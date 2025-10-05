import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_explorer/core/model/game_model.dart';
import 'package:game_explorer/core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final featuredGamesProvider = FutureProvider<List<GameModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getFeaturedGames();
});

final gameDetailProvider = FutureProvider.family<GameModel?, int>((ref, appId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getGameDetails(appId);
});

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<int>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<List<int>> {
  WishlistNotifier() : super([]);

  void addToWishlist(int gameId) {
    if (!state.contains(gameId)) {
      state = [...state, gameId];
    }
  }

  void removeFromWishlist(int gameId) {
    state = state.where((id) => id != gameId).toList();
  }

  bool isInWishlist(int gameId) {
    return state.contains(gameId);
  }
}