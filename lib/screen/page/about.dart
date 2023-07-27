import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

import '../../service/clash_service.dart';
import '../../tools/customlaunch.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Get.find<ClashService>();
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Text('About'.tr),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          // color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: CircleAvatar(
                  foregroundImage: AssetImage("assets/images/multiclash.png"),
                  radius: 100,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.warning),
                title: Text(
                    "ClashCross is a proxy debugging application built on the Clash core. We do not provide any services for it, so please refrain from giving feedback on any issues not related to the application's own usage."
                        .tr),
              ),
              const Divider(
                thickness: 1.0,
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(
                    "Your interactions and logs are kept and displayed only on your device. We do not collect, transmit, or share any of this content."
                            .tr),
              ),
              const Divider(
                thickness: 1.0,
              ),

              // TextButton(
              //   onPressed: () {},
              //   child: Text(
              //     "一款本地代理调试应用 ".tr,
              //     style: const TextStyle(fontSize: 20,color: Colors.black),
              //   ),
              // ),
              Text(
                "version:".trParams({"version": cs.app_version}),
                style: const TextStyle(fontFamily: 'nssc'),
              ),

              const Divider(
                thickness: 1.0,
              ),
              // Text("Author:".trParams({"name": "Kingtous"})),
              Text(
                "Thanks For:".tr,
                style: TextStyle(fontFamily: 'nssc'),
              ),
              Wrap(
                children: [
                  TextButton(
                      onPressed: () {
                        customLaunch(
                            Uri.parse("https://github.com/Dreamacro/clash"));
                      },
                      child: Text(
                        "Clash".tr,
                      )),
                  TextButton(
                      onPressed: () {
                        customLaunch(
                            Uri.parse("https://github.com/flutter/flutter"));
                      },
                      child: Text(
                        "Flutter".tr,
                      )),
                  TextButton(
                      onPressed: () {
                        customLaunch(
                            Uri.parse("https://github.com/Fclash/Fclash"));
                      },
                      child: Text(
                        "fclash".tr,
                      )),
                  TextButton(
                      onPressed: () {
                        customLaunch(
                            Uri.parse("https://fonts.google.com/icons"));
                      },
                      child: Text(
                        "Material Icons".tr,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
