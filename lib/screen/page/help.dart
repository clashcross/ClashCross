import 'package:clashcross/service/corpus_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kommon/kommon.dart';

import '../../tools/customlaunch.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final corpusService = Get.find<CorpusService>();
    List<Widget> children = [];
    if (corpusService.corpusList.isNotEmpty) {
      for (var element in corpusService.corpusList) {
        children.add(
          TextButton(
              onPressed: () {
                var url = addHttpPrefixIfNeeded(element.siteurl);
                customLaunch(Uri.parse(url));
              },
              child: Text(element.sitename)),
        );
      }
    }
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
            ListTile(
              leading: TextButton(
                onPressed: () {
                  customLaunch(Uri.parse(
                      "https://github.com/shipinbaoku/clashcross#url_scheme"));
                },
                child: const Icon(Icons.escalator_warning),
              ),
              title: Text('Importable ClashCross Websites'.tr),
              subtitle: Text(
                  "The listed URLs below are only representative of subscriptions that can be imported into ClashCross. ClashCross has no affiliation with them, please use your own discretion.".tr),
              // title: TextButton(
              //   onPressed: () {
              //     customLaunch(
              //         Uri.parse("https://github.com/shipinbaoku/clashcross#url_scheme"));
              //   },
              //   child: Text(
              //       "Url_scheme:Our application allows third parties to import Clash subscriptions using the url_scheme method"
              //           .tr),
              // ),
            ),
            Wrap(
              children: children,
            )
          ],
        ),
      )),
    );
  }
}
