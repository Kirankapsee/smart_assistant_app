import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/api_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit({ChatRepository? repository})
      : _repository = repository ?? ChatRepository(),
        super(ChatIdle(messages: [])) {
    _loadHistory();
  }

  bool get isSending => state is ChatSending;

  // ── Restore persisted messages ────────────────────────────
  void _loadHistory() {
    final history = _repository.loadLocalHistory();
    emit(ChatIdle(messages: history));
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      message: text.trim(),
      sender: MessageSender.user,
    );
    final updatedMessages = [...state.messages, userMsg];

    emit(ChatSending(messages: updatedMessages));

    try {
      final reply = await _repository.sendMessage(text.trim());
      final assistantMsg = ChatMessage(
        message: reply,
        sender: MessageSender.assistant,
      );
      final finalMessages = [...updatedMessages, assistantMsg];
      await _repository.saveHistory(finalMessages);
      emit(ChatIdle(messages: finalMessages));
    } catch (e) {
      emit(ChatError(
        messages: state.messages,
        errorMessage: _errorMessage(e),
      ));
    }
  }

  // ── Convenience shortcut from suggestion tap ──────────────
  Future<void> useSuggestion(String prompt) => sendMessage(prompt);

  // ── Clear history ─────────────────────────────────────────
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    emit(const ChatIdle(messages: []));
  }

  String _errorMessage(Object e) {
    if (e is NetworkException) return 'No internet connection.';
    if (e is ServerException) return 'Server error (${e.statusCode}). Please try again.';
    if (e is ParseException) return 'Unexpected response from server.';
    if (e is ApiException) return e.message;
    return 'Failed to send. Please try again.';
  }
}
