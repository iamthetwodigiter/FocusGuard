import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/core/theme/app_theme.dart';
import 'package:focusguard/core/constants/system_whitelist.dart';
import 'package:focusguard/features/settings/views/settings_screen.dart';
import '../../app_selection/viewmodels/app_selection_viewmodel.dart';
import '../../app_selection/models/app_info.dart';
import '../../settings/viewmodels/settings_viewmodel.dart';

class WhitelistScreen extends ConsumerStatefulWidget {
  const WhitelistScreen({super.key});

  @override
  ConsumerState<WhitelistScreen> createState() => _WhitelistScreenState();
}

class _WhitelistScreenState extends ConsumerState<WhitelistScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsState = ref.watch(appSelectionViewModelProvider);
    final blockedCountAsync = ref.watch(blockedAppsCountProvider);
    final blockedCount = blockedCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, blockedCount),
                _buildSearchHeader(),
                const SizedBox(height: 16),
                _buildInfoBanner(),
                const SizedBox(height: 16),
                Expanded(
                  child: appsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (error, _) => Center(child: Text('Error: $error')),
                    data: (apps) {
                      // Filter to only show apps that are in the whitelist AND installed on this device
                      final systemApps = apps
                          .where(
                            (app) => SystemWhitelist.packageNames.contains(
                              app.packageName,
                            ),
                          )
                          .toList();

                      return _buildAppsList(systemApps);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int blockedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Trusted Apps',
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

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) {
            ref.read(appSelectionViewModelProvider.notifier).searchApps(query);
          },
          style: const TextStyle(color: AppColors.text, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search trusted system apps...',
            hintStyle: TextStyle(
              color: AppColors.textDim.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.accent,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'These core system components are exempt from blocking by default.',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList(List<AppInfo> systemApps) {
    if (systemApps.isEmpty) {
      return const Center(
        child: Text(
          'No matching system apps found',
          style: TextStyle(color: AppColors.textDim),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      children: [
        _buildSectionTitle('Installed Core Components'),
        const SizedBox(height: 12),
        ...systemApps.map((app) => _buildAppCard(app)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textDim,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAppCard(AppInfo app) {
    final bool isTrusted = !app.isBlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTrusted
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.02),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: app.icon != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    app.icon! as Uint8List,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.android_rounded, color: AppColors.textDim),
        ),
        title: Text(
          app.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              isTrusted ? 'Trusted' : 'Restricted',
              style: TextStyle(
                color: isTrusted ? AppColors.success : AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CORE',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Switch.adaptive(
          value: isTrusted,
          activeTrackColor: AppColors.success.withValues(alpha: 0.5),
          activeThumbColor: AppColors.success,
          onChanged: (val) {
            final isShieldActive =
                ref.read(settingsProvider)['systemAppShield'] ?? true;
            if (isShieldActive) {
              _showShieldWarning(context);
              return;
            }
            ref
                .read(appSelectionViewModelProvider.notifier)
                .toggleAppBlock(app.packageName);
          },
        ),
      ),
    );
  }

  void _showShieldWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.success),
            SizedBox(width: 12),
            Text(
              'Shield Active',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const Text(
          'System App Shield is currently active. Core components are protected and cannot be untrusted.\nTo block system apps disable \'System App Shield\' in the settings.',
          style: TextStyle(color: AppColors.textDim),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            child: Text('Go to Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Understood',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
