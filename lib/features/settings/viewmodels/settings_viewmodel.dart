import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusguard/services/native_bridge/android_service_bridge.dart';

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  SettingsNotifier()
      : super({
          'notificationEnabled': true,
          'soundEnabled': true,
          'vibrationEnabled': true,
          'systemAppShield': true,
          'allowScreenshots': false,
          'theme': 'system',
        }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = {
      'notificationEnabled': prefs.getBool('notificationEnabled') ?? true,
      'soundEnabled': prefs.getBool('soundEnabled') ?? true,
      'vibrationEnabled': prefs.getBool('vibrationEnabled') ?? true,
      'systemAppShield': prefs.getBool('systemAppShield') ?? true,
      'allowScreenshots': prefs.getBool('allowScreenshots') ?? false,
      'theme': prefs.getString('theme') ?? 'system',
    };
    state = newState;
    
    // Apply initial screenshot blocking
    if (newState['allowScreenshots'] == false) {
       AndroidServiceBridge.setScreenshotBlocking(true);
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }

    if (key == 'allowScreenshots') {
      // Invert because 'allowScreenshots' true means blocking should be false
      await AndroidServiceBridge.setScreenshotBlocking(!value);
    }
  }

  Future<void> resetToDefaults() async {
    final defaults = {
      'notificationEnabled': true,
      'soundEnabled': true,
      'vibrationEnabled': true,
      'systemAppShield': true,
      'allowScreenshots': false,
      'theme': 'system',
    };
    state = defaults;
    
    final prefs = await SharedPreferences.getInstance();
    for (var entry in defaults.entries) {
      if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value as bool);
      } else if (entry.value is String) {
        await prefs.setString(entry.key, entry.value as String);
      }
    }
    
    // Reset blocking to active by default
    await AndroidServiceBridge.setScreenshotBlocking(true);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});
