import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';
import '../repositories/session_history_repository.dart';

/// Provider for SessionHistoryRepository
final sessionHistoryRepositoryProvider = Provider<SessionHistoryRepository>((ref) {
  return SessionHistoryRepository();
});

/// ViewModel for Session History
class SessionHistoryNotifier extends StateNotifier<AsyncValue<List<FocusSession>>> {
  final SessionHistoryRepository _repository;

  SessionHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final sessions = _repository.getAllSessions();
      state = AsyncValue.data(sessions);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addSession(FocusSession session) async {
    state.whenData((sessions) {
      state = AsyncValue.data([session, ...sessions]);
    });
    // Session is already added to Hive in Repository.startSession, 
    // but if it's a finished session being added manually:
    // Actually the logic in Repository is better.
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
    loadSessions();
  }

  Future<void> clearHistory() async {
    await _repository.clearAll();
    state = const AsyncValue.data([]);
  }
}

/// Provider for SessionHistoryNotifier
final sessionHistoryProvider =
    StateNotifierProvider<SessionHistoryNotifier, AsyncValue<List<FocusSession>>>((ref) {
  final repository = ref.read(sessionHistoryRepositoryProvider);
  return SessionHistoryNotifier(repository);
});

final allSessionsProvider = FutureProvider<List<FocusSession>>((ref) async {
  final repo = ref.watch(sessionHistoryRepositoryProvider);
  return repo.getAllSessions();
});

final todaySessionsProvider = FutureProvider<List<FocusSession>>((ref) async {
  final repo = ref.watch(sessionHistoryRepositoryProvider);
  return repo.getTodaySessions();
});

final weekSessionsProvider = FutureProvider<List<FocusSession>>((ref) async {
  final repo = ref.watch(sessionHistoryRepositoryProvider);
  return repo.getWeekSessions();
});

final monthSessionsProvider = FutureProvider<List<FocusSession>>((ref) async {
  final repo = ref.watch(sessionHistoryRepositoryProvider);
  return repo.getMonthSessions();
});

/// Provider for total focus time (in minutes)
final totalFocusTimeProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionHistoryProvider);
  return sessions.whenData((list) {
    return list.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }).value ?? 0;
});

/// Provider for completed sessions count
final completedSessionsCountProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionHistoryProvider);
  return sessions.whenData((list) {
    return list.where((s) => s.completed).length;
  }).value ?? 0;
});
