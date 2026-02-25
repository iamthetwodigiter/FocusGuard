import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/focus_rules_viewmodel.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  @override
  Widget build(BuildContext context) {
    final rulesState = ref.watch(focusRulesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(
              280,
              AppColors.accentSecondary.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _buildBlurCircle(
              320,
              AppColors.accent.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildInfoSection(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Your Routines',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      _buildRulesCount(rulesState),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: rulesState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (error, _) => Center(child: Text('Error: $error')),
                    data: (rules) => _buildRulesList(rules),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
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
            'Smart Schedule',
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

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.accentSecondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automate Focus',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Set times for automatic focus sessions.',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCount(AsyncValue<List<FocusRule>> state) {
    final count = state.when(data: (l) => l.length, loading: () => 0, error: (error, stack) => 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count active',
        style: const TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRulesList(List<FocusRule> rules) {
    if (rules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded, size: 48, color: AppColors.surface),
            SizedBox(height: 16),
            Text('No routines yet', style: TextStyle(color: AppColors.textDim)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: rules.length,
      itemBuilder: (context, index) => _buildRuleCard(rules[index]),
    );
  }

  Widget _buildRuleCard(FocusRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rule.startTime.format(context)} — ${rule.endTime.format(context)}',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: rule.isEnabled,
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                onChanged: (_) => ref.read(focusRulesProvider.notifier).toggleRule(rule.id),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: rule.daysOfWeek.map((day) => _buildDayChip(day)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => ref.read(focusRulesProvider.notifier).deleteRule(rule.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error.withValues(alpha: 0.6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        day,
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddRuleDialog,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Routine', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showAddRuleDialog() {
    // Keeping logic as provided
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Focus Rule', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create a new scheduled focus session', style: TextStyle(color: AppColors.textDim)),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Rule Name',
                labelStyle: const TextStyle(color: AppColors.textDim),
                hintText: 'e.g., Morning Focus',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppColors.bg.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Full management coming soon', style: TextStyle(color: AppColors.accent, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
