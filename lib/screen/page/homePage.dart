//ignore_for_file: file_names
import 'dart:async';
import 'dart:io';

import 'package:clashcross/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kommon/kommon.dart';
import 'package:provider/provider.dart';

import '../../model/themeCollection.dart';
import '../component/speed.dart';
import 'proxy.dart';
import '../../service/clash_service.dart';
import '../../service/notification_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Provider.of<ThemeCollection>(context).isDarkActive;

    final cs = Get.find<ClashService>();
    final nt = Get.find<NotificationService>();
    cs.updateTray();
    Map<String, dynamic> maps = cs.proxies.value['proxies'] ?? {};
    var selectors = maps.keys.where((proxy) {
      return maps[proxy]['type'] == 'Selector';
    }).toList(growable: false);
    final mode = Get.find<ClashService>().configEntity.value?.mode ?? "direct";
    if (mode == "global") {
      selectors = selectors
          .where((sel) => maps[sel]['name'].toLowerCase() == 'global')
          .toList();
    } else {
      selectors = selectors
          .where((sel) => maps[sel]['name'].toLowerCase() != 'global')
          .toList();
    }

    print(cs.proxies);
    for (var element in selectors) {
      // maps[element];
      // break;
    }
    final nonSelectedColor = Colors.grey.shade400;
    const selectedColor = Colors.blueAccent;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: kToolbarHeight * 1.2,
              child: Card(
                elevation: 6,
                color: isDarkTheme
                    ? const Color(0xff181227)
                    : const Color(0xffF5F5F6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Builder(builder: (context) {
                  return ListTile(
                    onTap: () {
                      Get.to(const Proxy());
                    },
                    leading: SvgPicture.asset(
                      // 'assets/flags/${Flags.list[currentLocIndex]['imagePath']}',
                      'assets/active.svg',
                      width: 30,
                      alignment: Alignment.center,
                    ),
                    trailing: SizedBox(
                      // width: 80,
                      child: IconButton(
                        icon: Icon(
                          Icons.navigate_next_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          Get.to(const Proxy());
                        },

                        // onPressed: () => Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //         builder: (builder) =>
                        //         const ChooseLocationRoute())) as int,
                      ),
                    ),
                    title: Text(
                      'Current using'.trParams({"name": cs.currentYaml.value}),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).primaryTextTheme.headline6,
                    ),
                    // subtitle: Obx(() => Text(
                    //     'Current mode:'
                    //         .trParams({"name": cs.configEntity.value!.mode!}),
                    //     style: Theme.of(context).primaryTextTheme.caption)),
                  );
                }),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: SpeedWidget(),
          ),
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              SvgPicture.asset(
                'assets/map.svg',
                width: MediaQuery.of(context).size.width,
                color: isDarkTheme
                    ? const Color(0xff38323F)
                    : const Color(0xffC7B4E3),
                fit: BoxFit.fitWidth,
              ),
              Builder(builder: (context) {
                return Obx(() => GestureDetector(
                      onTap: () {
                        if (cs.isSystemProxyObs.value) {
                          cs.clearSystemProxy();
                          if (!Platform.isWindows) {
                            nt.cancelAllNotification();
                          }
                        } else {
                          cs.setSystemProxy();
                          if (!isDesktop) {
                            if (Platform.isAndroid) {
                              FlutterLocalNotificationsPlugin
                                  flutterLocalNotificationsPlugin =
                                  FlutterLocalNotificationsPlugin();
                              flutterLocalNotificationsPlugin
                                  .resolvePlatformSpecificImplementation<
                                      AndroidFlutterLocalNotificationsPlugin>()
                                  ?.requestPermission();
                              Timer.periodic(const Duration(seconds: 1), (t) {
                                nt.showNotification("ClashCross",
                                    "↑:${cs.uploadRate.value.toStringAsFixed(1)}KB/s ↓:${cs.downRate.value.toStringAsFixed(1)}KB/s");
                              });
                            }
                          }
                        }
                      },
                      child: Card(
                        elevation: 6,
                        color: isDarkTheme
                            ? const Color(0xff181227)
                            : const Color(0xffF5F5F6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        child: SizedBox.square(
                          dimension: 75 * 2,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  cs.isSystemProxyObs.value
                                      ? 'assets/stop.svg'
                                      : 'assets/powOn.svg',
                                  width: cs.isSystemProxyObs.value ? 50 : 50,
                                  color: cs.isSystemProxyObs.value
                                      ? Colors.redAccent.shade200
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    cs.isSystemProxyObs.value
                                        ? 'Tap to Stop'.tr
                                        : 'Tap to Start'.tr,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ));
              }),
            ],
          ),
          isDesktop?Container():Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Obx(
                    (){
                  final modeother = Get.find<ClashService>().configEntity.value?.mode ?? "direct";
                  return  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Rule');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: modeother == "rule"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "rule".tr,
                            // style: style,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Global');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: modeother == "global"
                                  ? selectedColor
                                  : nonSelectedColor
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("global".tr,
                            // style: style,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Direct');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: modeother == "direct"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("direct".tr,
                            // style: style
                          ),
                        ),
                      )
                    ],
                  );
                }
            ),


          ),
          Obx(
            () => (cs.currentYaml.value == "config.yaml" &&
                    cs.isSystemProxyObs.value)
                ? ListTile(
                    leading: const Icon(Icons.warning),
                    title: Text(
                      "Currently using config.yaml configuration. Please ensure that you have appropriate forwarding rules. Otherwise, please find and import usable rules on your own."
                          .tr,
                      style: Theme.of(context).primaryTextTheme.bodyMedium,
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
