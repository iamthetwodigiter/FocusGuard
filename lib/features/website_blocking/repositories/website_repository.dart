import 'package:flutter/foundation.dart';
import 'package:focusguard/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/website_info.dart';
import '../../../services/native_bridge/android_service_bridge.dart';

class WebsiteRepository {
  static const List<String> _browserPackages = [
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
    'com.samsung.android.app.sbrowser', // Samsung Internet
    'com.sec.android.app.sbrowser',    // Samsung Internet (alternative)
    'mark.via.gp',                     // Via Browser
    'com.yandex.browser',              // Yandex Browser
    'org.mozilla.fennec_fdroid',       // Firefox (F-Droid)
    'com.opera.touch',                 // Opera Touch
    'com.qwant.liberty',               // Qwant
    'org.mozilla.focus',               // Firefox Focus
    'org.torproject.torbrowser',       // Tor Browser
    'com.ecosia.android',              // Ecosia
    'com.ghostery.android.ghostery',   // Ghostery Browser
    'com.android.browser',             // AOSP Browser
  ];

  Box<WebsiteInfo> _getBox() {
    return Hive.box<WebsiteInfo>(AppConstants.websitesBox);
  }

  Future<List<WebsiteInfo>> getBlockedWebsites() async {
    final box = _getBox();
    return box.values.where((w) => w.isBlocked).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<List<WebsiteInfo>> getAllWebsites() async {
    final box = _getBox();
    return box.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<void> addWebsite(String url) async {
    final box = _getBox();
    
    // Normalize URL
    String normalizedUrl = url.trim().toLowerCase();
    if (!normalizedUrl.contains('://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    // Check if already exists
    final existing = box.values.firstWhere(
      (w) => w.url == normalizedUrl,
      orElse: () => WebsiteInfo(url: '', isBlocked: false),
    );

    if (existing.url.isEmpty) {
      final website = WebsiteInfo(url: normalizedUrl, isBlocked: true);
      await box.add(website);
      debugPrint('✅ Added website: $normalizedUrl');
    } else {
      debugPrint('⚠️ Website already exists: $normalizedUrl');
    }

    await _syncToNative();
  }

  Future<void> toggleWebsiteBlock(String url) async {
    final box = _getBox();
    
    for (var i = 0; i < box.length; i++) {
      final website = box.getAt(i);
      if (website?.url == url) {
        final updated = website!.copyWith(isBlocked: !website.isBlocked);
        await box.putAt(i, updated);
        debugPrint('🔄 Toggled website: $url -> blocked: ${updated.isBlocked}');
        break;
      }
    }

    await _syncToNative();
  }

  Future<void> removeWebsite(String url) async {
    final box = _getBox();
    
    for (var i = 0; i < box.length; i++) {
      final website = box.getAt(i);
      if (website?.url == url) {
        await box.deleteAt(i);
        debugPrint('🗑️ Removed website: $url');
        break;
      }
    }

    await _syncToNative();
  }

  Future<void> clearAll() async {
    final box = _getBox();
    await box.clear();
    debugPrint('🗑️ Cleared all websites');
    await _syncToNative();
  }

  // Sync browser blocking to native service
  Future<void> _syncToNative() async {
    final blockedWebsites = await getBlockedWebsites();
    
    // If any websites are blocked, block all browsers
    final List<String> browsersToBlock = blockedWebsites.isNotEmpty 
        ? _browserPackages 
        : [];

    debugPrint('📡 Syncing browsers to native service...');
    debugPrint('   Blocked websites: ${blockedWebsites.length}');
    debugPrint('   Browsers to block: ${browsersToBlock.length}');
    debugPrint('   Browser list: $browsersToBlock');
    
    await AndroidServiceBridge.syncBlockedBrowsers(browsersToBlock);
    
    // Sync actual URLs for selective blocking
    final List<String> urls = blockedWebsites.map((w) => w.url).toList();
    await AndroidServiceBridge.syncBlockedWebsites(urls);
    
    debugPrint('✅ Browser and URL sync complete');
  }

  static List<String> get browserPackages => _browserPackages;
}
