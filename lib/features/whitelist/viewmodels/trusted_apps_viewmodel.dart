import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrustedApp {
  final String packageName;
  final String appName;
  final bool isTrusted;

  TrustedApp({
    required this.packageName,
    required this.appName,
    required this.isTrusted,
  });
}

final trustedAppsProvider = StateNotifierProvider<TrustedAppsNotifier, AsyncValue<List<TrustedApp>>>((ref) {
  return TrustedAppsNotifier();
});

class TrustedAppsNotifier extends StateNotifier<AsyncValue<List<TrustedApp>>> {
  TrustedAppsNotifier() : super(const AsyncValue.loading()) {
    loadTrustedApps();
  }

  Future<void> loadTrustedApps() async {
    try {
      final trustedApps = [
        TrustedApp(packageName: 'com.google.android.messaging', appName: 'Messages', isTrusted: true),
        TrustedApp(packageName: 'com.google.android.dialer', appName: 'Phone', isTrusted: true),
        TrustedApp(packageName: 'com.android.clock', appName: 'Clock', isTrusted: false),
      ];
      state = AsyncValue.data(trustedApps);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleTrustedApp(String packageName) async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<TrustedApp>>).value;
      state = AsyncValue.data(
        currentData.map((app) {
          if (app.packageName == packageName) {
            return TrustedApp(
              packageName: app.packageName,
              appName: app.appName,
              isTrusted: !app.isTrusted,
            );
          }
          return app;
        }).toList(),
      );
    }
  }

  Future<void> clearAllTrusted() async {
    if (state is AsyncData) {
      final currentData = (state as AsyncData<List<TrustedApp>>).value;
      state = AsyncValue.data(
        currentData.map((app) {
          return TrustedApp(
            packageName: app.packageName,
            appName: app.appName,
            isTrusted: false,
          );
        }).toList(),
      );
    }
  }
}

final trustedAppsCountProvider = Provider<int>((ref) {
  final apps = ref.watch(trustedAppsProvider);
  return apps.whenData((list) => list.where((app) => app.isTrusted).length).value ?? 0;
});
