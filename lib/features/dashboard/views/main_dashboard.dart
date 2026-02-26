import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/core/constants/app_constants.dart';
import 'package:focusguard/features/focus_session/views/home_screen.dart';
import 'package:focusguard/features/statistics/views/statistics_screen.dart';
import 'package:focusguard/features/app_selection/views/app_selection_screen.dart';
import 'package:focusguard/features/website_blocking/views/website_blocking_screen.dart';
import 'package:focusguard/features/whitelist/views/whitelist_screen.dart';
import 'package:focusguard/features/scheduling/views/scheduling_screen.dart';
import 'package:focusguard/features/session_history/views/session_history_screen.dart';
import 'package:focusguard/features/achievements/views/achievements_screen.dart';
import 'package:focusguard/features/settings/views/settings_screen.dart';
import 'package:focusguard/features/developer/views/developer_screen.dart';
import 'package:focusguard/core/theme/app_theme.dart';
import 'package:focusguard/services/native_bridge/android_service_bridge.dart';
import 'package:focusguard/services/routine_supervisor.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard> {
  @override
  void initState() {
    super.initState();
    // Start the routine supervisor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineSupervisorProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context, currentTab, isDark),
      drawer: _buildDrawer(context, isDark),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg, AppColors.bg],
          ),
        ),
        child: _buildTabContent(currentTab),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, currentTab, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int currentTab,
    bool isDark,
  ) {
    final titles = ['FocusCore', 'Analytics', 'App Control', 'Web Filters'];

    return AppBar(
      title: Text(
        titles[currentTab],
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await AndroidServiceBridge.exitApp();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: AppColors.bg,
      width: MediaQuery.of(context).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDrawerSection('Core Controls'),
                _buildDrawerItem(
                  context,
                  Icons.verified_user_rounded,
                  'Trusted Apps',
                  'Management of system whitelist',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WhitelistScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.calendar_today_rounded,
                  'Schedules',
                  'Timed focus sessions',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SchedulingScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerSection('Data & Progress'),
                _buildDrawerItem(
                  context,
                  Icons.history_rounded,
                  'Focus Logs',
                  'Review past sessions',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SessionHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.emoji_events_rounded,
                  'Milestones',
                  'Unlocked achievements',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
                // const Padding(
                //   padding: EdgeInsets.all(5),
                //   child: Divider(color: Colors.white10),
                // ),
                // _buildDrawerItem(
                //   context,
                //   Icons.settings_rounded,
                //   'Preferences',
                //   'App settings and privacy',
                //   () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (_) => const SettingsScreen()),
                //     );
                //   },
                // ),
                _buildDrawerSection('About'),
                _buildDrawerItem(
                  context,
                  Icons.terminal_rounded,
                  'Developer',
                  'Meet the creator',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeveloperScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'FocusGuard',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Productivity & Protection',
            style: TextStyle(
              color: AppColors.textDim.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12, top: 12),
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

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textDim.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 5, 32, 48),
      child: Row(
        children: [
          Text(
            'App Version',
            style: TextStyle(
              color: AppColors.accent.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              AppConstants.appVersion,
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    int currentTab,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            ref,
            0,
            Icons.bolt_rounded,
            'Focus',
            currentTab,
            isDark,
          ),
          _buildNavItem(
            ref,
            1,
            Icons.auto_graph_rounded,
            'Data',
            currentTab,
            isDark,
          ),
          _buildNavItem(
            ref,
            2,
            Icons.grid_view_rounded,
            'Apps',
            currentTab,
            isDark,
          ),
          _buildNavItem(
            ref,
            3,
            Icons.public_rounded,
            'Web',
            currentTab,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
    int currentTab,
    bool isDark,
  ) {
    final isSelected = currentTab == index;
    const accent = AppColors.accent;

    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? accent : AppColors.textDim),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const StatisticsScreen();
      case 2:
        return const AppSelectionScreen();
      case 3:
        return const WebsiteBlockingScreen();
      default:
        return const HomeScreen();
    }
  }
}
