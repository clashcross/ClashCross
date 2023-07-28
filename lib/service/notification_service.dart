import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kommon/kommon.dart';

class NotificationService extends GetxService {
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  var id = 0;

  Future<NotificationService> init() async {
    await notification.initialize(const InitializationSettings(
      linux: LinuxInitializationSettings(defaultActionName: 'act'),
      macOS: MacOSInitializationSettings(),
      // android: AndroidInitializationSettings("fclash"),
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));
    return this;
  }

  Future<void> showNotification(String title, String body) async {
    await notification.show(
        // id++,
        id,
        title,
        body,
        const NotificationDetails(
            linux: LinuxNotificationDetails(
                urgency: LinuxNotificationUrgency.normal),
            macOS: MacOSNotificationDetails(),
            android: AndroidNotificationDetails(
                "com.ClashCross.ClashCross", "ClashCross",
                playSound: false, enableVibration: false)));
  }

  Future<void> cancelAllNotification() async {
    await notification.cancelAll();
  }

  Future<void> cancelNotification(id) async {
    await notification.cancel(id);
  }
}
