import 'package:flutter_riverpod/flutter_riverpod.dart';
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
