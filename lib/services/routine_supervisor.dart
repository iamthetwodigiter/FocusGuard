import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/features/scheduling/viewmodels/focus_rules_viewmodel.dart';
import 'package:focusguard/features/focus_session/viewmodels/focus_session_viewmodel.dart';
import 'package:focusguard/services/logging_service.dart';
import 'package:intl/intl.dart';

final routineSupervisorProvider = Provider<RoutineSupervisor>((ref) {
  return RoutineSupervisor(ref);
});

class RoutineSupervisor {
  final Ref _ref;
  Timer? _timer;
  bool _isChecking = false;

  RoutineSupervisor(this._ref);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkRoutines());
    _checkRoutines();
    LoggingService().log('🕒 Routine Supervisor Started (5s interval)');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    debugPrint('🕒 Routine Supervisor Stopped');
  }

  Future<void> _checkRoutines() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final now = DateTime.now();
      final currentDay = DateFormat('E').format(now); // Mon, Tue, etc.
      final currentTimeInMinutes = now.hour * 60 + now.minute;

      final rulesAsync = _ref.read(focusRulesProvider);
      final sessionState = _ref.read(focusSessionViewModelProvider);

      rulesAsync.whenData((rules) {
        bool shouldBeActive = false;
        FocusRule? activeRule;

        for (final rule in rules) {
          if (!rule.isEnabled) continue;
          if (!rule.daysOfWeek.contains(currentDay)) continue;

          final startInMinutes = rule.startTime.hour * 60 + rule.startTime.minute;
          final endInMinutes = rule.endTime.hour * 60 + rule.endTime.minute;

          // Handle overnight schedules (e.g., 23:00 to 02:00)
          bool isTimeMatch = false;
          if (startInMinutes <= endInMinutes) {
            isTimeMatch = currentTimeInMinutes >= startInMinutes && currentTimeInMinutes < endInMinutes;
          } else {
            // Overnight case
            isTimeMatch = currentTimeInMinutes >= startInMinutes || currentTimeInMinutes < endInMinutes;
          }

          if (isTimeMatch) {
            shouldBeActive = true;
            activeRule = rule;
            break; 
          }
        }

        if (shouldBeActive && !sessionState.isSessionActive) {
          LoggingService().log('🕒 Automation: Starting session for routine "${activeRule?.name}"');
          _startAutomaticSession(activeRule!);
        } else if (!shouldBeActive && sessionState.isSessionActive) {
          // Optional: Auto-stop session if it was started by automation?
          // For now, let's just start sessions.
        }
      });
    } catch (e) {
      debugPrint('❌ Error checking routines: $e');
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _startAutomaticSession(FocusRule rule) async {
    final now = DateTime.now();
    final endInMinutes = rule.endTime.hour * 60 + rule.endTime.minute;
    final nowInMinutes = now.hour * 60 + now.minute;
    
    int duration;
    if (endInMinutes > nowInMinutes) {
      duration = endInMinutes - nowInMinutes;
    } else {
      // Overnight
      duration = (1440 - nowInMinutes) + endInMinutes;
    }

    if (duration <= 0) return;

    // Start session through the ViewModel
    await _ref.read(focusSessionViewModelProvider.notifier).startSession(duration);
  }
}
