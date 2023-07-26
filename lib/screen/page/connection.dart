import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kommon/kommon.dart';
import 'package:provider/provider.dart';

import '../../model/themeCollection.dart';
import '../../service/clash_service.dart';

class Connections extends StatefulWidget {
  const Connections({Key? key}) : super(key: key);

  @override
  State<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  late Timer _timer;
  RxMap<String, dynamic> connections = RxMap();
  RxString searchField = "".obs;

  @override
  void initState() {
    super.initState();
    connections.value = Get.find<ClashService>().getConnections();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      connections.value = Get.find<ClashService>().getConnections();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ThemeCollection>(context);
    bool isDarkTheme = Provider.of<ThemeCollection>(context).isDarkActive;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text('Connections'.tr,),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CloseButton(),
          )
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          elevation: 6,
                          color: isDarkTheme
                              ? const Color(0xff181227)
                              : const Color(0xffF5F5F6),
                          child: TextField(
                            onChanged: (s) {
                              searchField.value = s;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDarkTheme
                                    ? const Color(0xffF5F5F6)
                                    : const Color(0xff181227),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ).paddingSymmetric(horizontal: 32),
                        )),
                      ],
                    ),
                    Expanded(child: Obx(
                      () {
                        Iterable<dynamic> conns = connections["connections"];
                        // search
                        if (searchField.isNotEmpty) {
                          conns = conns.where((element) => element["metadata"]
                                  ['host']
                              .toString()
                              .contains(searchField.value));
                        }
                        final li = conns.toList(growable: false);
                        return ListView.builder(
                          itemCount: li.length,
                          itemBuilder: (context, index) =>
                              _buildConnection(li[index]),
                        );
                      },
                    ))
                  ],
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 115.0,
              // decoration: BoxDecoration(
              //   color: Colors.white
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => BrnEnhanceNumberCard(
                      backgroundColor: Colors.transparent,
                      itemChildren: [
                        BrnNumberInfoItemModel(
                            number:
                                getTrafficString(connections["uploadTotal"]),
                            title: "Upload".tr,
                            lastDesc: "MB"),
                      ],
                      themeData: BrnEnhanceNumberCardConfig(
                        titleTextStyle: BrnTextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                ?.color,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Obx(
                    () => BrnEnhanceNumberCard(
                      backgroundColor: Colors.transparent,
                      itemChildren: [
                        BrnNumberInfoItemModel(
                            number:
                                getTrafficString(connections["downloadTotal"]),
                            title: "Download".tr,
                            lastDesc: "MB"),
                      ],
                      themeData: BrnEnhanceNumberCardConfig(
                        titleTextStyle: BrnTextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                ?.color,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  BrnNormalButton(
                    onTap: () {
                      Get.find<ClashService>().closeAllConnections();
                      EasyLoading.showToast("Success".tr);
                      // BrnToast.show("Success".tr, context);
                    },
                    text: "Close all connections".tr,
                    backgroundColor: Colors.redAccent,
                  ).paddingSymmetric(horizontal: 32, vertical: 32)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConnection(Map<String, dynamic> conn) {
    bool isDarkTheme = Provider.of<ThemeCollection>(context).isDarkActive;
    String key = conn["id"];
    Map<String, dynamic> meta = conn["metadata"];
    List<dynamic> chains = conn["chains"];
    final hover = false.obs;
    return Card(
      elevation: 6,
      color: isDarkTheme ? const Color(0xff181227) : const Color(0xffF5F5F6),
      child: MouseRegion(
        onHover: (ev) {
          hover.value = true;
        },
        onExit: (ev) {
          hover.value = false;
        },
        child: Obx(
          () => Container(
            decoration:
                BoxDecoration(color: hover.value ? Colors.white38 : null),
            child: Row(
              key: ValueKey(key),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BrnStateTag(
                          tagText: "${meta["host"]}",
                          tagState: TagState.invalidate,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BrnStateTag(
                          tagText: "${meta["network"]}",
                          tagState: TagState.running,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        BrnStateTag(
                          tagText: "${meta["type"]}",
                          tagState: TagState.running,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BrnStateTag(
                          tagText:
                              "${meta["sourceIP"]}:${meta["sourcePort"]} -> ${meta["destinationIP"]}:${meta["destinationPort"]}",
                          tagState: TagState.succeed,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BrnStateTag(
                          tagText: "$chains".length>20?"$chains".substring(0,20):"$chains",

                          tagState: TagState.running,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        BrnStateTag(
                          tagText:
                              "${DateTime.now().difference(DateTime.tryParse(conn["start"]) ?? DateTime.now()).inSeconds}s",
                          tagState: TagState.running,
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.upload_rounded),
                              Text(
                                overflow:TextOverflow.ellipsis,
                                "${getTrafficString(conn["upload"])}MB",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodySmall,
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.download_rounded),
                              Text(
                                overflow:TextOverflow.ellipsis,
                                "${getTrafficString(conn["download"])}MB",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodySmall,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    BrnNormalButton(
                      text: "Close".tr,
                      backgroundColor: Colors.redAccent,
                      onTap: () {
                        bool res = Get.find<ClashService>()
                            .closeConnection(conn["id"]);
                        EasyLoading.showToast(
                          res ? "Success".tr : "Failed".tr,
                        );
                        // BrnToast.show(
                        //     res ? "Success".tr : "Failed".tr, context);
                      },
                    )
                  ],
                ).paddingSymmetric(horizontal: 0))
              ],
            ).paddingSymmetric(horizontal: 0, vertical: 4),
          ),
        ),
      ),
    );
  }
}

// in MB
String getTrafficString(int traffic) {
  return (traffic * 1.0 / 1024 / 1024).toStringAsFixed(1);
}
