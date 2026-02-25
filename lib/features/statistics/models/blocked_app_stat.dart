import 'package:hive_flutter/hive_flutter.dart';

part 'blocked_app_stat.g.dart';

@HiveType(typeId: 2)
class BlockedAppStat extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final int blockCount;

  @HiveField(3)
  final DateTime lastBlockedTime;

  BlockedAppStat({
    required this.packageName,
    required this.appName,
    required this.blockCount,
    required this.lastBlockedTime,
  });

  set blockCount(int count) => blockCount = count;
  set lastBlockedTime(DateTime last) => lastBlockedTime = last;
}
