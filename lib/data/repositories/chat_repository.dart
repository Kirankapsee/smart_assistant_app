import '../models/chat_message_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class ChatRepository {
  final ApiService _api;
  final LocalStorageService _storage;

  ChatRepository({
    ApiService? apiService,
    LocalStorageService? storageService,
  })  : _api = apiService ?? ApiService(),
        _storage = storageService ?? LocalStorageService();

  /// Sends a message to POST /chat and returns the assistant's reply.
  Future<String> sendMessage(String message) => _api.sendMessage(message);

  /// Fetches remote history from GET /chat/history.
  /// The app merges this with local history on first load if needed.
  Future<List<ChatMessage>> fetchRemoteHistory() =>
      _api.getChatHistory();

  // ── Local persistence (SharedPreferences) ─────────────────
  List<ChatMessage> loadLocalHistory() => _storage.loadChatHistory();

  Future<void> saveHistory(List<ChatMessage> messages) =>
      _storage.saveChatHistory(messages);

  Future<void> clearHistory() => _storage.clearChatHistory();
}
