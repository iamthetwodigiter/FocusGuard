import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/app_selection_viewmodel.dart';
import '../models/app_info.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class AppSelectionScreen extends ConsumerStatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
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
      backgroundColor: Colors.transparent, // Let Dashboard handle background
      body: Stack(
        children: [
          // Semi-transparent overlay to separate from dashboard background if needed
          // but dashboard already has background. Let's just use it.
          
          SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(blockedCount),
                const SizedBox(height: 16),
                _buildInfoBanner(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Application List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      if (blockedCount > 0)
                        Text(
                          '$blockedCount blocked',
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: appsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (error, _) => Center(child: Text('Error: $error')),
                    data: (apps) => _buildAppsList(apps),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(int blockedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      ref.read(appSelectionViewModelProvider.notifier).searchApps(query);
                    },
                    style: const TextStyle(color: AppColors.text, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search installed apps...',
                      hintStyle: TextStyle(color: AppColors.textDim.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.textDim),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(appSelectionViewModelProvider.notifier).loadApps();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (blockedCount > 0) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showClearDialog(context),
                  icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.error),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selected apps will be restricted when a focus session starts.',
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

  Widget _buildAppsList(List<AppInfo> apps) {
    if (apps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps_rounded, size: 64, color: AppColors.surface),
            SizedBox(height: 16),
            Text(
              'No applications found',
              style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(appSelectionViewModelProvider.notifier).loadApps(),
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return _buildAppCard(app);
        },
      ),
    );
  }

  Widget _buildAppCard(AppInfo app) {
    final bool isBlocked = app.isBlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBlocked ? AppColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.02),
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
                  child: Image.memory(app.icon! as Uint8List, fit: BoxFit.cover),
                )
              : const Icon(Icons.android_rounded, color: AppColors.textDim),
        ),
        title: Text(
          app.appName,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          isBlocked ? 'Restricted' : 'Allowed',
          style: TextStyle(
            color: isBlocked ? AppColors.error : AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch.adaptive(
          value: isBlocked,
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
          onChanged: (_) => ref.read(appSelectionViewModelProvider.notifier).toggleAppBlock(app.packageName),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Reset Rules?', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
        content: const Text(
          'Allow all restricted applications? This will reset your current blocklist.',
          style: TextStyle(color: AppColors.textDim),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Restricted')),
          TextButton(
            onPressed: () {
              ref.read(appSelectionViewModelProvider.notifier).clearAllBlocks();
              Navigator.pop(context);
            },
            child: const Text('Allow All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
