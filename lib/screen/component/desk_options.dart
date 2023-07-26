import 'dart:io';

import 'package:clashcross/screen/component/speed.dart';
import 'package:clashcross/screen/component/windows_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../service/clash_service.dart';

class DeskOptions extends StatelessWidget {
  const DeskOptions({super.key});

  @override
  Widget build(BuildContext context) {

    final nonSelectedColor = Colors.grey.shade400;
    const selectedColor = Colors.blueAccent;
    const style = TextStyle(color: Colors.white);
    return Obx(
          () {
        final mode =
            Get.find<ClashService>().configEntity.value?.mode ?? "Direct";
        debugPrint("current mode: $mode");
        return GestureDetector(
          onPanStart: (_) {
            windowManager.startDragging();
          },
          child: SizedBox(
            // height: 75,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const AppIcon().marginOnly(top: Platform.isMacOS ? 12.0 : 0.0),
                // Switch
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Rule');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mode == "rule"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "rule".tr,
                            style: style,
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
                              color: mode == "global"
                                  ? selectedColor
                                  : nonSelectedColor),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("global".tr, style: style),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Direct');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mode == "direct"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("direct".tr, style: style),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      decoration:
                      const BoxDecoration(color: Colors.transparent),
                      child: const SpeedWidget()),
                ),
                if (!Platform.isMacOS) const WindowsPanel()
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: const CircleAvatar(
        foregroundImage: AssetImage("assets/images/rocket.png"),
        radius: 20,
      ),
    );
  }
}