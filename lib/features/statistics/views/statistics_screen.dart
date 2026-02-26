import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/features/statistics/viewmodels/statistics_viewmodel.dart';
import 'package:focusguard/features/session_history/viewmodels/session_history_viewmodel.dart';
import 'package:focusguard/features/achievements/viewmodels/achievements_viewmodel.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekSessions = ref.watch(weekSessionsProvider);
    final topBlockedApps = ref.watch(topBlockedAppsProvider);
    final achievements = ref.watch(allAchievementsProvider);
    final totalFocusTime = ref.watch(totalFocusTimeProvider);
    final totalBlocks = ref.watch(totalBlocksStatProvider);
    final completedCount = ref.watch(completedSessionsCountProvider);
    final peakStreak = ref.watch(peakFlowStreakProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background organic blobs
          Positioned(
            top: 100,
            left: -100,
            child: _buildBlurCircle(
              300,
              AppColors.accent.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildOverviewSection(
                        totalFocusTime,
                        completedCount,
                        totalBlocks,
                        peakStreak,
                      ),
                      const SizedBox(height: 40),
                      _buildSectionTitle('Weekly Performance'),
                      const SizedBox(height: 16),
                      weekSessions.when(
                        data: (sessions) =>
                            _buildModernWeeklyChart(sessions),
                        error: (_, _) =>
                            _buildErrorState('Failed to load activity'),
                        loading: () => _buildLoadingState(),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionTitle('Focus Disruptors'),
                      const SizedBox(height: 16),
                      topBlockedApps.when(
                        data: (apps) => _buildBlockedAppsList(apps),
                        error: (_, _) => const SizedBox(),
                        loading: () => _buildLoadingState(),
                      ),
                      const SizedBox(height: 48),
                      _buildSectionTitle('Milestones'),
                      const SizedBox(height: 16),
                      achievements.when(
                        data: (all) => _buildAchievementsGrid(all),
                        error: (_, _) => const SizedBox(),
                        loading: () => _buildLoadingState(),
                      ),
                      const SizedBox(height: 120),
                    ]),
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 80,
      centerTitle: false,
      title: Text(
        'Analytics Hub',
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
          fontSize: 28,
          letterSpacing: -1,
        ),
      ),
      floating: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildOverviewSection(
    int time,
    int sessions,
    int blocks,
    int peakStreak,
  ) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMetricCard(
                  'Deep Focus',
                  '$time',
                  'min',
                  Icons.spa_rounded,
                  Colors.indigo,
                  cardWidth,
                ),
                _buildMetricCard(
                  'Sessions',
                  '$sessions',
                  'done',
                  Icons.task_alt_rounded,
                  const Color(0xFF10B981),
                  cardWidth,
                ),
                _buildMetricCard(
                  'Blocks',
                  '$blocks',
                  'apps',
                  Icons.shield_rounded,
                  Colors.orange,
                  cardWidth,
                ),
                _buildMetricCard(
                  'Peak Flow',
                  '$peakStreak',
                  'days',
                  Icons.local_fire_department_rounded,
                  const Color(0xFFF43F5E),
                  cardWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String val,
    String unit,
    IconData icon,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                val,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernWeeklyChart(List<dynamic> sessions) {
    final maxValRaw = sessions.isEmpty
        ? 0
        : sessions
              .map((s) => (s.durationMinutes ?? 0) as int)
              .reduce((a, b) => a > b ? a : b);
    final maxVal = maxValRaw == 0 ? 1 : maxValRaw;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                // Mocking or mapping days to ensure 7 slots
                const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final session = sessions.length > index
                    ? sessions[index]
                    : null;
                final heightFactor = session != null
                    ? (session.durationMinutes as int) / maxVal
                    : 0.05;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      width: 14,
                      height: 120 * heightFactor.toDouble(),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.accentSecondary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          if (session != null)
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dayNames[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAppsList(List<dynamic> apps) {
    return Column(
      children: apps.take(3).map((app) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.app_blocking_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Blocked ${app.blockCount} times',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDim,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsGrid(List<dynamic> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.take(6).length,
      itemBuilder: (context, index) {
        final ach = achievements[index];
        return Opacity(
          opacity: ach.unlocked ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ach.unlocked
                    ? AppColors.success.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ach.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  ach.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() => const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
  );
  Widget _buildErrorState(String msg) => Center(child: Text(msg));
}
