import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/native_bridge/android_service_bridge.dart';
import '../../session_history/models/focus_session.dart';
import '../../session_history/viewmodels/session_history_viewmodel.dart';
import '../../app_selection/viewmodels/app_selection_viewmodel.dart';
import '../models/focus_session_state.dart';

class FocusSessionViewModel extends StateNotifier<FocusSessionState> {
  final Ref _ref;
  DateTime? _sessionStartTime;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  FocusSessionViewModel(this._ref) : super(FocusSessionState()) {
    checkPermissions();
  }

  int get remainingSeconds => _remainingSeconds;

  Future<void> checkPermissions() async {
    final enabled = await AndroidServiceBridge.isAccessibilityServiceEnabled();
    final overlayPermission = await AndroidServiceBridge.canDrawOverlays();
    final notificationStatus = await Permission.notification.status;

    state = state.copyWith(
      isServiceEnabled: enabled,
      hasOverlayPermission: overlayPermission,
      hasNotificationPermission: notificationStatus.isGranted,
      isNotificationPermanentlyDenied: notificationStatus.isPermanentlyDenied,
    );
  }

  Future<void> requestNotificationPermission() async {
    if (state.isNotificationPermanentlyDenied) {
      await openAppSettings();
    } else {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        // Fallback for some Android versions where request() returns denied but dialog wasn't shown
        await Future.delayed(const Duration(milliseconds: 200));
        await checkPermissions();
        if (!state.hasNotificationPermission) {
          await openAppSettings();
        }
      } else {
        await checkPermissions();
      }
    }
  }

  Future<void> setSelectedPreset(int preset) async {
    state = state.copyWith(selectedPreset: preset);
  }

  Future<void> requestOverlayPermission() async {
    await AndroidServiceBridge.requestOverlayPermission();
    // Status will be re-checked when app resumes via didChangeAppLifecycleState in View
  }

  Future<void> startSession(int durationMinutes) async {
    if (state.isSessionActive) return;

    if (!state.isServiceEnabled || !state.hasOverlayPermission) {
      checkPermissions();
      return;
    }

    await AndroidServiceBridge.activateFocusSession(true);
    
    _sessionStartTime = DateTime.now();
    _remainingSeconds = durationMinutes * 60;
    _startTimer();
    await AndroidServiceBridge.setScreenshotBlocking(true);
    
    state = state.copyWith(isSessionActive: true);
  }

  Future<void> stopSession() async {
    if (!state.isSessionActive) return;

    await AndroidServiceBridge.activateFocusSession(false);
    _stopTimer();

    if (_sessionStartTime != null) {
      final blockedApps = _ref.read(blockedAppsProvider).value ?? [];
      final session = FocusSession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationMinutes: DateTime.now().difference(_sessionStartTime!).inMinutes,
        blockedAppsCount: blockedApps.length,
        blockedAppsPackages: blockedApps.map((a) => a.packageName).toList(),
        completed: true,
      );
      await _ref.read(sessionHistoryProvider.notifier).addSession(session);
      _sessionStartTime = null;
    }
    await AndroidServiceBridge.setScreenshotBlocking(false);
    state = state.copyWith(isSessionActive: false);
  }

  Future<void> toggleSession(int durationMinutes) async {
    if (state.isSessionActive) {
      await stopSession();
    } else {
      await startSession(durationMinutes);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // Trigger a fake state update to notify listeners of timer change 
        // Or we could move remainingSeconds into the state
        state = state.copyWith(); 
      } else {
        toggleSession(0); // Stop session when time is up
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final focusSessionViewModelProvider = StateNotifierProvider<FocusSessionViewModel, FocusSessionState>((ref) {
  return FocusSessionViewModel(ref);
});
