import 'dart:typed_data';
import 'package:http/http.dart'as http;
import '../configs/app_urls.dart';


Future<Uint8List> loadImageBytes(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    // Return empty bytes for placeholder
    return Uint8List(0);
  }

  try {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${AppUrls.baseUrlMain}$imageUrl';

    print(fullUrl);
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading image: $e');
    return Uint8List(0);
  }
}
