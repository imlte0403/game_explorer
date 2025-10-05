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
  final List<String> developers;
  final List<String> publishers;
  final List<String> platforms;
  final List<String> screenshots;
  final String releaseDate;
  final String ageRating;
  final String multiplayerInfo;

  GameModel({
    required this.appId,
    required this.name,
    required this.headerImage,
    required this.backgroundImage,
    required this.price,
    required this.genres,
    required this.shortDescription,
    required this.rating,
    this.developers = const [],
    this.publishers = const [],
    this.platforms = const [],
    this.screenshots = const [],
    this.releaseDate = '',
    this.ageRating = '',
    this.multiplayerInfo = '',
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

    final headerImg = _firstNonEmpty([...capsuleCandidates, backgroundImg]);

    List<String> developersList = [];
    try {
      if (data['developers'] != null && data['developers'] is List) {
        developersList = (data['developers'] as List)
            .map((dev) => dev.toString())
            .toList();
      }
    } catch (e) {
      developersList = [];
    }

    List<String> publishersList = [];
    try {
      if (data['publishers'] != null && data['publishers'] is List) {
        publishersList = (data['publishers'] as List)
            .map((pub) => pub.toString())
            .toList();
      }
    } catch (e) {
      publishersList = [];
    }

    List<String> platformsList = [];
    try {
      if (data['platforms'] != null && data['platforms'] is Map) {
        final platforms = data['platforms'] as Map<String, dynamic>;
        if (platforms['windows'] == true) platformsList.add('windows');
        if (platforms['mac'] == true) platformsList.add('mac');
        if (platforms['linux'] == true) platformsList.add('linux');
      }
    } catch (e) {
      platformsList = [];
    }

    List<String> screenshotsList = [];
    try {
      if (data['screenshots'] != null && data['screenshots'] is List) {
        screenshotsList = (data['screenshots'] as List)
            .where((screenshot) => screenshot['path_full'] != null)
            .map((screenshot) => screenshot['path_full'].toString())
            .toList();
      }
    } catch (e) {
      screenshotsList = [];
    }

    String releaseDate = '';
    try {
      if (data['release_date'] != null && data['release_date']['date'] != null) {
        releaseDate = data['release_date']['date'].toString();
      }
    } catch (e) {
      releaseDate = '';
    }

    String ageRating = '';
    try {
      if (data['required_age'] != null) {
        final age = data['required_age'];
        if (age == 0) {
          ageRating = '전체 이용가';
        } else {
          ageRating = '$age세 이용가';
        }
      }
    } catch (e) {
      ageRating = '';
    }

    String multiplayerInfo = '싱글플레이어';
    try {
      if (data['categories'] != null && data['categories'] is List) {
        final categories = data['categories'] as List;
        final hasMultiplayer = categories.any((cat) =>
          cat['description']?.toString().toLowerCase().contains('multi') ?? false
        );
        final hasCoop = categories.any((cat) =>
          cat['description']?.toString().toLowerCase().contains('co-op') ?? false
        );

        if (hasMultiplayer && hasCoop) {
          multiplayerInfo = '멀티플레이어 / Co-op';
        } else if (hasMultiplayer) {
          multiplayerInfo = '멀티플레이어';
        } else if (hasCoop) {
          multiplayerInfo = 'Co-op';
        }
      }
    } catch (e) {
      multiplayerInfo = '싱글플레이어';
    }

    return GameModel(
      appId: data['steam_appid'] ?? 0,
      name: data['name'] ?? 'Unknown',
      headerImage: headerImg,
      backgroundImage: backgroundImg,
      price: priceText,
      genres: genresList,
      shortDescription: data['short_description'] ?? '',
      rating: ratingText,
      developers: developersList,
      publishers: publishersList,
      platforms: platformsList,
      screenshots: screenshotsList,
      releaseDate: releaseDate,
      ageRating: ageRating,
      multiplayerInfo: multiplayerInfo,
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
      'developers': developers,
      'publishers': publishers,
      'platforms': platforms,
      'screenshots': screenshots,
      'releaseDate': releaseDate,
      'ageRating': ageRating,
      'multiplayerInfo': multiplayerInfo,
    };
  }
}
