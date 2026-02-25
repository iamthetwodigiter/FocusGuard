import 'package:installed_apps/installed_apps.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/native_bridge/android_service_bridge.dart';
import '../../../services/logging_service.dart';
import '../models/app_info.dart';

/// Repository for managing app data
class AppRepository {
  final Box _blockedAppsBox;
  
  // Cache for installed apps to avoid repeated scans
  List<AppInfo>? _cachedInstalledApps;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  AppRepository(this._blockedAppsBox);

  /// Get all installed apps from device with caching
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final logger = LoggingService();
      // Use cache if available and fresh
      if (_cachedInstalledApps != null && _cacheTime != null) {
        if (DateTime.now().difference(_cacheTime!).inMinutes < _cacheDuration.inMinutes) {
          logger.log('📦 Using cached installed apps (${_cachedInstalledApps!.length} apps)');
          return _cachedInstalledApps!;
        }
      }

      logger.log('📦 Fetching installed apps from device...');
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true
      );

      final blockedPackages = getBlockedPackageNames();

      final appList = apps.map((app) {
        return AppInfo(
          packageName: app.packageName,
          appName: app.name,
          icon: app.icon,
          isBlocked: blockedPackages.contains(app.packageName),
        );
      }).where((app) => app.packageName.isNotEmpty).toList()
        ..sort((a, b) => a.appName.compareTo(b.appName));
      
      // Update cache
      _cachedInstalledApps = appList;
      _cacheTime = DateTime.now();
      
      return appList;
    } catch (e) {
      LoggingService().log('❌ Error fetching installed apps: $e');
      return [];
    }
  }

  /// Clear the apps cache (call when blocked apps change)
  void clearCache() {
    _cachedInstalledApps = null;
    _cacheTime = null;
  }

  /// Get list of blocked package names - FAST, no app scanning
  Set<String> getBlockedPackageNames() {
    final blocked = _blockedAppsBox.get(
      AppConstants.blockedAppsKey,
      defaultValue: <String>[],
    ) as List;
    return Set<String>.from(blocked);
  }

  /// Get blocked apps with full info
  Future<List<AppInfo>> getBlockedApps() async {
    final allApps = await getInstalledApps();
    return allApps.where((app) => app.isBlocked).toList();
  }

  /// Toggle block status for an app - FAST, doesn't reload all apps
  Future<void> toggleAppBlock(String packageName) async {
    final blockedPackages = getBlockedPackageNames();
    
    if (blockedPackages.contains(packageName)) {
      blockedPackages.remove(packageName);
    } else {
      blockedPackages.add(packageName);
    }

    await _saveBlockedApps(blockedPackages);
  }

  /// Block multiple apps at once
  Future<void> blockApps(List<String> packageNames) async {
    final blockedPackages = getBlockedPackageNames();
    blockedPackages.addAll(packageNames);
    await _saveBlockedApps(blockedPackages);
  }

  /// Unblock multiple apps at once
  Future<void> unblockApps(List<String> packageNames) async {
    final blockedPackages = getBlockedPackageNames();
    blockedPackages.removeAll(packageNames);
    await _saveBlockedApps(blockedPackages);
  }

  /// Clear all blocked apps
  Future<void> clearAllBlockedApps() async {
    await _saveBlockedApps({});
  }

  /// Save blocked apps and sync to native
  Future<void> _saveBlockedApps(Set<String> packageNames) async {
    await _blockedAppsBox.put(
      AppConstants.blockedAppsKey,
      packageNames.toList(),
    );

    // Clear cache since data changed
    clearCache();

    // Sync to SharedPreferences for native Android service
    await AndroidServiceBridge.syncBlockedApps(packageNames.toList());
  }
}
