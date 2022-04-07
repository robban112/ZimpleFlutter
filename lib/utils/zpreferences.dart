import 'package:shared_preferences/shared_preferences.dart';

enum Keys {
  cachedImages,
  themeMode,
  calendarFilteredPersons,
  calendarIsShowingWeekend,
  hasSeenOnboarding,
}

class ZPreferences {
  static Future<void> saveData<T>(Keys key, T value) async {
    print("$key, Saving data: $value");
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key.name, value);
    } else if (value is String) {
      await prefs.setString(key.name, value);
    } else if (value is bool) {
      await prefs.setBool(key.name, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key.name, value);
    } else {
      print("Invalid Type");
    }
  }

  static Future<void> saveCachedImages(List<String> values) async {
    print("Updating ZPreferences Cached Images: $values");
    return saveData(Keys.cachedImages, values);
  }

  static Future<List<String>?> getStringList(Keys key) async {
    try {
      dynamic data = await readData(key);
      print("data: $data");
      if (data is List) {
        return data.whereType<String>().toList();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<List<String>?> getCachedImages() async {
    return getStringList(Keys.cachedImages);
  }

  static Future<T?> readData<T>(Keys key) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic obj = prefs.get(key.name) as T;
      return obj;
    } catch (error) {
      return null;
    }
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
