import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kommon/kommon.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../main.dart';
import '../../model/themeCollection.dart';
import '../../service/clash_service.dart';
import '../../tools/customlaunch.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    isDarkTheme = Provider.of<ThemeCollection>(context).isDarkActive;
    return Scaffold(
      body: Column(
        children: [
          // Obx(() => BrnNoticeBar(
          //     content: 'Current using'.trParams(
          //         {"name": Get.find<ClashService>().currentYaml.value}))),
          Expanded(child: Obx(() => buildProfileList(context)))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "add a subcription link.".tr,
        onPressed: () {
          _addProfile(context);
        },
        child: const Icon(Icons.add),
      ),
      persistentFooterButtons: isDesktop
          ? [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final dir = await getApplicationSupportDirectory();
                      if (Platform.isWindows) {
                        launchUrlString("file://${join(dir.path, "clashCross")}");
                      } else {
                        launchUrl(
                            Uri.parse("file://${join(dir.path, "clashCross")}"));
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open_outlined),
                        Text(
                          "Open config folder".tr,
                          style: Theme.of(context).primaryTextTheme.bodyLarge,
                        )
                      ],
                    ),
                  ),
                ],
              )
            ]
          : null,
    );
  }

  Widget buildProfileList(context) {
    final configs = Get.find<ClashService>().yamlConfigs;
    final configsList = configs.toList(growable: false);
    if (configs.isEmpty) {
      return Container(
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
              style: const TextStyle(fontFamily: 'nssc'),
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
      );
    } else {
      return ListView.builder(
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final filename = basename(configsList[index].path);
          final key = basenameWithoutExtension(configsList[index].path);
          final link = Get.find<ClashService>().getSubscriptionLinkByYaml(key);
          return InkWell(
            onTap: () => handleProfileClicked(configsList[index],
                Get.find<ClashService>().currentYaml.value == filename),
            child: Container(
              // height: kToolbarHeight,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkTheme
                    ? const Color(0xff181227)
                    : const Color(0xffF5F5F6),
                // gradient: LinearGradient(
                //   colors: Get.find<ClashService>().currentYaml.value ==
                //           filename
                //       ? [const Color(0xff6622CC), const Color(0xff6622CC)]
                //       : [Colors.grey, Colors.grey],
                //   // transform: GradientRotation(5),
                // ),
              ),
              // padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListTile(
                  selectedColor: Colors.red,
                  selected:
                      Get.find<ClashService>().currentYaml.value == filename,
                  leading: Container(
                    width: 50,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        !(Get.find<ClashService>().currentYaml.value ==
                                filename)
                            ? Image.asset(
                                "assets/images/rocket.png",
                                color: Colors.grey,
                                width: 50,
                              )
                            : Container(),
                        Get.find<ClashService>().currentYaml.value == filename
                            ? const Icon(
                                Icons.check_circle_outline,
                                size: 50,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    basename(configsList[index].path),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).primaryTextTheme.headline6,
                  ),
                  subtitle: link.isEmpty
                      ? const Offstage()
                      : Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  EasyLoading.show(status: 'Updating'.tr);
                                  // BrnToast.show('Updating'.tr, context,
                                  //     textStyle: Theme.of(context)
                                  //         .primaryTextTheme
                                  //         .bodyMedium!);
                                  try {
                                    final res = await Get.find<ClashService>()
                                        .updateSubscription(key);
                                    if (res) {
                                      EasyLoading.showSuccess(
                                          'Update and apply settings success!'
                                              .tr);
                                      // BrnToast.show(
                                      //     'Update and apply settings success!'
                                      //         .tr,
                                      //     context,
                                      //     textStyle: Theme.of(context)
                                      //         .primaryTextTheme
                                      //         .bodyMedium!);
                                    } else {
                                      EasyLoading.showError(
                                          'Update failed, please retry!'.tr);
                                      // BrnToast.show(
                                      //     'Update failed, please retry!'
                                      //         .tr,
                                      //     context,
                                      //     textStyle: Theme.of(context)
                                      //         .primaryTextTheme
                                      //         .bodyMedium!);
                                    }
                                  } catch (e) {
                                    EasyLoading.dismiss();
                                    // BrnToast.show(e.toString(), context,
                                    //     textStyle: Theme.of(context)
                                    //         .primaryTextTheme
                                    //         .caption!);
                                  }
                                },
                                child: Tooltip(
                                    message: link,
                                    child: Text(
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium,
                                        "update subscription".tr))),
                            TextButton(
                                onPressed: () async {
                                  FlutterClipboard.copy(link).then((value) {
                                    // BrnToast.show('Success'.tr, context);
                                    EasyLoading.showSuccess('Success'.tr);
                                  });
                                },
                                child: Tooltip(
                                    message: link,
                                    child: Text(
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium,
                                        "Copy link".tr))),
                            // TextButton(
                            //     onPressed: () async {
                            //       BrnToast.show('Updating'.tr, context);
                            //       try {
                            //         final res =
                            //             await Get.find<ClashService>()
                            //                 .updateSubscription(key);
                            //         if (res) {
                            //           BrnToast.show(
                            //               'Update and apply settings success!'
                            //                   .tr,
                            //               context);
                            //         } else {
                            //           BrnToast.show(
                            //               'Update failed, please retry!'
                            //                   .tr,
                            //               context);
                            //         }
                            //       } catch (e) {
                            //         BrnToast.show(
                            //             e.toString(), context);
                            //       }
                            //     },
                            //     child: Tooltip(
                            //         message: link,
                            //         child: Text(
                            //             "Set update interval".tr))),
                          ],
                        )),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     // Image.asset(
              //     //   "assets/images/rocket.png.bak",
              //     //   width: 50,
              //     // ),
              //     Expanded(
              //         child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           style: Theme.of(context)
              //               .primaryTextTheme
              //               .headline6!
              //               .copyWith(color: Colors.white),
              //           basename(
              //             configsList[index].path,
              //           ),
              //           // style: TextStyle(fontSize: 24),
              //         ),
              //         link.isEmpty
              //             ? Offstage()
              //             : Row(
              //                 children: [
              //                   TextButton(
              //                       onPressed: () async {
              //                         BrnToast.show('Updating'.tr, context);
              //                         try {
              //                           final res =
              //                               await Get.find<ClashService>()
              //                                   .updateSubscription(key);
              //                           if (res) {
              //                             BrnToast.show(
              //                                 'Update and apply settings success!'
              //                                     .tr
              //                                     .tr,
              //                                 context);
              //                           } else {
              //                             BrnToast.show(
              //                                 'Update failed, please retry!'
              //                                     .tr
              //                                     .tr,
              //                                 context);
              //                           }
              //                         } catch (e) {
              //                           BrnToast.show(
              //                               e.toString(), context);
              //                         }
              //                       },
              //                       child: Tooltip(
              //                           message: link,
              //                           child: Text(
              //                               style: Theme.of(context)
              //                                   .primaryTextTheme
              //                                   .bodyMedium!
              //                                   .copyWith(
              //                                       color: Colors.white),
              //                               "update subscription".tr))),
              //                   TextButton(
              //                       onPressed: () async {
              //                         FlutterClipboard.copy(link)
              //                             .then((value) {
              //                           BrnToast.show(
              //                               'Success'.tr, context);
              //                         });
              //                       },
              //                       child: Tooltip(
              //                           message: link,
              //                           child: Text(
              //                               style: Theme.of(context)
              //                                   .primaryTextTheme
              //                                   .bodyMedium!
              //                                   .copyWith(
              //                                       color: Colors.white),
              //                               "Copy link".tr))),
              //                   // TextButton(
              //                   //     onPressed: () async {
              //                   //       BrnToast.show('Updating'.tr, context);
              //                   //       try {
              //                   //         final res =
              //                   //             await Get.find<ClashService>()
              //                   //                 .updateSubscription(key);
              //                   //         if (res) {
              //                   //           BrnToast.show(
              //                   //               'Update and apply settings success!'
              //                   //                   .tr,
              //                   //               context);
              //                   //         } else {
              //                   //           BrnToast.show(
              //                   //               'Update failed, please retry!'
              //                   //                   .tr,
              //                   //               context);
              //                   //         }
              //                   //       } catch (e) {
              //                   //         BrnToast.show(
              //                   //             e.toString(), context);
              //                   //       }
              //                   //     },
              //                   //     child: Tooltip(
              //                   //         message: link,
              //                   //         child: Text(
              //                   //             "Set update interval".tr))),
              //                 ],
              //               )
              //       ],
              //     )),
              //     const Icon(Icons.keyboard_arrow_right)
              //   ],
              // )),
            ),
          );
        },
      );
    }
  }

  void _addProfile(BuildContext context) {
    Get.find<DialogService>().inputDialog(
        title: "Input a valid subscription link url".tr,
        onText: (txt) async {
          Future.delayed(Duration.zero, () {
            Get.find<DialogService>().inputDialog(
                title: "What is your config name".tr,
                onText: (name) async {
                  if (name == "config") {
                    EasyLoading.showError("Cannot use this special name".tr);
                    // BrnToast.show("Cannot use this special name".tr, context);
                  }
                  Future.delayed(Duration.zero, () async {
                    try {
                      BrnLoadingDialog.show(Get.context!,
                          content: '', barrierDismissible: false);
                      await Get.find<ClashService>().addProfile(name, txt);
                    } finally {
                      BrnLoadingDialog.dismiss(Get.context!);
                    }
                  });
                });
          });
        });
  }

  handleProfileClicked(FileSystemEntity config, bool isInUse) {
    Get.bottomSheet(BrnCommonActionSheet(
      title: basename(config.path),
      actions: [
        BrnCommonActionSheetItem('set to default profile'.tr,
            desc: isInUse
                ? "already default profile".tr
                : "switch to this profile".tr),
        BrnCommonActionSheetItem('DELETE'.tr,
            desc: "delete this profile".tr,
            actionStyle: BrnCommonActionSheetItemStyle.alert),
      ],
      cancelTitle: 'Cancel'.tr,
      onItemClickInterceptor: (index, a) {
        switch (index) {
          case 0:
            // if (!isInUse) {
            Get.find<ClashService>().changeYaml(config).then((value) {
              if (value) {
                Get.snackbar("Success".tr, "update yaml config success!".tr,
                    snackPosition: SnackPosition.BOTTOM);
              } else {
                Get.snackbar("Failed".tr,
                    "update yaml config failed! Please check yaml file.".tr,
                    snackPosition: SnackPosition.BOTTOM);
              }
            });
            // }
            break;
          case 1:
            if (isInUse) {
              Future.delayed(Duration.zero, () {
                Get.dialog(BrnDialog(
                  titleText: "You can't delete a profile which is in use!".tr,
                  contentWidget: Center(
                      child:
                          Text('Please switch to another profile first.'.tr)),
                  actionsText: ["OK"],
                ));
              });
            } else {
              if (getFileNameFromFileSystemEntity(config) != "config.yaml") {
                Get.find<ClashService>().deleteProfile(config);
              } else {
                EasyLoading.showError(
                    "You can't delete a profile named config.yaml!".tr);
              }
            }
            break;
        }
        return false;
      },
    ));
  }

  // 直接从 FileSystemEntity 获取文件名
  String getFileNameFromFileSystemEntity(FileSystemEntity entity) {
    return entity.path.split('/').last;
  }
}
