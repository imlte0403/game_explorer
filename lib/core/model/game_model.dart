String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

class GameModel {
  final int appId;
  final String name;
  final String headerImage;
  final String backgroundImage;
  final String price;
  final List<String> genres;
  final String shortDescription;
  final String rating;

  GameModel({
    required this.appId,
    required this.name,
    required this.headerImage,
    required this.backgroundImage,
    required this.price,
    required this.genres,
    required this.shortDescription,
    required this.rating,
  });

  factory GameModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? reviewsData,
  }) {
    final data = json['data'] ?? json;

    List<String> genresList = [];
    if (data['genres'] != null) {
      genresList = (data['genres'] as List)
          .map((genre) => genre['description'].toString())
          .toList();
    }

    String priceText = 'Free';
    if (data['price_overview'] != null) {
      priceText = data['price_overview']['final_formatted'] ?? 'N/A';
    } else if (data['is_free'] == true) {
      priceText = 'Free';
    }

    String ratingText = '평가 없음';
    if (reviewsData != null && reviewsData['total_reviews'] != null) {
      final totalReviews = reviewsData['total_reviews'] as int;
      final totalPositive = reviewsData['total_positive'] as int? ?? 0;

      if (totalReviews > 0) {
        final positiveRatio = (totalPositive / totalReviews) * 100;

        if (positiveRatio >= 95) {
          ratingText = '압도적으로 긍정적';
        } else if (positiveRatio >= 80) {
          ratingText = '매우 긍정적';
        } else if (positiveRatio >= 70) {
          ratingText = '대체로 긍정적';
        } else if (positiveRatio >= 40) {
          ratingText = '복합적';
        } else if (positiveRatio >= 20) {
          ratingText = '대체로 부정적';
        } else if (positiveRatio >= 10) {
          ratingText = '매우 부정적';
        } else {
          ratingText = '압도적으로 부정적';
        }
      }
    }

    final libraryAssets = (data['library_assets'] as Map?) ?? const {};
    final libraryCapsule =
        (libraryAssets['library_capsule'] as Map?) ?? const <String, dynamic>{};

    final capsuleCandidates = <String?>[
      data['header_image'] as String?,
      libraryCapsule['image'] as String?,
      libraryCapsule['image2x'] as String?,
      data['capsule_imagev5'] as String?,
      data['capsule_image'] as String?,
    ];

    final backgroundImg = _firstNonEmpty([
      data['background_raw'] as String?,
      data['background'] as String?,
      data['header_image'] as String?,
    ]);

    final headerImg = _firstNonEmpty([
      ...capsuleCandidates,
      backgroundImg,
    ]);

    return GameModel(
      appId: data['steam_appid'] ?? 0,
      name: data['name'] ?? 'Unknown',
      headerImage: headerImg,
      backgroundImage: backgroundImg,
      price: priceText,
      genres: genresList,
      shortDescription: data['short_description'] ?? '',
      rating: ratingText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'name': name,
      'headerImage': headerImage,
      'backgroundImage': backgroundImage,
      'price': price,
      'genres': genres,
      'shortDescription': shortDescription,
      'rating': rating,
    };
  }
}
