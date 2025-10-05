import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:game_explorer/core/model/game_model.dart';
import 'package:http/http.dart' as http;
import 'package:game_explorer/core/config/api_config.dart';

class ApiService {
  Future<List<GameModel>> getFeaturedGames() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.featuredCategoriesUrl),
      );

      debugPrint('Featured categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API response keys: ${data.keys.toList()}');

        final List<GameModel> games = [];
        List<dynamic> gameItems = [];

        if (data['specials'] != null && data['specials']['items'] != null) {
          gameItems.addAll(data['specials']['items']);
        }
        if (data['new_releases'] != null && data['new_releases']['items'] != null) {
          gameItems.addAll(data['new_releases']['items']);
        }
        if (data['top_sellers'] != null && data['top_sellers']['items'] != null) {
          gameItems.addAll(data['top_sellers']['items']);
        }

        debugPrint('Total game items found: ${gameItems.length}');

        final limitedItems = gameItems.take(20).toList();

        for (var item in limitedItems) {
          final gameId = item['id'];
          if (gameId != null) {
            debugPrint('Fetching game details for ID: $gameId');
            final gameDetail = await getGameDetails(gameId);
            if (gameDetail != null && gameDetail.name.length <= 18) {
              games.add(gameDetail);
            }
          }
        }

        debugPrint('Successfully loaded ${games.length} games');
        return games;
      } else {
        throw Exception('Failed to load featured games: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getFeaturedGames: $e');
      throw Exception('Error fetching featured games: $e');
    }
  }

  Future<Map<String, dynamic>?> getGameReviews(int appId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.appReviewsUrl(appId)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['query_summary'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching reviews for game $appId: $e');
      return null;
    }
  }

  Future<GameModel?> getGameDetails(int appId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.appDetailsUrl(appId)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['$appId'] != null && data['$appId']['success'] == true) {
          // Fetch reviews separately
          final reviewsData = await getGameReviews(appId);

          return GameModel.fromJson(data['$appId'], reviewsData: reviewsData);
        }
        return null;
      } else {
        throw Exception('Failed to load game details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching game $appId: $e');
      return null;
    }
  }
}
