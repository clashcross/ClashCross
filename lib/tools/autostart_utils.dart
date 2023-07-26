import 'package:launch_at_startup/launch_at_startup.dart';

class AutostartUtils {
  static Future<bool> isEnabled() {
    return launchAtStartup.isEnabled();
  }

  static Future<bool> disable() {
    return launchAtStartup.disable();
  }

  static Future<bool> enable() {
    return launchAtStartup.enable();
  }
}
