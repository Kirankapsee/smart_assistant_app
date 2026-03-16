class AppConstants {
  // ── API ───────────────────────────────────────────────────
  // 🔧 Replace with your real backend base URL before running.
  // Example: 'https://api.myassistant.com'
  // For local dev:  'http://10.0.2.2:3000'  (Android emulator)
  //                 'http://localhost:3000'  (iOS simulator)
  static const String baseUrl = 'https://YOUR_API_BASE_URL_HERE';

  // Endpoints
  static const String endpointSuggestions = '/suggestions';
  static const String endpointChat = '/chat';
  static const String endpointChatHistory = '/chat/history';

  static const int defaultPageLimit = 10;

  // ── SharedPreferences keys ────────────────────────────────
  static const String keyThemeMode = 'theme_mode';
  static const String keyChatHistory = 'chat_history';

  // ── Durations ─────────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ── HTTP ──────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
