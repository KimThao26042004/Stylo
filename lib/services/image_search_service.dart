import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/similar_product.dart';

class ImageSearchService {

  /// Base URL theo platform
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web (browser)
      return "http://localhost:5248/api/Product";
    } else {
      // Android Emulator
      return "http://10.0.2.2:5248/api/Product";

      // Nếu chạy trên device thật (cùng LAN)
      // return "http://192.168.1.10:5248/api/Product";
    }
  }

  /// Search product by image
  static Future<List<SimilarProduct>> searchByImage(
      dynamic image, {
        int k = 10,
      }) async {
    final uri = Uri.parse("$baseUrl/search-by-image?k=$k");

    final request = http.MultipartRequest('POST', uri);

    // --------- UPLOAD FILE ----------
    if (kIsWeb) {
      // Flutter Web: dùng bytes
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name,
        ),
      );
    } else {
      // Mobile / Emulator: dùng path
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );
    }

    // --------- SEND REQUEST ----------
    final response = await request.send();
    final body = await response.stream.bytesToString();

    debugPrint(" IMAGE SEARCH STATUS: ${response.statusCode}");
    debugPrint(" IMAGE SEARCH BODY: $body");

    if (response.statusCode != 200) {
      throw Exception("Search by image failed: $body");
    }

    // --------- PARSE RESPONSE ----------
    final List list = json.decode(body);
    return list
        .map((e) => SimilarProduct.fromJson(e))
        .toList();
  }
}
