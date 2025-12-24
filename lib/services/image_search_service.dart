import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/similar_product.dart';

class ImageSearchService {

  static String get apiBaseUrl {
    if (kIsWeb) {
      return "http://localhost:5248/api/Product";
    } else {
      return "http://10.0.2.2:5248/api/Product";
    }
  }

  static String get imageBaseUrl {
    if (kIsWeb) {
      return "http://localhost:5248";
    } else {
      return "http://10.0.2.2:5248";
    }
  }

  /// Search product by image
  static Future<List<SimilarProduct>> searchByImage(
      dynamic image, {
        int k = 10,
      }) async {
    final uri = Uri.parse("$apiBaseUrl/search-by-image?k=$k");

    final request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(body);
    }

    final List list = json.decode(body);
    return list.map((e) => SimilarProduct.fromJson(e)).toList();
  }
}
