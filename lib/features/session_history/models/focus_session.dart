import 'package:hive_flutter/hive_flutter.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 0)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final int blockedAppsCount;

  @HiveField(5)
  final List<String> blockedAppsPackages;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  final String notes;

  FocusSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.blockedAppsCount,
    required this.blockedAppsPackages,
    required this.completed,
    this.notes = '',
  });

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return startTime.isAfter(weekAgo);
  }

  bool get isThisMonth {
    return startTime.month == DateTime.now().month &&
        startTime.year == DateTime.now().year;
  }
}
