import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/city.dart';

class OpenMeteoGeocodingApi {
  final http.Client _client;

  OpenMeteoGeocodingApi(this._client);

  Future<List<City>> searchCities(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': q,
        'count': '10',
        'language': 'pt',
        'format': 'json',
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Geocoding falhou: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? const [];

    return results
        .cast<Map<String, dynamic>>()
        .map(City.fromJson)
        .toList(growable: false);
  }
}
