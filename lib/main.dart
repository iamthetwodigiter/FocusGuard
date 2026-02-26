import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/app/app.dart';
import 'package:focusguard/core/constants/app_constants.dart';
import 'package:focusguard/features/achievements/models/achievement.dart';
import 'package:focusguard/features/achievements/repositories/achievements_repository.dart';
import 'package:focusguard/features/session_history/models/focus_session.dart';
import 'package:focusguard/features/statistics/models/blocked_app_stat.dart';
import 'package:focusguard/features/website_blocking/models/website_info.dart';
import 'package:focusguard/services/native_bridge/android_service_bridge.dart';
import 'package:focusguard/services/storage/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register Hive TypeAdapters before initializing HiveService
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(BlockedAppStatAdapter());
  Hive.registerAdapter(WebsiteInfoAdapter());
  
  await HiveService.init();
  
  // Initialize repositories
  final achievementsRepo = AchievementsRepository();
  
  await achievementsRepo.init();

  // Sync existing data to native on app start
  await _syncDataToNative();

  runApp(ProviderScope(child: const FocusGuardApp()));
  Permission.notification.request();
}


/// Sync all app data from Hive to SharedPreferences for native service
Future<void> _syncDataToNative() async {
  try {
    debugPrint('🔄 STARTUP SYNC - Syncing Hive data to SharedPreferences...');
    
    // Get blocked apps from Hive
    final appsBox = HiveService.getBox(AppConstants.blockedAppsBox);
    final blockedApps = appsBox.get(
      AppConstants.blockedAppsKey,
      defaultValue: <String>[],
    ) as List;
    final blockedAppsList = List<String>.from(blockedApps);
    
    debugPrint('   Found ${blockedAppsList.length} blocked apps in Hive: $blockedAppsList');
    
    // Sync to native
    await AndroidServiceBridge.syncBlockedApps(blockedAppsList);
    
    // Get blocked websites and sync browsers
    try {
      final websitesBox = Hive.box<WebsiteInfo>(AppConstants.websitesBox);
      
      final hasWebsites = websitesBox.isNotEmpty;
      
      if (hasWebsites) {
        debugPrint('   Found websites in blocklist, syncing browsers...');
        // Browser packages list
        final browsers = [
          'com.android.chrome',              // Chrome
          'org.mozilla.firefox',             // Firefox
          'com.opera.browser',               // Opera
          'com.opera.mini.native',           // Opera Mini
          'com.microsoft.emmx',              // Edge
          'com.brave.browser',               // Brave
          'com.duckduckgo.mobile.android',   // DuckDuckGo
          'org.chromium.chrome',             // Chromium
          'com.UCMobile.intl',               // UC Browser
          'com.kiwibrowser.browser',         // Kiwi Browser
          'com.vivaldi.browser',             // Vivaldi
          'com.samsung.android.app.sbrowser',// Samsung Internet
          'com.sec.android.app.sbrowser',    // Samsung Internet (alternative)
          'mark.via.gp',                     // Via Browser
          'com.yandex.browser',              // Yandex Browser
          'com.android.browser',             // AOSP Browser
        ];
        await AndroidServiceBridge.syncBlockedBrowsers(browsers);
      }
    } catch (e) {
      debugPrint('⚠️ Could not sync websites: $e');
    }
    
    debugPrint('✅ STARTUP SYNC - Complete!');
  } catch (e) {
    debugPrint('❌ Error during startup sync: $e');
  }
}
