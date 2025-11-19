class AppConstants {
  static const String baseUrl =
  String.fromEnvironment('BASE_URL', defaultValue: '');

  static const String tokenKey =
  String.fromEnvironment('API_KEY', defaultValue: '');

  static const accessToken = 'accessToken';
  static const refreshToken = 'backendToken';
  static const id = 'id';
}
