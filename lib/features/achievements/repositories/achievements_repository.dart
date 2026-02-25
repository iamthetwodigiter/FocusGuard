import 'package:focusguard/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement.dart';
import '../../session_history/models/focus_session.dart';

class AchievementsRepository {
  late Box<Achievement> _box;

  Future<void> init() async {
    _box = Hive.box<Achievement>(AppConstants.achievementsBox);
    await _initializeAchievements();
  }

  Future<void> _initializeAchievements() async {
    if (_box.isEmpty) {
      final achievements = _getDefaultAchievements();
      for (var achievement in achievements) {
        await _box.add(achievement);
      }
    }
  }

  List<Achievement> _getDefaultAchievements() => [
    Achievement(
      id: 'first_session',
      title: 'First Focus',
      description: 'Complete your first focus session',
      emoji: '🎯',
      unlocked: false,
      category: 'sessions',
    ),
    Achievement(
      id: 'one_hour',
      title: 'One Hour Focus',
      description: 'Complete 60 minutes in a single session',
      emoji: '⏰',
      unlocked: false,
      category: 'focus_time',
    ),
    Achievement(
      id: 'three_day_streak',
      title: 'On Fire',
      description: 'Maintain a 3 day focus streak',
      emoji: '🔥',
      unlocked: false,
      category: 'streak',
    ),
    Achievement(
      id: 'blocked_100',
      title: 'Blocker',
      description: 'Block 100 app attempts',
      emoji: '🚫',
      unlocked: false,
      category: 'blocks',
    ),
    Achievement(
      id: 'ten_sessions',
      title: 'Committed',
      description: 'Complete 10 focus sessions',
      emoji: '📊',
      unlocked: false,
      category: 'sessions',
    ),
    Achievement(
      id: 'five_hours',
      title: 'Marathon',
      description: 'Accumulate 5 hours of focus time',
      emoji: '🏃',
      unlocked: false,
      category: 'focus_time',
    ),
  ];

  /// Get all achievements
  List<Achievement> getAll() => _box.values.toList();

  /// Get unlocked achievements
  List<Achievement> getUnlocked() => getAll().where((a) => a.unlocked).toList();

  /// Get locked achievements
  List<Achievement> getLocked() => getAll().where((a) => !a.unlocked).toList();

  /// Check and unlock achievements based on sessions
  Future<void> checkAndUnlockAchievements(List<FocusSession> allSessions) async {
    final achievements = getAll();

    for (var achievement in achievements) {
      if (achievement.unlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_session':
          shouldUnlock = allSessions.isNotEmpty;
          break;
        case 'one_hour':
          shouldUnlock = allSessions.any((s) => s.durationMinutes >= 60);
          break;
        case 'three_day_streak':
          shouldUnlock = _checkStreak(allSessions, 3);
          break;
        case 'blocked_100':
          final totalBlocks =
              allSessions.fold<int>(0, (sum, s) => sum + s.blockedAppsCount);
          shouldUnlock = totalBlocks >= 100;
          break;
        case 'ten_sessions':
          shouldUnlock = allSessions.length >= 10;
          break;
        case 'five_hours':
          final totalMinutes =
              allSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
          shouldUnlock = totalMinutes >= 300; // 5 hours
          break;
      }

      if (shouldUnlock) {
        achievement.unlocked = true;
        achievement.unlockedDate = DateTime.now();
        await achievement.save();
      }
    }
  }

  bool _checkStreak(List<FocusSession> sessions, int minimumDays) {
    if (sessions.isEmpty) return false;

    final sortedSessions = sessions.where((s) => s.completed).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sortedSessions.isEmpty) return false;

    int streak = 1;
    DateTime currentDate = DateTime(
      sortedSessions[0].startTime.year,
      sortedSessions[0].startTime.month,
      sortedSessions[0].startTime.day,
    );

    for (int i = 1; i < sortedSessions.length; i++) {
      final sessionDate = DateTime(
        sortedSessions[i].startTime.year,
        sortedSessions[i].startTime.month,
        sortedSessions[i].startTime.day,
      );

      final difference = currentDate.difference(sessionDate).inDays;

      if (difference == 1) {
        streak++;
        currentDate = sessionDate;
      } else if (difference > 1) {
        break;
      }
    }

    return streak >= minimumDays;
  }

  /// Get achievement by id
  Achievement? getById(String id) {
    try {
      return _box.values.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
