class ApiConfig {
  static const String steamApiKey = String.fromEnvironment('STEAM_API_KEY');
  
  static const String baseUrl = 'https://store.steampowered.com/api';
  
  static const String featuredCategoriesUrl =
      '$baseUrl/featuredcategories?cc=kr&l=ko';
  
  static String appDetailsUrl(int appId) =>
      '$baseUrl/appdetails?appids=$appId&cc=kr&l=ko';

  static String appReviewsUrl(int appId) =>
      'https://store.steampowered.com/appreviews/$appId?json=1&language=koreana&purchase_type=all';

  static bool get hasApiKey => steamApiKey.isNotEmpty;
}
