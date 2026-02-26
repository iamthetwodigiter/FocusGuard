import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusguard/core/constants/app_constants.dart';
import 'package:focusguard/services/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bridge between Flutter and Native Android Service [AccessibilityService]
class AndroidServiceBridge {
  static const MethodChannel _channel = MethodChannel('app.focusguard/service');

  /// Save blocked apps list to SharedPreferences for native access
  static Future<void> syncBlockedApps(List<String> packageNames) async {
    final logger = LoggingService();
    logger.log(
      '🔄 syncBlockedApps CALLED - Syncing ${packageNames.length} apps',
    );
    logger.log('   Apps: $packageNames');

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(packageNames);

    logger.log('   JSON: $jsonString');

    await prefs.setString(AppConstants.nativeBlockedAppsKey, jsonString);
    logger.log(
      '   📍 Saved to SharedPrefs with key: ${AppConstants.nativeBlockedAppsKey}',
    );

    // Verify
    await prefs.reload();
    final saved = prefs.getString(AppConstants.nativeBlockedAppsKey);
    logger.log('   ✅ Verification - read back: $saved');
  }

  /// Save blocked browsers list to SharedPreferences for native access
  static Future<void> syncBlockedBrowsers(List<String> browserPackages) async {
    final logger = LoggingService();
    logger.log(
      '🌐 syncBlockedBrowsers - Syncing ${browserPackages.length} browsers',
    );
    logger.log('   Browsers: $browserPackages');

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(browserPackages);

    await prefs.setString(AppConstants.nativeBlockedBrowsersKey, jsonString);

    // Verify
    await prefs.reload();
    final saved = prefs.getString(AppConstants.nativeBlockedBrowsersKey);
    logger.log('   ✅ Verification - read back: $saved');
  }

  /// Save blocked website URLs list to SharedPreferences for native access
  static Future<void> syncBlockedWebsites(List<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(urls);
    await prefs.setString(AppConstants.nativeBlockedWebsitesKey, jsonString);
  }

  /// Start the accessibility service
  static Future<bool> startAccessibilityService() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if accessibility service is enabled
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open accessibility settings
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Check if app can draw overlays
  static Future<bool> canDrawOverlays() async {
    try {
      final result = await _channel.invokeMethod<bool>('canDrawOverlays');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Activate focus session
  static Future<void> activateFocusSession(bool active) async {
    final logger = LoggingService();
    logger.log('🔧 activateFocusSession($active) - Setting session state...');

    final prefs = await SharedPreferences.getInstance();

    // Reload to ensure fresh data
    await prefs.reload();

    final result = await prefs.setBool(
      AppConstants.nativeSessionActiveKey,
      active,
    );
    logger.log(
      '🔧 setBool("${AppConstants.nativeSessionActiveKey}", $active) = $result',
    );

    // Verify it was saved
    await prefs.reload();
    final saved = prefs.getBool(AppConstants.nativeSessionActiveKey);
    logger.log('✅ Verified - Session state: $saved');

    // Check all keys
    final allKeys = prefs.getKeys();
    logger.log('📋 All SharedPrefs keys: $allKeys');

    // Debug logging
    logger.log('🎯 Focus session ${active ? "🟢 STARTED" : "🔴 STOPPED"}');

    // Also log what's currently in SharedPreferences
    final blockedApps = prefs.getString(AppConstants.nativeBlockedAppsKey);
    logger.log('📱 Blocked apps in SharedPrefs: $blockedApps');
  }

  /// Debug: Get current state from SharedPreferences
  static Future<Map<String, dynamic>> getDebugState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'blocked_apps':
          prefs.getString(AppConstants.nativeBlockedAppsKey) ?? '[]',
      'session_active':
          prefs.getBool(AppConstants.nativeSessionActiveKey) ?? false,
    };
  }

  /// Retrieve service logs from accessibility service
  static Future<List<String>> getServiceLogs() async {
    try {
      final logs = await _channel.invokeMethod<List<dynamic>>('getLogs');
      return logs?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('Error getting service logs: $e');
      return ['Error: $e'];
    }
  }

  /// Send a log message to the native service
  static Future<void> logToService(String message) async {
    try {
      await _channel.invokeMethod<void>('addLog', {'message': message});
    } catch (e) {
      debugPrint('Error sending log to service: $e');
    }
  }

  /// Enable/disable screenshot blocking
  static Future<void> setScreenshotBlocking(bool enabled) async {
    try {
      await _channel.invokeMethod('setScreenshotBlocking', {
        'enabled': enabled,
      });
    } catch (e) {
      debugPrint('Error setting screenshot blocking: $e');
    }
  }

  /// Completely exit the app and stop services
  static Future<void> exitApp() async {
    try {
      await _channel.invokeMethod('exitApp');
    } catch (e) {
      debugPrint('Error exiting app: $e');
    }
  }
}
