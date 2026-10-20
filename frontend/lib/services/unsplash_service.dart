import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_keys.dart';

class UnsplashService {
  static const _baseUrl = 'https://api.unsplash.com/search/photos';


  Future<String?> fetchImageUrl(String query) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'query': query,
      'per_page': '1',
      'orientation': 'landscape',
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Client-ID ${ApiKeys.unsplashAccessKey}',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      final urls = results.first['urls'] as Map<String, dynamic>;
      return urls['regular'] as String?;
    } catch (_) {
      return null; 
    }
  }
}