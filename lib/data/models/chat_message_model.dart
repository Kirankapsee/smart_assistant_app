import 'dart:convert';

enum MessageSender { user, assistant }

class ChatMessage {
  final String message;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == MessageSender.user;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        message: json['message'] as String,
        sender: json['sender'] == 'user'
            ? MessageSender.user
            : MessageSender.assistant,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'sender': sender == MessageSender.user ? 'user' : 'assistant',
        'timestamp': timestamp.toIso8601String(),
      };

  static List<ChatMessage> listFromJson(String jsonStr) {
    final List decoded = json.decode(jsonStr) as List;
    return decoded
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<ChatMessage> messages) =>
      json.encode(messages.map((m) => m.toJson()).toList());
}
