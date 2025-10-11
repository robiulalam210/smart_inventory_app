import 'package:flutter_dotenv/flutter_dotenv.dart';
final bool isLive = false; // Set to true for production environment

class AppUrls {



  static String versionUrl = dotenv.env['VERSION_URL']!;
  static String currentVersion = dotenv.env['CURRENT_VERSION']!;
  static String fileUrl = dotenv.env['FILE_URL']!;
  static String? baseUrlMain =
      isLive ? dotenv.env['BASE_URL'] : dotenv.env['TEST_BASE_URL'];

  static final String baseUrl = "$baseUrlMain/api"; //!Server url

  static final String login          = '$baseUrl/login-with-saas';
  static final String patient          = '$baseUrl/user/bloc/change-password';
  static final String saveInvoice          = '$baseUrl/great-lab-save-invoice';
  static final String setUpData          = '$baseUrl/lab-offline/setup-data';
  static final String syncInvoice          = '$baseUrl/lab-offline/sync/invoice';
  static final String fullInvoiceRefund          = '$baseUrl/great-lab-invoice-full-refund/';
  static final String getInvoice          = '$baseUrl/lab-offline/invoice';



  //!for App update link
  static const String playStoreLink= '';
  static const String appStoreLink = '';
}
