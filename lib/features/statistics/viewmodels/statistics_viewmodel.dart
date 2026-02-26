import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../session_history/viewmodels/session_history_viewmodel.dart';
import '../repositories/statistics_repository.dart';
import '../models/blocked_app_stat.dart';

final statisticsRepositoryProvider = Provider((ref) => StatisticsRepository());

final topBlockedAppsProvider = FutureProvider<List<BlockedAppStat>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getTopBlockedApps(limit: 5);
});

final allBlockedAppsProvider = FutureProvider<List<BlockedAppStat>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getAllBlockedApps();
});

final totalBlocksStatProvider = Provider<int>((ref) {
  final repo = ref.watch(statisticsRepositoryProvider);
  // We need to watch the underlying data to react to changes.
  // One way is to have a state notifier or just reload the provider.
  return repo.getTotalBlocks();
});

final uniqueAppsBlockedProvider = Provider<int>((ref) {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getUniqueAppsBlocked();
});

final peakFlowStreakProvider = Provider<int>((ref) {
  final sessionsAsync = ref.watch(sessionHistoryProvider);
  return sessionsAsync.maybeWhen(
    data: (sessions) {
      if (sessions.isEmpty) return 0;
      
      // Get unique dates with at least one session, sorted newest to oldest
      final sessionDates = sessions
          .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (sessionDates.isEmpty) return 0;

      int streak = 0;
      DateTime today = DateTime.now();
      DateTime checkDate = DateTime(today.year, today.month, today.day);

      // If the latest session isn't today or yesterday, streak is broken
      if (sessionDates.first.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        return 0;
      }

      // If latest is yesterday, start checking from yesterday
      if (sessionDates.first == checkDate.subtract(const Duration(days: 1))) {
          checkDate = sessionDates.first;
      }

      for (final date in sessionDates) {
        if (date == checkDate) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(checkDate)) {
          break; // Gap found
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});
