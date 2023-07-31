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


bool isValidIPorDomain(String input) {
  final RegExp ipRegex =
  RegExp(r'^\b(?:\d{1,3}\.){3}\d{1,3}\b|\b(?:[\w-]+\.){1,}[\w-]{2,}\b$');
  return ipRegex.hasMatch(input);
}

String addHttpPrefixIfNeeded(String input) {
  const String httpPrefix = 'http://';
  const String httpsPrefix = 'https://';

  if (input.isEmpty) {
    return '';
  }

  if (!input.startsWith(httpPrefix) && !input.startsWith(httpsPrefix)) {
    return '$httpsPrefix$input';
  }

  return input;
}