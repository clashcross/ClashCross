import 'package:url_launcher/url_launcher.dart';

void customLaunch(command) async {
  if (await canLaunchUrl(command)) {
    await launchUrl(
      command,
      mode: LaunchMode.externalApplication,
    );
  } else {
    print('cant launch');
  }
}
