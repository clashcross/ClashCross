import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kommon/kommon.dart';

import '../../tools/customlaunch.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Text('Help'.tr),
      ),
      body: SingleChildScrollView(
          child: Container(
        alignment: Alignment.center,
        // color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.warning),
            //   title: Text(
            //       "ClashCross is a proxy debugging application built on the Clash core. We do not provide any services for it, so please refrain from giving feedback on any issues not related to the application's own usage."
            //           .tr),
            // ),
            const Divider(
              thickness: 1.0,
            ),
            BrnAbnormalStateWidget(
              bgColor: Theme.of(context).primaryColor,
              // title: 'No profile, please add profiles.'.tr,
              content: "How to import profie".tr,
            ),
            const Divider(
              thickness: 1.0,
            ),
            // Text("Author:".trParams({"name": "Kingtous"})),
            Text(
              "afftips".tr,
              style: TextStyle(fontFamily: 'nssc'),
            ),
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      customLaunch(
                          Uri.parse("https://www.vultr.com/?ref=8992609-8H"));
                    },
                    child: Text(
                      "Vultr".tr,
                    )),
                TextButton(
                    onPressed: () {
                      customLaunch(
                          Uri.parse("https://app.cloudcone.com/?ref=10165"));
                    },
                    child: Text(
                      "CloudCone".tr,
                    )),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
