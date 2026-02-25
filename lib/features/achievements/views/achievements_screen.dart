import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/features/achievements/viewmodels/achievements_viewmodel.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesState = ref.watch(badgesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -50,
            right: -100,
            child: _buildOrb(
              300,
              AppColors.accent.withValues(alpha: 0.1),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                badgesState.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (badges) {
                    final unlockedCount = badges
                        .where((b) => b.unlocked)
                        .length;
                    final total = badges.length;
                    final progress = total > 0 ? unlockedCount / total : 0.0;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 24),
                          _buildProgressHeader(
                            unlockedCount,
                            total,
                            progress,
                          ),
                          const SizedBox(height: 40),
                          _buildSectionTitle('Available Badges'),
                          const SizedBox(height: 16),
                          _buildBadgesGrid(context, badges),
                          const SizedBox(height: 40),
                          _buildSectionTitle('Active Tiers'),
                          const SizedBox(height: 16),
                          _buildTierCard(unlockedCount),
                          const SizedBox(height: 120),
                        ]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 80,
      title: Text(
        'Milestones',
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
          fontSize: 28,
          letterSpacing: -1,
        ),
      ),
      floating: true,
      centerTitle: false,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildProgressHeader(
    int unlocked,
    int total,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unlocked',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$unlocked / $total',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(
    BuildContext context,
    List<AchievementBadge> badges,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeItem(context, badge);
      },
    );
  }

  Widget _buildBadgeItem(
    BuildContext context,
    AchievementBadge badge,
  ) {
    const accent = AppColors.accent;

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: badge.unlocked
              ? accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: badge.unlocked
                ? accent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.03),
            width: 1.5,
          ),
          boxShadow: [
            if (badge.unlocked)
              BoxShadow(
                color: accent.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 36,
                color: badge.unlocked
                    ? null
                    : Colors.grey.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: badge.unlocked
                    ? AppColors.text
                    : AppColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(int unlocked) {
    String tierName = 'Squire';
    Color tierColor = Colors.grey;
    if (unlocked > 10) {
      tierName = 'Master';
      tierColor = AppColors.success;
    } else if (unlocked > 5) {
      tierName = 'Adept';
      tierColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.stars_rounded, color: tierColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Standing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDim,
                  ),
                ),
                Text(
                  tierName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: tierColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(
    BuildContext context,
    AchievementBadge badge,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(badge.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDim,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Inspiring'),
            ),
          ],
        ),
      ),
    );
  }
}
