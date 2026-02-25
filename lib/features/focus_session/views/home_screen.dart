import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/core/theme/app_theme.dart';
import 'package:focusguard/features/focus_session/models/focus_session_state.dart';
import '../../../services/native_bridge/android_service_bridge.dart';
import '../../app_selection/viewmodels/app_selection_viewmodel.dart';
import '../viewmodels/focus_session_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;

  final focusPresets = [
    {'duration': 15, 'label': '15min', 'color': Colors.blue},
    {'duration': 25, 'label': '25min', 'color': Colors.purple},
    {'duration': 45, 'label': '45min', 'color': Colors.orange},
    {'duration': 90, 'label': '90min', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(focusSessionViewModelProvider.notifier).checkPermissions();
      ref.invalidate(blockedAppsCountProvider);
      ref.invalidate(blockedAppsProvider);
    }
  }

  void _showEnableServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Accessibility Required',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'FocusGuard needs accessibility permission to block distractive applications effectively.',
          style: TextStyle(color: AppColors.textDim),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AndroidServiceBridge.openAccessibilitySettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(focusSessionViewModelProvider);
    final sessionNotifier = ref.read(focusSessionViewModelProvider.notifier);
    final blockedCountAsync = ref.watch(blockedAppsCountProvider);
    final blockedCount = blockedCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(
              250,
              AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: _buildBlurCircle(
              300,
              AppColors.accentSecondary.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildPermissionPrompts(sessionState, sessionNotifier),
                  const SizedBox(height: 40),
                  _buildFocusOrb(sessionState, sessionNotifier, blockedCount),
                  const SizedBox(height: 60),
                  if (!sessionState.isSessionActive)
                    _buildDurationPicker(sessionState, sessionNotifier),
                  const SizedBox(height: 48),
                  _buildStatusCards(sessionState, blockedCount),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPrompts(
    FocusSessionState sessionState,
    FocusSessionViewModel sessionNotifier,
  ) {
    if (sessionState.hasNotificationPermission &&
        sessionState.hasOverlayPermission &&
        sessionState.isServiceEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (!sessionState.hasNotificationPermission)
          _buildPermissionCard(
            sessionState.isNotificationPermanentlyDenied
                ? 'Action Required'
                : 'Notifications Disabled',
            sessionState.isNotificationPermanentlyDenied
                ? 'Permissions are blocked. Please enable in Settings.'
                : 'Required to show session status and alerts.',
            Icons.notifications_active_rounded,
            AppColors.warning,
            () => sessionNotifier.requestNotificationPermission(),
          ),
        if (!sessionState.hasNotificationPermission &&
            !sessionState.hasOverlayPermission)
          const SizedBox(height: 12),
        if (!sessionState.hasOverlayPermission)
          _buildPermissionCard(
            'Overlay Permission',
            'Required to display the blocking screen over apps.',
            Icons.layers_rounded,
            AppColors.info,
            () => sessionNotifier.requestOverlayPermission(),
          ),
        if ((!sessionState.hasNotificationPermission ||
                !sessionState.hasOverlayPermission) &&
            !sessionState.isServiceEnabled)
          const SizedBox(height: 12),
        if (!sessionState.isServiceEnabled)
          _buildPermissionCard(
            'Accessibility Service',
            'Essential for detecting and blocking apps.',
            Icons.admin_panel_settings_rounded,
            AppColors.error,
            () => _showEnableServiceDialog(),
          ),
      ],
    );
  }

  Widget _buildPermissionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textDim.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Deep Focus',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bolt_rounded, color: AppColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusOrb(
    FocusSessionState sessionState,
    FocusSessionViewModel sessionNotifier,
    int blockedCount,
  ) {
    const accent = AppColors.accent;
    const secondary = AppColors.accentSecondary;

    return GestureDetector(
      onTap: () {
        if (blockedCount == 0 && !sessionState.isSessionActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please block some apps first!')),
          );
          return;
        }

        if (!sessionState.isServiceEnabled && !sessionState.isSessionActive) {
          _showEnableServiceDialog();
          return;
        }

        sessionNotifier.toggleSession(sessionState.selectedPreset);
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (sessionState.isSessionActive)
              ScaleTransition(
                scale: Tween<double>(
                  begin: 1.0,
                  end: 1.3,
                ).animate(_pulseController),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: secondary.withValues(alpha: 0.25),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: sessionState.isSessionActive
                      ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                      : [accent, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (sessionState.isSessionActive ? Colors.red : accent)
                        .withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: -10,
                    offset: const Offset(-10, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    sessionState.isSessionActive
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sessionState.isSessionActive ? 'GIVE UP' : 'FOCUS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (sessionState.isSessionActive)
                    Text(
                      _formatRemainingTime(sessionNotifier.remainingSeconds),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRemainingTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildDurationPicker(
    FocusSessionState sessionState,
    FocusSessionViewModel sessionNotifier,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: focusPresets.map((p) {
            final isSelected = sessionState.selectedPreset == p['duration'];
            final color = p['color'] as Color;
            return GestureDetector(
              onTap: () {
                sessionNotifier.setSelectedPreset(p['duration'] as int);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                height: 90,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${p['duration']}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : AppColors.text,
                      ),
                    ),
                    const Text(
                      'min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusCards(FocusSessionState sessionState, int blockedCount) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            'System',
            sessionState.isServiceEnabled ? 'Active' : 'Needs Setup',
            sessionState.isServiceEnabled
                ? Icons.verified_user_rounded
                : Icons.info_outline,
            sessionState.isServiceEnabled
                ? AppColors.success
                : AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallStatCard(
            'Filters',
            '$blockedCount Active',
            Icons.grid_view_rounded,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
