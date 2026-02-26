import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'days': daysOfWeek,
      'isEnabled': isEnabled,
    };
  }

  factory FocusRule.fromMap(Map<dynamic, dynamic> map) {
    return FocusRule(
      id: map['id'] as String,
      name: map['name'] as String,
      startTime: TimeOfDay(hour: map['startHour'] as int, minute: map['startMinute'] as int),
      endTime: TimeOfDay(hour: map['endHour'] as int, minute: map['endMinute'] as int),
      daysOfWeek: List<String>.from(map['days'] as List),
      isEnabled: map['isEnabled'] as bool,
    );
  }
}

final focusRulesProvider =
    StateNotifierProvider<FocusRulesNotifier, AsyncValue<List<FocusRule>>>((ref) {
  return FocusRulesNotifier();
});

class FocusRulesNotifier extends StateNotifier<AsyncValue<List<FocusRule>>> {
  FocusRulesNotifier() : super(const AsyncValue.loading()) {
    loadRules();
  }

  Box get _box => Hive.box(AppConstants.routinesBox);

  Future<void> loadRules() async {
    try {
      final List<dynamic> rawRules = _box.get(AppConstants.routinesKey, defaultValue: []);
      final rules = rawRules.map((r) => FocusRule.fromMap(r as Map)).toList();
      
      if (rules.isEmpty) {
        // Initial defaults
        final defaultRules = [
          FocusRule(
            id: '1',
            name: 'Deep Work',
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 12, minute: 0),
            daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
            isEnabled: false,
          ),
        ];
        await _saveRules(defaultRules);
        state = AsyncValue.data(defaultRules);
      } else {
        state = AsyncValue.data(rules);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveRules(List<FocusRule> rules) async {
    await _box.put(AppConstants.routinesKey, rules.map((r) => r.toMap()).toList());
  }

  Future<void> addRule(FocusRule rule) async {
    state.whenData((currentData) async {
      final newList = [...currentData, rule];
      await _saveRules(newList);
      state = AsyncValue.data(newList);
    });
  }

  Future<void> deleteRule(String id) async {
    state.whenData((currentData) async {
      final newList = currentData.where((rule) => rule.id != id).toList();
      await _saveRules(newList);
      state = AsyncValue.data(newList);
    });
  }

  Future<void> toggleRule(String id) async {
    state.whenData((currentData) async {
      final newList = currentData.map((rule) {
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
      }).toList();
      await _saveRules(newList);
      state = AsyncValue.data(newList);
    });
  }

  Future<void> updateRule(FocusRule updatedRule) async {
    state.whenData((currentData) async {
      final newList = currentData.map((rule) {
        return rule.id == updatedRule.id ? updatedRule : rule;
      }).toList();
      await _saveRules(newList);
      state = AsyncValue.data(newList);
    });
  }
}

final enabledRulesCountProvider = Provider<int>((ref) {
  final rules = ref.watch(focusRulesProvider);
  return rules.whenData((list) => list.where((rule) => rule.isEnabled).length).value ?? 0;
});
