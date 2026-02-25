
class FocusSessionState {
  final bool isSessionActive;
  final bool isServiceEnabled;
  final bool hasOverlayPermission;
  final bool hasNotificationPermission;
  final bool isNotificationPermanentlyDenied;
  final int selectedPreset;

  FocusSessionState({
    this.isSessionActive = false,
    this.isServiceEnabled = false,
    this.hasOverlayPermission = false,
    this.hasNotificationPermission = false,
    this.isNotificationPermanentlyDenied = false,
    this.selectedPreset = 25,
  });

  FocusSessionState copyWith({
    bool? isSessionActive,
    bool? isServiceEnabled,
    bool? hasOverlayPermission,
    bool? hasNotificationPermission,
    bool? isNotificationPermanentlyDenied,
    int? selectedPreset,
  }) {
    return FocusSessionState(
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      hasNotificationPermission: hasNotificationPermission ?? this.hasNotificationPermission,
      isNotificationPermanentlyDenied: isNotificationPermanentlyDenied ?? this.isNotificationPermanentlyDenied,
      selectedPreset: selectedPreset ?? this.selectedPreset,
    );
  }
}
