class ApiConfig {
  static const String defaultApiBaseUrl = 'http://localhost:1337';

  static String get apiBaseUrl {
    const apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl.trim().isNotEmpty) {
      return apiUrl.trim().replaceAll(RegExp(r'/+$'), '');
    }

    return defaultApiBaseUrl;
  }
}
