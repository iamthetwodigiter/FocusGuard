import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:focusguard/features/settings/presentation/screens/debug_logs_screen.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurCircle(
              300,
              AppColors.accentSecondary.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlurCircle(
              250,
              AppColors.accent.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    children: [
                      _buildSectionTitle('Interaction'),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          context,
                          'Push Notifications',
                          'Stay updated on focus progress',
                          Icons.notifications_active_rounded,
                          AppColors.accent,
                          settings['notificationEnabled'] ?? false,
                          (val) => ref.read(settingsProvider.notifier).updateSetting('notificationEnabled', val),
                        ),
                        _buildSwitchTile(
                          context,
                          'Haptic Feedback',
                          'Tactile response on events',
                          Icons.vibration_rounded,
                          AppColors.warning,
                          settings['vibrationEnabled'] ?? false,
                          (val) => ref.read(settingsProvider.notifier).updateSetting('vibrationEnabled', val),
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Security & Privacy'),
                      _buildSettingsCard([
                        _buildSwitchTile(
                          context,
                          'Shield System Apps',
                          'Apply rules to system applications',
                          Icons.admin_panel_settings_rounded,
                          AppColors.success,
                          settings['blockSystemApps'] ?? false,
                          (val) => ref.read(settingsProvider.notifier).updateSetting('blockSystemApps', val),
                        ),
                        _buildSwitchTile(
                          context,
                          'Screenshot Privacy',
                          'Protect content from screenshots',
                          Icons.screenshot_rounded,
                          AppColors.accentSecondary,
                          // In settings map, allowScreenshots true means privacy is false
                          !(settings['allowScreenshots'] ?? true),
                          (val) => ref.read(settingsProvider.notifier).updateSetting('allowScreenshots', !val),
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Maintenance'),
                      _buildSettingsCard([
                        _buildActionTile(
                          context,
                          'System Diagnostics',
                          'View internal service activity',
                          Icons.terminal_rounded,
                          AppColors.textDim,
                          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebugLogsScreen())),
                        ),
                        _buildActionTile(
                          context,
                          'Reset Preferences',
                          'Restore all factory defaults',
                          Icons.refresh_rounded,
                          AppColors.error,
                          () => _showResetDialog(context, ref),
                        ),
                      ]),
                      const SizedBox(height: 48),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'FocusGuard Premium',
                              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            Text(
                              'Version 1.0.0 (Build 42)',
                              style: TextStyle(color: AppColors.textDim.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textDim,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
        activeThumbColor: AppColors.accent, // Keeping it for compatibility if needed, but the lint suggested activeThumbColor/activeTrackColor
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textDim),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Confirm Reset', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
        content: const Text(
          'Restore all preferences to default values? This cannot be undone.',
          style: TextStyle(color: AppColors.textDim),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }
}
