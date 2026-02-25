import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/storage/hive_service.dart';
import '../models/app_info.dart';
import '../repositories/app_repository.dart';

/// Provider for AppRepository
final appRepositoryProvider = Provider<AppRepository>((ref) {
  final box = HiveService.getBox(AppConstants.blockedAppsBox);
  return AppRepository(box);
});

/// State for installed apps list
final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final repository = ref.read(appRepositoryProvider);
  return repository.getInstalledApps();
});

/// State for blocked apps list
final blockedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final repository = ref.read(appRepositoryProvider);
  return repository.getBlockedApps();
});

/// State for blocked apps count - optimized to only count without scanning all apps
final blockedAppsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(appRepositoryProvider);
  return repository.getBlockedPackageNames().length;
});

/// ViewModel for App Selection screen - optimized for performance
class AppSelectionViewModel extends StateNotifier<AsyncValue<List<AppInfo>>> {
  final AppRepository _repository;
  final Ref _ref;

  AppSelectionViewModel(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadApps();
  }

  /// Load all installed apps
  Future<void> loadApps() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _repository.getInstalledApps();
      state = AsyncValue.data(apps);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Toggle block status for a single app - OPTIMIZED: doesn't reload all apps
  Future<void> toggleAppBlock(String packageName) async {
    await _repository.toggleAppBlock(packageName);
    
    // Invalidate providers instead of reloading all apps
    _ref.invalidate(blockedAppsProvider);
    _ref.invalidate(blockedAppsCountProvider);
    
    // Update local state optimistically
    state.whenData((apps) {
      final updatedApps = apps.map((app) {
        if (app.packageName == packageName) {
          return AppInfo(
            packageName: app.packageName,
            appName: app.appName,
            icon: app.icon,
            isBlocked: !app.isBlocked,
          );
        }
        return app;
      }).toList();
      state = AsyncValue.data(updatedApps);
    });
  }

  /// Search/filter apps by name
  void searchApps(String query) {
    state.whenData((apps) {
      if (query.isEmpty) {
        // Reset to full list
        loadApps();
      } else {
        final filtered = apps
            .where((app) =>
                app.appName.toLowerCase().contains(query.toLowerCase()))
            .toList();
        state = AsyncValue.data(filtered);
      }
    });
  }

  /// Block selected apps
  Future<void> blockSelectedApps(List<String> packageNames) async {
    await _repository.blockApps(packageNames);
    // Invalidate instead of reloading
    _ref.invalidate(blockedAppsProvider);
    _ref.invalidate(blockedAppsCountProvider);
    await loadApps();
  }

  /// Unblock selected apps
  Future<void> unblockSelectedApps(List<String> packageNames) async {
    await _repository.unblockApps(packageNames);
    // Invalidate instead of reloading
    _ref.invalidate(blockedAppsProvider);
    _ref.invalidate(blockedAppsCountProvider);
    await loadApps();
  }

  /// Clear all blocks
  Future<void> clearAllBlocks() async {
    await _repository.clearAllBlockedApps();
    // Invalidate instead of reloading
    _ref.invalidate(blockedAppsProvider);
    _ref.invalidate(blockedAppsCountProvider);
    await loadApps();
  }
}

/// Provider for AppSelectionViewModel - pass Ref to enable invalidation
final appSelectionViewModelProvider =
    StateNotifierProvider<AppSelectionViewModel, AsyncValue<List<AppInfo>>>(
  (ref) {
    final repository = ref.read(appRepositoryProvider);
    return AppSelectionViewModel(repository, ref);
  },
);
