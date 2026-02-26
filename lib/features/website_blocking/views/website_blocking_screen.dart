import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/website_blocking_viewmodel.dart';
import '../models/website_info.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class WebsiteBlockingScreen extends ConsumerStatefulWidget {
  const WebsiteBlockingScreen({super.key});

  @override
  ConsumerState<WebsiteBlockingScreen> createState() => _WebsiteBlockingScreenState();
}

class _WebsiteBlockingScreenState extends ConsumerState<WebsiteBlockingScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final websitesState = ref.watch(websiteBlockingViewModelProvider);
    final blockedCount = ref.watch(blockedWebsitesCountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildInfoBanner(blockedCount),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  'Restricted Domains',
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
            child: websitesState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (websites) => _buildWebsitesList(websites),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: _buildFAB(),
      ),
    );
  }

  Widget _buildInfoBanner(int blockedCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.public_off_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Filtering',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Browsers will be blocked during focus.',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (blockedCount > 0)
            IconButton(
              onPressed: _showClearDialog,
              icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.error),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebsitesList(List<WebsiteInfo> websites) {
    if (websites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language_rounded, size: 64, color: AppColors.surface),
            const SizedBox(height: 16),
            const Text(
              'No blocked websites yet',
              style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: websites.length,
      itemBuilder: (context, index) {
        final website = websites[index];
        return _buildWebsiteCard(website);
      },
    );
  }

  Widget _buildWebsiteCard(WebsiteInfo website) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link_rounded, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  website.url,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  website.isBlocked ? 'Is restricted' : 'Is allowed',
                  style: TextStyle(
                    color: website.isBlocked ? AppColors.error : AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: website.isBlocked,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
            onChanged: (_) => ref.read(websiteBlockingViewModelProvider.notifier).toggleWebsiteBlock(website.url),
          ),
          IconButton(
            onPressed: () => ref.read(websiteBlockingViewModelProvider.notifier).removeWebsite(website.url),
            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddWebsiteDialog,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Domain', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showAddWebsiteDialog() {
    _urlController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add to Shield', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              style: const TextStyle(color: AppColors.text),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., youtube.com',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.language_rounded, color: AppColors.accent),
                filled: true,
                fillColor: AppColors.bg.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _addWebsite(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _addWebsite,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addWebsite() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(websiteBlockingViewModelProvider.notifier).addWebsite(url);
      Navigator.pop(context);
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Shield?', style: TextStyle(color: AppColors.text)),
        content: const Text('Remove all blocked domains?', style: TextStyle(color: AppColors.textDim)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep')),
          TextButton(
            onPressed: () {
              ref.read(websiteBlockingViewModelProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

