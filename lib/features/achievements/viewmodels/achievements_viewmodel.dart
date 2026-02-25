import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/achievements_repository.dart';
import '../models/achievement.dart';

final achievementsRepositoryProvider = Provider((ref) => AchievementsRepository());

final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.watch(achievementsRepositoryProvider);
  await repo.init();
  return repo.getAll();
});

final unlockedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.watch(achievementsRepositoryProvider);
  return repo.getUnlocked();
});

final lockedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.watch(achievementsRepositoryProvider);
  return repo.getLocked();
});

class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool unlocked;
  final DateTime? unlockedDate;

  AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.unlocked,
    this.unlockedDate,
  });
}

final badgesProvider = FutureProvider<List<AchievementBadge>>((ref) async {
  final achievements = ref.watch(allAchievementsProvider);
  return achievements.whenData((list) {
    return list.map((achievement) => AchievementBadge(
      id: achievement.id,
      name: achievement.title,
      description: achievement.description,
      emoji: achievement.emoji,
      unlocked: achievement.unlocked,
      unlockedDate: achievement.unlockedDate,
    )).toList();
  }).value ?? [];
});

final unlockedBadgesCountProvider = Provider<int>((ref) {
  final badges = ref.watch(badgesProvider);
  return badges.whenData((list) => list.where((b) => b.unlocked).length).value ?? 0;
});
