import 'package:focusguard/features/statistics/models/blocked_app_stat.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusguard/core/constants/app_constants.dart';

class StatisticsRepository {
  late final Box<BlockedAppStat> _box;

  StatisticsRepository() {
    _box = Hive.box<BlockedAppStat>(AppConstants.blockedAppStatsBox);
  }

  Future<void> recordBlockedApp(String packageName, String appName) async {
    final existing = _box.values.firstWhere(
      (stat) => stat.packageName == packageName,
      orElse: () => BlockedAppStat(
        packageName: packageName,
        appName: appName,
        blockCount: 0,
        lastBlockedTime: DateTime.now(),
      ),
    );

    if (_box.containsKey(existing.packageName)) {
      existing.blockCount++;
      existing.lastBlockedTime = DateTime.now();
      await _box.put(existing.packageName, existing);
    } else {
      await _box.put(
        packageName,
        BlockedAppStat(
          packageName: packageName,
          appName: appName,
          blockCount: 1,
          lastBlockedTime: DateTime.now(),
        ),
      );
    }
  }

  List<BlockedAppStat> getTopBlockedApps({int limit = 5}) {
    final sorted = _box.values.toList()..sort((a, b) => b.blockCount.compareTo(a.blockCount));
    return sorted.take(limit).toList();
  }

  List<BlockedAppStat> getAllBlockedApps() {
    return _box.values.toList()..sort((a, b) => b.blockCount.compareTo(a.blockCount));
  }

  int getTotalBlocks() {
    return _box.values.fold<int>(0, (sum, stat) => sum + stat.blockCount);
  }

  int getUniqueAppsBlocked() {
    return _box.length;
  }

  BlockedAppStat? getStatsByPackage(String packageName) {
    return _box.get(packageName);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> deleteStat(String packageName) async {
    await _box.delete(packageName);
  }
}
