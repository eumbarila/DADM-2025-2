import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  static final String _apiKey = dotenv.env['API_KEY'] ?? '';

  static Future<List<Map<String, dynamic>>> getNearbyPlaces(
      double lat, double lng, double radiusKm) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=${(radiusKm * 1000).toInt()}&type=point_of_interest&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return (data['results'] as List)
          .map((item) => {
        'place_id': item['place_id'],
        'name': item['name'],
        'lat': item['geometry']['location']['lat'],
        'lng': item['geometry']['location']['lng'],
      })
          .toList();
    }
    return [];
  }
}
