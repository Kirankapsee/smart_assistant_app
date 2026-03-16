import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message_model.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw StateError('LocalStorageService not initialized');
    return _prefs!;
  }

  // ── Chat history ─────────────────────────────────────────
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    await _p.setString(
        AppConstants.keyChatHistory, ChatMessage.listToJson(messages));
  }

  List<ChatMessage> loadChatHistory() {
    final raw = _p.getString(AppConstants.keyChatHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      return ChatMessage.listFromJson(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> clearChatHistory() async {
    await _p.remove(AppConstants.keyChatHistory);
  }

  // ── Theme ────────────────────────────────────────────────
  Future<void> saveThemeMode(bool isDark) async {
    await _p.setBool(AppConstants.keyThemeMode, isDark);
  }

  bool loadIsDarkMode() => _p.getBool(AppConstants.keyThemeMode) ?? false;
}
