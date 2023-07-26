import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class WindowsPanel extends StatelessWidget {
  const WindowsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Ink(
            child: InkWell(
                onTap: () {
                  windowManager.minimize();
                },
                child: const Icon(Icons.minimize).paddingAll(8.0))),
        Ink(
            child: InkWell(
                onTap: () async {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                },
                child: const Icon(Icons.rectangle_outlined).paddingAll(8.0))),
        Ink(
            child: InkWell(
                onTap: () {
                  windowManager.hide();
                },
                child: const Icon(Icons.close).paddingAll(8.0))),
      ],
    );
  }
}
