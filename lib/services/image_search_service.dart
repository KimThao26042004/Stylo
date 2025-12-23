import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/similar_product.dart';

class ImageSearchService {
  static const String baseUrl = "http://10.0.2.2:8000";
  // ⚠ Android emulator: 10.0.2.2
  // iOS simulator: localhost
  // Device thật: IP máy tính

  static Future<List<SimilarProduct>> searchByImage(
      File imageFile, {
        int k = 10,
      }) async {
    final uri = Uri.parse("$baseUrl/search-by-image?k=$k");

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Search image failed");
    }

    final jsonData = json.decode(body);
    final List list = jsonData['products'];

    return list.map((e) => SimilarProduct.fromJson(e)).toList();
  }
}
