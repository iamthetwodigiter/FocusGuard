import 'package:focusguard/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/focus_session.dart';

class SessionHistoryRepository {
  late Box<FocusSession> _box;

  SessionHistoryRepository() {
    _box = Hive.box<FocusSession>(AppConstants.sessionsBox);
  }

  /// Create and start a new focus session
  Future<FocusSession> startSession(
    int durationMinutes,
    List<String> blockedApps,
  ) async {
    final session = FocusSession(
      sessionId: const Uuid().v4(),
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      blockedAppsCount: blockedApps.length,
      blockedAppsPackages: blockedApps,
      completed: false,
    );
    await _box.add(session);
    return session;
  }

  /// End a focus session
  Future<void> endSession(String sessionId) async {
    final sessions = _box.values
        .where((s) => s.sessionId == sessionId)
        .toList();
    if (sessions.isNotEmpty) {
      final session = sessions.first;
      session.endTime = DateTime.now();
      session.completed = true;
      await session.save();
    }
  }

  /// Get all sessions
  List<FocusSession> getAllSessions() =>
      _box.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));

  /// Get today's sessions
  List<FocusSession> getTodaySessions() =>
      getAllSessions().where((s) => s.isToday).toList();

  /// Get this week's sessions
  List<FocusSession> getWeekSessions() =>
      getAllSessions().where((s) => s.isThisWeek).toList();

  /// Get this month's sessions
  List<FocusSession> getMonthSessions() =>
      getAllSessions().where((s) => s.isThisMonth).toList();

  /// Get total focus time (in minutes)
  int getTotalFocusTime(List<FocusSession> sessions) {
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
  }

  /// Get total blocks count
  int getTotalBlocksCount(List<FocusSession> sessions) {
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.blockedAppsCount,
    );
  }

  /// Get completed sessions count
  int getCompletedCount(List<FocusSession> sessions) {
    return sessions.where((s) => s.completed).length;
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    final sessions = _box.values
        .where((s) => s.sessionId == sessionId)
        .toList();
    if (sessions.isNotEmpty) {
      await sessions.first.delete();
    }
  }

  /// Clear all sessions
  Future<void> clearAll() async {
    await _box.clear();
  }
}
