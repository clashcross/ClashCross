import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

import '../../service/clash_service.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() => BrnEnhanceNumberCard(
              backgroundColor: Colors.transparent,
              itemChildren: [
                BrnNumberInfoItemModel(
                    preDesc: "Download".tr,
                    number: Get.find<ClashService>()
                        .downRate
                        .value
                        .toStringAsFixed(1),
                    lastDesc: "KB/s"),
              ],
              rowCount: 4,
              itemTextAlign: TextAlign.center,
              themeData: BrnEnhanceNumberCardConfig(
                  titleTextStyle: BrnTextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6?.color,fontSize: 20),),
            )),
        Obx(() => BrnEnhanceNumberCard(
              // backgroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              itemChildren: [
                BrnNumberInfoItemModel(
                    preDesc: "Upload".tr,
                    number: Get.find<ClashService>()
                        .uploadRate
                        .value
                        .toStringAsFixed(1),
                    lastDesc: "KB/s"),
              ],
              rowCount: 4,
              itemTextAlign: TextAlign.center,
              themeData: BrnEnhanceNumberCardConfig(
                  titleTextStyle: BrnTextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6?.color,fontSize: 20)),
            )),
      ],
    );
  }
}
