import 'package:hive_flutter/hive_flutter.dart';

part 'achievement.g.dart';

@HiveType(typeId: 1)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  bool unlocked;

  @HiveField(5)
  DateTime? unlockedDate;

  @HiveField(6)
  final String category; // 'streak', 'focus_time', 'blocks', 'sessions'

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlocked,
    this.unlockedDate,
    required this.category,
  });
}
