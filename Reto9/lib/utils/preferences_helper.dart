import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const _radiusKey = 'search_radius_km';

  static Future<void> setRadius(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_radiusKey, radius);
  }

  static Future<double?> getRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_radiusKey);
  }
}
