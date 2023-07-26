import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:provider/provider.dart';

import '../../model/themeCollection.dart';
import '../../service/clash_service.dart';

class ClashLog extends StatefulWidget {
  const ClashLog({Key? key}) : super(key: key);

  @override
  State<ClashLog> createState() => _ClashLogState();
}

class _ClashLogState extends State<ClashLog> {
  final logs = RxList<String>();
  final buffer = List<String>.empty(growable: true);
  late Timer? _timer;
  final connected = false.obs;
  static const logMaxLen = 100;
  StreamSubscription<dynamic>? streamSubscription;

  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  void tryConnect() {
    Get.find<ClashService>().startLogging();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (buffer.isNotEmpty) {
        logs.insertAll(0, buffer.reversed);
        buffer.clear();
        if (logs.length > logMaxLen) {
          logs.value = logs.sublist(0, logMaxLen);
        }
      }
    });
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (streamSubscription == null) {
        if (Get.find<ClashService>().logStream == null) {
          printInfo(info: 'clash log stream not opened');
        }
        streamSubscription =
            Get.find<ClashService>().logStream?.listen((event) {
          String logStr = event;
          buffer.add(logStr);
          Get.printInfo(info: 'Log widget: $logStr');
        });
        if (streamSubscription == null) {
          printInfo(info: 'log service retry');
        } else {
          printInfo(info: 'log service connected'.tr);
          connected.value = true;
        }
      } else {
        connected.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    Get.printInfo(info: 'log dispose');
    Get.find<ClashService>().stopLog();
    streamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text('Log'.tr,),
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CloseButton(),
            )
          ],
        ),
    body: Column(
      children: [
        // Obx(
        //   () => BrnNoticeBar(
        //     content: connected.value
        //         ? 'Log is running. Any logs will show below.'.tr
        //         : "No Logs currently / Connecting to clash log daemon...".tr,
        //     showLeftIcon: true,
        //     showRightIcon: true,
        //     noticeStyle: connected.value
        //         ? NoticeStyles.succeedWithArrow
        //         : NoticeStyles.runningWithArrow,
        //   ),
        // ),
        Expanded(
          child: Obx(() => ListView.builder(
            itemBuilder: (cxt, index) {
              return Padding(
                key: ValueKey(logs[index]),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: buildLogItem(logs[index]),
              );
            },
            itemCount: logs.length,
          )),
        ),
      ],
    ),);
  }

  Widget buildLogItem(String log) {
    bool isDarkTheme = Provider.of<ThemeCollection>(context).isDarkActive;
    final json = jsonDecode(log) ?? {};
    return Card(
      elevation: 6,
      color: isDarkTheme
          ? const Color(0xff181227)
          : const Color(0xffF5F5F6),
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(12.0),
      //     color: Colors.grey.shade200),
      child: Stack(
        children: [
          Text(
            json['Payload'] ?? "",
            style: Theme.of(context).primaryTextTheme.bodyMedium,
          ),
          Align(
            alignment: Alignment.topRight,
            child: BrnStateTag(tagText: '${json['LogLevel']}'),
          )
        ],
      ),
    );
  }
}
