import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';
import '../viewmodels/session_history_viewmodel.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(sessionHistoryProvider);
    final totalTime = ref.watch(totalFocusTimeProvider);
    final completedCount = ref.watch(completedSessionsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlurCircle(
              300,
              AppColors.accent.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlurCircle(
              250,
              AppColors.accentSecondary.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildOverviewStats(totalTime, completedCount),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Recent Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${stateToSessionsCount(sessionsState)} items',
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
                  child: sessionsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (error, _) => Center(child: Text('Error: $error')),
                    data: (sessions) => _buildSessionsList(context, ref, sessions),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int stateToSessionsCount(AsyncValue<List<FocusSession>> state) {
    return state.when(
      data: (s) => s.length,
      loading: () => 0,
      error: (error, stack) => 0,
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
            'Focus Logs',
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

  Widget _buildOverviewStats(int totalTime, int sessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              'Total Time',
              '$totalTime',
              'min',
              Icons.timer_rounded,
              AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricItem(
              'Sessions',
              '$sessions',
              'completed',
              Icons.check_circle_rounded,
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
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
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDim,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, WidgetRef ref, List<FocusSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.textDim.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'No history yet',
              style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, ref, session);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref, FocusSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.success, size: 20),
            ),
            title: Text(
              '${session.durationMinutes} min Session',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _formatDate(session.startTime),
              style: const TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
            trailing: const Icon(Icons.expand_more_rounded, color: AppColors.textDim),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeInfo('Started', _formatTime(session.startTime)),
                        _buildTimeInfo('Ended', session.endTime != null ? _formatTime(session.endTime!) : '--:--'),
                        _buildTimeInfo('Blocks', '${session.blockedAppsCount} apps'),
                      ],
                    ),
                    if (session.blockedAppsPackages.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'BLOCKED APPS',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: session.blockedAppsPackages.map((app) => _buildAppTag(app)).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => ref.read(sessionHistoryProvider.notifier).deleteSession(session.sessionId),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete Log'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error.withValues(alpha: 0.7),
                          backgroundColor: AppColors.error.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildAppTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        name,
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
