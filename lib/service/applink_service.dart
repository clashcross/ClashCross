import 'package:app_links/app_links.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kommon/kommon.dart';

import 'clash_service.dart';

class ApplinkService extends GetxService {
  final _appLinks = AppLinks();
  late var _linkSubscription;

  Future<ApplinkService> init() async {
    initapplinkService();
    return this;
  }

  initapplinkService() async {
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      importProfile(uri);
    }
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      importProfile(uri);
    });

  }

  importProfile(Uri uri){
    if (uri.queryParameters["url"] != null) {
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
                await Get.find<ClashService>()
                    .addProfile(name, uri.queryParameters["url"]!);
              } finally {
                BrnLoadingDialog.dismiss(Get.context!);
              }
            });
          });
    } else {
      EasyLoading.showError("请导入有效的clash订阅链接");
    }
  }
}
