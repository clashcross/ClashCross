import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kommon/kommon.dart' hide ProxyTypes;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:proxy_manager/proxy_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../bean/clash_config_entity.dart';
import '../generated_bindings.dart';
import '../main.dart';
import 'notification_service.dart';

late NativeLibrary clashFFI;
const mobileChannel = MethodChannel("ClashCrossPlugin");

class ClashService extends GetxService with TrayListener {
  // 需要一起改端口
  static const clashBaseUrl = "http://127.0.0.1:$clashExtPort";
  static const clashExtPort = 22345;

  // 运行时
  late Directory _clashDirectory;
  RandomAccessFile? _clashLock;

  // 流量
  final uploadRate = 0.0.obs;
  final downRate = 0.0.obs;
  final yamlConfigs = RxSet<FileSystemEntity>();

  // final currentYaml = isDesktop?'config.yaml'.obs:"".obs;
  final currentYaml = 'config.yaml'.obs;
  final proxyStatus = RxMap<String, int>();

  // action
  static const ACTION_SET_SYSTEM_PROXY = "assr";
  static const ACTION_UNSET_SYSTEM_PROXY = "ausr";
  static const ACTION_CPOY_SYSTEM_PROXY = "cpoy";
  static const MAX_ENTRIES = 5;

  // default port
  static var initializedHttpPort = 0;
  static var initializedSockPort = 0;
  static var initializedMixedPort = 0;

  // config
  Rx<ClashConfigEntity?> configEntity = Rx(null);

  // log
  Stream<dynamic>? logStream;
  RxMap<String, dynamic> proxies = RxMap();
  RxBool isSystemProxyObs = RxBool(false);
  String app_version = '';
  String build_number = '';

  ClashService() {
    // load lib
    var fullPath = "";
    if (Platform.isWindows) {
      fullPath = "libclash.dll";
    } else if (Platform.isMacOS) {
      fullPath = "libclash.dylib";
    } else {
      fullPath = "libclash.so";
    }
    final lib = ffi.DynamicLibrary.open(fullPath);

    // var libraryPath = p.join(Directory.current.path, 'clash', 'libclash.so');
    // if (Platform.isMacOS) {
    //   libraryPath = p.join(Directory.current.path, 'clash', 'libclash.dylib');
    // }
    // if (Platform.isWindows) {
    //   libraryPath = p.join(Directory.current.path, 'clash', 'libclash.dll');
    // }
    // final lib = ffi.DynamicLibrary.open(libraryPath);

    clashFFI = NativeLibrary(lib);
    clashFFI.init_native_api_bridge(ffi.NativeApi.initializeApiDLData);
  }

  Future<ClashService> init() async {
    _clashDirectory = await getApplicationSupportDirectory();
    // init config yaml
    final _ = SpUtil.getData('yaml', defValue: currentYaml.value);
    initializedHttpPort = SpUtil.getData('http-port', defValue: 12346);
    initializedSockPort = SpUtil.getData('socks-port', defValue: 12347);
    initializedMixedPort = SpUtil.getData('mixed-port', defValue: 12348);
    currentYaml.value = _;
    Request.setBaseUrl(clashBaseUrl);
    // init clash
    // kill all other clash clients
    final clashConfigPath = p.join(_clashDirectory.path, "clash");
    _clashDirectory = Directory(clashConfigPath);
    print("fclash work directory: ${_clashDirectory.path}");
    final clashConf = p.join(_clashDirectory.path, currentYaml.value);
    final countryMMdb = p.join(_clashDirectory.path, 'Country.mmdb');
    if (!await _clashDirectory.exists()) {
      await _clashDirectory.create(recursive: true);
    }
    // copy executable to directory
    final mmdb = await rootBundle.load('assets/tp/clash/Country.mmdb');
    // write to clash dir
    final mmdbF = File(countryMMdb);
    if (!mmdbF.existsSync()) {
      await mmdbF.writeAsBytes(mmdb.buffer.asInt8List());
    }
    // if(isDesktop){
    final config = await rootBundle.load('assets/tp/clash/config.yaml');
    // write to clash dir
    final configF = File(clashConf);
    if (!configF.existsSync()) {
      await configF.writeAsBytes(config.buffer.asInt8List());
    }
    // }
    // create or detect lock file
    await _acquireLock(_clashDirectory);
    // ffi
    clashFFI.set_home_dir(_clashDirectory.path.toNativeUtf8().cast());
    clashFFI.clash_init(_clashDirectory.path.toNativeUtf8().cast());
    clashFFI.set_config(clashConf.toNativeUtf8().cast());
    clashFFI.set_ext_controller(clashExtPort);
    if (clashFFI.parse_options() == 0) {
      Get.printInfo(info: "parse ok");
    }
    Future.delayed(Duration.zero, () {
      initDaemon();
    });
    // tray show issue
    if (isDesktop) {
      trayManager.addListener(this);
    }
    getAppVersion();
    // wait getx initialize
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!Platform.isWindows) {
    //     Get.find<NotificationService>()
    //         .showNotification("ClashCross", "Is running".tr);
    //   }
    // });
    return this;
  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    app_version = version;
    build_number = buildNumber;
    print('App Version: $version');
    print('Build Number: $buildNumber');
  }

  void getConfigs() {
    yamlConfigs.clear();
    final entities = _clashDirectory.listSync();
    for (final entity in entities) {
      if (entity.path.toLowerCase().endsWith('.yaml') &&
          !yamlConfigs.contains(entity)) {
        yamlConfigs.add(entity);
        Get.printInfo(info: 'detected: ${entity.path}');
      }
    }
  }

  Map<String, dynamic> getConnections() {
    String connections =
        clashFFI.get_all_connections().cast<Utf8>().toDartString();
    return json.decode(connections);
  }

  void closeAllConnections() {
    clashFFI.close_all_connections();
  }

  bool closeConnection(String connectionId) {
    final id = connectionId.toNativeUtf8().cast<ffi.Char>();
    return clashFFI.close_connection(id) == 1;
  }

  void getCurrentClashConfig() {
    configEntity.value = ClashConfigEntity.fromJson(
        json.decode(clashFFI.get_configs().cast<Utf8>().toDartString()));
  }

  Future<void> reload() async {
    // get configs
    getConfigs();
    getCurrentClashConfig();
    // proxies
    getProxies();
    updateTray();
  }

  // Future<bool> isRunning() async {
  //   try {
  //     final resp = await Request.get(clashBaseUrl,
  //         options: Options(sendTimeout: 1000, receiveTimeout: 1000));
  //     if ('clash' == resp['hello']) {
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  void initDaemon() async {
    printInfo(info: 'init clash service');
    // wait for online
    // while (!await isRunning()) {
    //   printInfo(info: 'waiting online status');
    //   await Future.delayed(const Duration(milliseconds: 500));
    // }
    // get traffic
    Timer.periodic(const Duration(seconds: 1), (t) {
      final traffic = clashFFI.get_traffic().cast<Utf8>().toDartString();
      if (kDebugMode) {
        // debugPrint("$traffic");
      }
      try {
        final trafficJson = jsonDecode(traffic);
        uploadRate.value = trafficJson['Up'].toDouble() / 1024; // KB
        downRate.value = trafficJson['Down'].toDouble() / 1024; // KB
        // fix: 只有KDE不会导致Tray自动消失
        // final desktop = Platform.environment['XDG_CURRENT_DESKTOP'];
        // updateTray();
      } catch (e) {
        Get.printError(info: '$e');
      }
    });
    // system proxy
    // listen port
    await reload();
    checkPort();
    if (isSystemProxy()) {
      setSystemProxy();
    }
  }

  @override
  void onClose() {
    closeClashDaemon();
    super.onClose();
  }

  Future<void> closeClashDaemon() async {
    Get.printInfo(info: 'fclash: closing daemon');
    // double check
    // stopClashSubP();
    if (isSystemProxy()) {
      // just clear system proxy
      await clearSystemProxy(permanent: false);
    }
    await _clashLock?.unlock();
  }

  void getProxies() {
    proxies.value =
        json.decode(clashFFI.get_proxies().cast<Utf8>().toDartString());
  }

  /// @Deprecated
  // Future<Stream<Uint8List>?> getTraffic() async {
  //   Response<ResponseBody> resp = await Request.dioClient
  //       .get('/traffic', options: Options(responseType: ResponseType.stream));
  //   return resp.data?.stream;
  // }

  // @Deprecated
  // Future<Stream<Uint8List>?> _getLog({String type = "info"}) async {
  //   Response<ResponseBody> resp = await Request.dioClient.get('/logs',
  //       options: Options(responseType: ResponseType.stream),
  //       queryParameters: {"level": type});
  //   return resp.data?.stream;
  // }

  void startLogging() {
    final receiver = ReceivePort();
    logStream = receiver.asBroadcastStream();
    if (kDebugMode) {
      logStream?.listen((event) {
        debugPrint("LOG: ${event}");
      });
    }
    final nativePort = receiver.sendPort.nativePort;
    debugPrint("port: $nativePort");
    clashFFI.start_log(nativePort);
  }

  Future<bool> _changeConfig(FileSystemEntity config) async {
    // check if it has `rule-set`, and try to convert it
    final content = await convertConfig(await File(config.path).readAsString())
        .catchError((e) {
      printError(info: e);
    });
    if (content.isNotEmpty) {
      await File(config.path).writeAsString(content);
    }
    // judge valid
    if (clashFFI.is_config_valid(config.path.toNativeUtf8().cast()) == 0) {
      final resp = await Request.dioClient.put('/configs',
          queryParameters: {"force": false}, data: {"path": config.path});
      Get.printInfo(info: 'config changed ret: ${resp.statusCode}');
      currentYaml.value = p.basename(config.path);
      SpUtil.setData('yaml', currentYaml.value);
      return resp.statusCode == 204;
    } else {
      Future.delayed(Duration.zero, () {
        Get.defaultDialog(
            middleText: 'not a valid config file'.tr,
            onConfirm: () {
              Get.back();
            });
      });
      config.delete();
      return false;
    }
  }

  Future<bool> changeYaml(FileSystemEntity config) async {
    try {
      if (await config.exists()) {
        return await _changeConfig(config);
      } else {
        return false;
      }
    } finally {
      reload();
    }
  }

  bool changeProxy(String selectName, String proxyName) {
    final ret = clashFFI.change_proxy(
        selectName.toNativeUtf8().cast(), proxyName.toNativeUtf8().cast());
    if (ret == 0) {
      reload();
    }
    return ret == 0;
  }

  bool changeConfigField(String field, dynamic value) {
    try {
      int ret = clashFFI.change_config_field(
          json.encode(<String, dynamic>{field: value}).toNativeUtf8().cast());
      return ret == 0;
    } finally {
      getCurrentClashConfig();
      if (field.endsWith("port") && isSystemProxy()) {
        setSystemProxy();
      }
    }
  }

  bool isSystemProxy() {
    return SpUtil.getData('system_proxy', defValue: false);
  }

  Future<bool> setIsSystemProxy(bool proxy) {
    isSystemProxyObs.value = proxy;
    return SpUtil.setData('system_proxy', proxy);
  }

  Future<void> setSystemProxy() async {
    if (isDesktop) {
      if (configEntity.value != null) {
        final entity = configEntity.value!;
        if (entity.port != 0) {
          await Future.wait([
            proxyManager.setAsSystemProxy(
                ProxyTypes.http, '127.0.0.1', entity.port!),
            proxyManager.setAsSystemProxy(
                ProxyTypes.https, '127.0.0.1', entity.port!)
          ]);
          debugPrint("set http");
        }
        if (entity.socksPort != 0 && !Platform.isWindows) {
          debugPrint("set socks");
          await proxyManager.setAsSystemProxy(
              ProxyTypes.socks, '127.0.0.1', entity.socksPort!);
        }
        await setIsSystemProxy(true);
      }
    } else {
      if (configEntity.value != null) {
        final entity = configEntity.value!;
        if (entity.port != 0) {
          await mobileChannel
              .invokeMethod("SetHttpPort", {"port": entity.port});
        }
        mobileChannel.invokeMethod("StartProxy");
        await setIsSystemProxy(true);
      }

      // await Clipboard.setData(
      //     ClipboardData(text: "${configEntity.value?.port}"));
      // final dialog = BrnDialog(
      //   titleText: "请手动设置代理",
      //   messageText:
      //       "端口号已复制。请进入已连接WiFi的详情设置，将代理设置为手动，主机名填写127.0.0.1，端口填写${configEntity.value?.port}，然后返回点击已完成即可",
      //   actionsText: ["取消", "已完成", "去设置填写"],
      //   indexedActionCallback: (index) async {
      //     if (index == 0) {
      //       if (Get.isOverlaysOpen) {
      //         Get.back();
      //       }
      //     } else if (index == 1) {
      //       final proxy = await SystemProxy.getProxySettings();
      //       if (proxy != null) {
      //         if (proxy["host"] == "127.0.0.1" &&
      //             int.parse(proxy["port"].toString()) ==
      //                 configEntity.value?.port) {
      //           Future.delayed(Duration.zero, () {
      //             if (Get.overlayContext != null) {
      //               BrnToast.show("设置成功", Get.overlayContext!);
      //               setIsSystemProxy(true);
      //             }
      //           });
      //           if (Get.isOverlaysOpen) {
      //             Get.back();
      //           }
      //         }
      //       } else {
      //         Future.delayed(Duration.zero, () {
      //           if (Get.overlayContext != null) {
      //             BrnToast.show("好像未完成设置哦", Get.overlayContext!);
      //           }
      //         });
      //       }
      //     } else {
      //       Future.delayed(Duration.zero, () {
      //         BrnToast.show("端口号已复制", Get.context!);
      //       });
      //       await OpenSettings.openWIFISetting();
      //     }
      //   },
      // );
      // Get.dialog(dialog);
    }
    reload();
  }

  Future<void> clearSystemProxy({bool permanent = true}) async {
    if (isDesktop) {
      await proxyManager.cleanSystemProxy();
      if (permanent) {
        await setIsSystemProxy(false);
      }
    } else {
      mobileChannel.invokeMethod("StopProxy");
      await setIsSystemProxy(false);
      // final dialog = BrnDialog(
      //   titleText: "请手动设置代理",
      //   messageText: "请进入已连接WiFi的详情设置，将代理设置为无",
      //   actionsText: ["取消", "已完成", "去设置清除"],
      //   indexedActionCallback: (index) async {
      //     if (index == 0) {
      //       if (Get.isOverlaysOpen) {
      //         Get.back();
      //       }
      //     } else if (index == 1) {
      //       final proxy = await SystemProxy.getProxySettings();
      //       if (proxy != null) {
      //         Future.delayed(Duration.zero, () {
      //           if (Get.overlayContext != null) {
      //             BrnToast.show("好像没有清除成功哦，当前代理${proxy}", Get.overlayContext!);
      //           }
      //         });
      //       } else {
      //         Future.delayed(Duration.zero, () {
      //           if (Get.overlayContext != null) {
      //             BrnToast.show("清除成功", Get.overlayContext!);
      //           }
      //           setIsSystemProxy(false);
      //           if (Get.isOverlaysOpen) {
      //             Get.back();
      //           }
      //         });
      //       }
      //     } else {
      //       OpenSettings.openWIFISetting().then((_) async {
      //         final proxy = await SystemProxy.getProxySettings();
      //         debugPrint("$proxy");
      //       });
      //     }
      //   },
      // );
      // Get.dialog(dialog);
    }
    reload();
  }

  Future<void> copySystemProxy() async {
    String copyLinuxMac = "";
    String copyWindows = "";
    if (isDesktop) {
      if (configEntity.value != null) {
        final entity = configEntity.value!;
        if (!Platform.isWindows) {
          if (entity.socksPort != 0) {
            copyLinuxMac =
                "export all_proxy=socks:5//127.0.0.1:${entity.socksPort} ";
          }
          if (entity.port != 0) {
            copyLinuxMac += "export http=http://127.0.0.1:${entity.port} ";
            copyLinuxMac += "export https=https://127.0.0.1:${entity.port} ";
          }
          await Clipboard.setData(ClipboardData(text: copyLinuxMac));
        } else {
          if (entity.socksPort != 0) {
            copyWindows =
                "SET all_proxy=socks:5//127.0.0.1:${entity.socksPort} ";
          }
          if (entity.port != 0) {
            copyWindows += "SET http=http://127.0.0.1:${entity.port} ";
            copyWindows += "SET https=https://127.0.0.1:${entity.port} ";
          }
          await Clipboard.setData(ClipboardData(text: copyWindows));
        }
      }
    } else {}
  }

  void updateTray() {
    if (!isDesktop) {
      return;
    }
    final stringList = List<MenuItem>.empty(growable: true);
    // yaml
    stringList
        .add(MenuItem(label: "profile: ${currentYaml.value}", disabled: true));
    if (proxies['proxies'] != null) {
      Map<String, dynamic> m = proxies['proxies'];
      m.removeWhere((key, value) => value['type'] != "Selector");
      var cnt = 0;
      for (final k in m.keys) {
        if (cnt >= ClashService.MAX_ENTRIES) {
          stringList.add(MenuItem(label: "...", disabled: true));
          break;
        }
        stringList.add(
            MenuItem(label: "${m[k]['name']}: ${m[k]['now']}", disabled: true));
        cnt += 1;
      }
    }
    // port
    if (configEntity.value != null) {
      stringList.add(
          MenuItem(label: 'http: ${configEntity.value?.port}', disabled: true));
      stringList.add(MenuItem(
          label: 'socks: ${configEntity.value?.socksPort}', disabled: true));
    }
    // system proxy
    stringList.add(MenuItem.separator());
    if (!isSystemProxy()) {
      stringList
          .add(MenuItem(label: "Not system proxy yet.".tr, disabled: true));
      stringList.add(MenuItem(
          label: "复制终端代理命令".tr, toolTip: "复制代理命令到终端运行".tr, disabled: true));
      stringList.add(MenuItem(
          label: "Set as system proxy".tr,
          toolTip: "click to set as system proxy".tr,
          key: ACTION_SET_SYSTEM_PROXY));
    } else {
      stringList.add(MenuItem(label: "System proxy now.".tr, disabled: true));
      stringList.add(MenuItem(
          label: "Unset system proxy".tr,
          toolTip: "click to reset system proxy".tr,
          key: ACTION_UNSET_SYSTEM_PROXY));
      stringList.add(MenuItem(
          label: "Copy terminal proxy command".tr,
          toolTip: "Copy the proxy command and run it in the terminal".tr,
          key: ACTION_CPOY_SYSTEM_PROXY));
      stringList.add(MenuItem.separator());
    }
    initAppTray(details: stringList, isUpdate: true);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case ACTION_SET_SYSTEM_PROXY:
        setSystemProxy().then((value) {
          // reload();
        });
        break;
      case ACTION_UNSET_SYSTEM_PROXY:
        clearSystemProxy().then((_) {
          // reload();
        });
        break;
      case ACTION_CPOY_SYSTEM_PROXY:
        copySystemProxy();
        break;
      // case 'show':
      //   windowManager.show();
      //   break;
      // case 'exit':
      //   windowManager.close();
      //   clearSystemProxy().then((value) => exit(0));
    }
  }

  Future<bool> addProfile(String name, String url) async {
    final configName = '$name.yaml';
    final newProfilePath = p.join(_clashDirectory.path, configName);
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        return false;
      }
      final resp = await Dio(BaseOptions(
              headers: {'User-Agent': 'ClashCross'},
              sendTimeout: 15000,
              receiveTimeout: 15000))
          .downloadUri(uri, newProfilePath, onReceiveProgress: (i, t) {
        Get.printInfo(info: "$i$t");
      }).catchError((e) {
        EasyLoading.showError('Error: $e');
      });
      return resp.statusCode == 200;
    } catch (e) {
      EasyLoading.showError('Error: $e');
    } finally {
      final f = File(newProfilePath);
      if (f.existsSync() && await changeYaml(f)) {
        await SpUtil.setData('profile_$name', url);
        EasyLoading.showSuccess("导入配置成功！");
        return true;
      }
      EasyLoading.showError("导入配置失败");
      return false;
    }
  }

  Future<bool> deleteProfile(FileSystemEntity config) async {
    if (config.existsSync()) {
      config.deleteSync();
      await SpUtil.remove('profile_${p.basename(config.path)}');
      reload();
      return true;
    } else {
      return false;
    }
  }

  void checkPort() {
    if (configEntity.value != null) {
      if (configEntity.value!.port == 0) {
        changeConfigField('port', initializedHttpPort);
      }
      if (configEntity.value!.mixedPort == 0) {
        changeConfigField('mixed-port', initializedMixedPort);
      }
      if (configEntity.value!.socksPort == 0) {
        changeConfigField('socks-port', initializedSockPort);
      }
      updateTray();
    }
  }

  Future<int> delay(String proxyName,
      {int timeout = 5000, String url = "https://www.google.com"}) async {
    try {
      final completer = Completer<int>();
      final receiver = ReceivePort();
      clashFFI.async_test_delay(proxyName.toNativeUtf8().cast(),
          url.toNativeUtf8().cast(), timeout, receiver.sendPort.nativePort);
      final subs = receiver.listen((message) {
        if (!completer.isCompleted) {
          completer.complete(json.decode(message)['delay']);
        }
      });
      // 5s timeout, we add 1s
      Future.delayed(const Duration(seconds: 6), () {
        if (!completer.isCompleted) {
          completer.complete(-1);
        }
        subs.cancel();
      });
      return completer.future;
    } catch (e) {
      return -1;
    }
  }

  /// yaml: test
  String getSubscriptionLinkByYaml(String yaml) {
    final url = SpUtil.getData('profile_$yaml', defValue: "");
    Get.printInfo(info: 'subs link for $yaml: $url');
    return url;
  }

  /// stop clash by ps -A
  /// ps -A | grep '[^f]clash' | awk '{print $1}' | xargs
  ///
  /// notice: is a double check in client mode
  // void stopClashSubP() {
  //   final res = Process.runSync("ps", [
  //     "-A",
  //     "|",
  //     "grep",
  //     "'[^f]clash'",
  //     "|",
  //     "awk",
  //     "'print \$1'",
  //     "|",
  //     "xrgs",
  //   ]);
  //   final clashPids = res.stdout.toString().split(" ");
  //   for (final pid in clashPids) {
  //     final pidInt = int.tryParse(pid);
  //     if (pidInt != null) {
  //       Process.killPid(int.parse(pid));
  //     }
  //   }
  // }

  Future<bool> updateSubscription(String name) async {
    final configName = '$name.yaml';
    final newProfilePath = p.join(_clashDirectory.path, configName);
    final url = SpUtil.getData('profile_$name');
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        return false;
      }
      // delete exists
      final f = File(newProfilePath);
      final tmpF = File('$newProfilePath.tmp');

      final resp = await Dio(BaseOptions(
              headers: {'User-Agent': 'ClashCross'},
              sendTimeout: 15000,
              receiveTimeout: 15000))
          .downloadUri(uri, tmpF.path, onReceiveProgress: (i, t) {
        Get.printInfo(info: "$i/$t");
      }).catchError((e) {
        if (tmpF.existsSync()) {
          tmpF.deleteSync();
        }
      });
      if (resp.statusCode == 200) {
        if (f.existsSync()) {
          f.deleteSync();
        }
        tmpF.renameSync(f.path);
      }
      // set subscription
      await SpUtil.setData('profile_$name', url);
      return resp.statusCode == 200;
    } finally {
      final f = File(newProfilePath);
      if (f.existsSync()) {
        await changeYaml(f);
      }
    }
  }

  bool isHideWindowWhenStart() {
    return SpUtil.getData('boot_window_hide', defValue: false);
  }

  Future<bool> setHideWindowWhenStart(bool hide) {
    return SpUtil.setData('boot_window_hide', hide);
  }

  void handleSignal() {
    StreamSubscription? subTerm;
    subTerm = ProcessSignal.sigterm.watch().listen((event) {
      subTerm?.cancel();
      // _clashProcess?.kill();
    });
  }

  Future<void> testAllProxies(List<dynamic> allItem) async {
    await Future.wait(allItem.map((proxyName) async {
      final delayInMs = await delay(proxyName);
      proxyStatus[proxyName] = delayInMs;
    }));
  }

  Future<void> _acquireLock(Directory clashDirectory) async {
    final path = p.join(clashDirectory.path, "ClashCross.lock");
    final lockFile = File(path);
    if (!lockFile.existsSync()) {
      lockFile.createSync(recursive: true);
    }
    try {
      _clashLock = await lockFile.open(mode: FileMode.write);
      await _clashLock?.lock();
    } catch (e) {
      if (!Platform.isWindows) {
        await Get.find<NotificationService>()
            .showNotification("ClashCross", "Already running, Now exit.".tr);
      }
      exit(0);
    }
  }

  void stopLog() {
    logStream = null;
    clashFFI.stop_log();
  }
}

Future<String> convertConfig(String content) async {
  try {
    final yamlWriter = YAMLWriter();
    final payloadMap = <String, List>{};
    Map doc = json.decode(json.encode(loadYaml(content, recover: true)));
    // 下载rule-provider对应的payload文件
    if (doc.containsKey('rule-providers')) {
      // if (Get.overlayContext != null) {
      //   final completer = Completer<bool>();
      //   if (Get.isOverlaysOpen) {
      //     Get.back();
      //   }
      //   BrnDialogManager.showConfirmDialog(Get.overlayContext!,
      //       title: 'Convert profile'.tr,
      //       message:
      //           'Your profile contains RULE-SET which needs to convert to the profile supported by open source clash'
      //               .tr,
      //       cancel: 'Continue anyway'.tr,
      //       confirm: 'OK'.tr, onCancel: () {
      //     Get.back();
      //     completer.complete(false);
      //   }, onConfirm: () {
      //     Get.back();
      //     completer.complete(true);
      //   }, barrierDismissible: false);
      //   final res = await completer.future;
      //   if (!res) {
      //     return content;
      //   }
      // }
      BrnLoadingDialog.show(Get.overlayContext!);
      Map providers = doc['rule-providers'];
      final total = providers.keys.length;
      final index = 0.obs;
      // 进度显示
      // Get.dialog(BrnDialog(
      //   titleText: 'Converting',
      //   contentWidget: Center(
      //     child: Obx(
      //       () => Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           const SizedBox(
      //             width: 25,
      //             height: 25,
      //             child: BrnPageLoading(),
      //           ),
      //           Text("$index/$total")
      //         ],
      //       ),
      //     ),
      //   ),
      // ));

      // var downloadFutures = <Future>[];
      // for (final provider in providers.entries) {
      //   downloadFutures.add(Future.delayed(Duration.zero, () async {
      //     final key = provider.key;
      //     final value = provider.value;
      //     final url = value['url'];
      //     // debugPrint("Downloading $url");
      //     // if (url != null) {
      //     //   final resp = await (Dio().get(url));
      //     //   Map respDoc = loadYaml(resp.data, recover: true);
      //     //   payloadMap[key] = List.of(respDoc['payload']);
      //     //   debugPrint("$url completed");
      //     index.value++;
      //     // }
      //   }));
      // }
      // await Future.wait(downloadFutures);
      // if (Get.isOverlaysOpen) {
      //   Get.back();
      // }
      // 开始转换rules
      var rules = doc['rules'];
      var newRules = [];
      for (var i = 0; i < rules.length; i++) {
        String rule = rules[i];
        final tuple = rule.split(",");
        assert(tuple.length == 3);
        // RULE-SET,其它影音站点,其它影音站点
        if (tuple[0] == 'RULE-SET') {
          final provider = tuple[1];
          final proxyTo = tuple[2];
          if (payloadMap[provider] != null) {
            for (final payload in payloadMap[provider]!) {
              var payloadArr = payload.toString().split(',');
              if (payloadArr.isEmpty) {
                continue;
              }
              // IP加上IP-CIDR
              if (int.tryParse(payloadArr.first.substring(0, 1)) != null) {
                payloadArr.insert(0, 'IP-CIDR');
              }
              // https://github.com/Dreamacro/clash/wiki/configuration#no-resolve
              if (payload.endsWith('no-resolve')) {
                payloadArr.insert(payloadArr.length - 1, proxyTo);
              } else {
                payloadArr.add(proxyTo);
              }
              newRules.add(payloadArr.join(','));
            }
          }
        } else {
          if (tuple.where((element) => element.isEmpty).isEmpty) {
            newRules.add(rule);
          }
        }
      }
      // doc.remove('rule-providers');
      doc['rules'] = newRules;
      final outputString = yamlWriter.write(doc);
      return outputString;
    } else {
      // no need to update
      return "";
    }
  } catch (e) {
    debugPrint("$e");
    // ignore
    return "";
  } finally {
    BrnLoadingDialog.dismiss(Get.overlayContext!);
  }
}
