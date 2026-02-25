import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/website_info.dart';
import '../repositories/website_repository.dart';

final websiteRepositoryProvider = Provider((ref) => WebsiteRepository());

final websiteBlockingViewModelProvider =
    StateNotifierProvider<WebsiteBlockingViewModel, AsyncValue<List<WebsiteInfo>>>(
  (ref) {
    final viewModel = WebsiteBlockingViewModel(ref.read(websiteRepositoryProvider));
    viewModel.loadWebsites();
    return viewModel;
  },
);

final blockedWebsitesCountProvider = Provider<int>((ref) {
  final state = ref.watch(websiteBlockingViewModelProvider);
  return state.maybeWhen(
    data: (websites) => websites.where((w) => w.isBlocked).length,
    orElse: () => 0,
  );
});

class WebsiteBlockingViewModel extends StateNotifier<AsyncValue<List<WebsiteInfo>>> {
  final WebsiteRepository _repository;

  WebsiteBlockingViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> loadWebsites() async {
    state = const AsyncValue.loading();
    try {
      final websites = await _repository.getAllWebsites();
      state = AsyncValue.data(websites);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWebsite(String url) async {
    try {
      await _repository.addWebsite(url);
      await loadWebsites();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleWebsiteBlock(String url) async {
    try {
      await _repository.toggleWebsiteBlock(url);
      await loadWebsites();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeWebsite(String url) async {
    try {
      await _repository.removeWebsite(url);
      await loadWebsites();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      await loadWebsites();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
