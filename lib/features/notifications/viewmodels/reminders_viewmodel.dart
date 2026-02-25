import 'package:flutter_riverpod/flutter_riverpod.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isActive;
  final String type;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.isActive,
    required this.type,
  });
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, AsyncValue<List<Reminder>>>((ref) {
  return RemindersNotifier();
});

class RemindersNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  RemindersNotifier() : super(const AsyncValue.loading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    try {
      final now = DateTime.now();
      final reminders = [
        Reminder(
          id: '1',
          title: 'Morning Focus Time',
          description: 'Start your daily focus session',
          scheduledTime: now.add(const Duration(hours: 2)),
          isActive: true,
          type: 'focus',
        ),
        Reminder(
          id: '2',
          title: 'Take a Break',
          description: 'You\'ve been focusing for 1 hour',
          scheduledTime: now.add(const Duration(hours: 1)),
          isActive: true,
          type: 'break',
        ),
      ];
      state = AsyncValue.data(reminders);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<Reminder>>).value;
      state = AsyncValue.data([...currentData, reminder]);
    }
  }

  Future<void> deleteReminder(String id) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<Reminder>>).value;
      state = AsyncValue.data(
        currentData.where((reminder) => reminder.id != id).toList(),
      );
    }
  }

  Future<void> toggleReminder(String id) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<Reminder>>).value;
      state = AsyncValue.data(
        currentData.map((reminder) {
          if (reminder.id == id) {
            return Reminder(
              id: reminder.id,
              title: reminder.title,
              description: reminder.description,
              scheduledTime: reminder.scheduledTime,
              isActive: !reminder.isActive,
              type: reminder.type,
            );
          }
          return reminder;
        }).toList(),
      );
    }
  }
}

final activeRemindersCountProvider = Provider<int>((ref) {
  final reminders = ref.watch(remindersProvider);
  return reminders.whenData((list) => list.where((r) => r.isActive).length).value ?? 0;
});
