import 'package:url_launcher/url_launcher.dart';


Future<void> appLaunchUrl(
    {required String scheme, required String path}) async {
  final url = Uri(scheme: scheme, path: path);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}