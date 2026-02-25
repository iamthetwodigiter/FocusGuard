import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusRule {
  final String id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> daysOfWeek;
  final bool isEnabled;

  FocusRule({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.isEnabled,
  });
}

final focusRulesProvider =
    StateNotifierProvider<FocusRulesNotifier, AsyncValue<List<FocusRule>>>((ref) {
  return FocusRulesNotifier();
});

class FocusRulesNotifier extends StateNotifier<AsyncValue<List<FocusRule>>> {
  FocusRulesNotifier() : super(const AsyncValue.loading()) {
    loadRules();
  }

  Future<void> loadRules() async {
    try {
      final rules = [
        FocusRule(
          id: '1',
          name: 'Morning Focus',
          startTime: const TimeOfDay(hour: 6, minute: 0),
          endTime: const TimeOfDay(hour: 9, minute: 0),
          daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          isEnabled: true,
        ),
        FocusRule(
          id: '2',
          name: 'Afternoon Focus',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 16, minute: 0),
          daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          isEnabled: false,
        ),
      ];
      state = AsyncValue.data(rules);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addRule(FocusRule rule) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<FocusRule>>).value;
      state = AsyncValue.data([...currentData, rule]);
    }
  }

  Future<void> deleteRule(String id) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<FocusRule>>).value;
      state = AsyncValue.data(
        currentData.where((rule) => rule.id != id).toList(),
      );
    }
  }

  Future<void> toggleRule(String id) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<FocusRule>>).value;
      state = AsyncValue.data(
        currentData.map((rule) {
          if (rule.id == id) {
            return FocusRule(
              id: rule.id,
              name: rule.name,
              startTime: rule.startTime,
              endTime: rule.endTime,
              daysOfWeek: rule.daysOfWeek,
              isEnabled: !rule.isEnabled,
            );
          }
          return rule;
        }).toList(),
      );
    }
  }
}

final enabledRulesCountProvider = Provider<int>((ref) {
  final rules = ref.watch(focusRulesProvider);
  return rules.whenData((list) => list.where((rule) => rule.isEnabled).length).value ?? 0;
});
