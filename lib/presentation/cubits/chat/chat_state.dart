part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  const ChatState({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// Idle – no pending operation.
class ChatIdle extends ChatState {
  const ChatIdle({required super.messages});
}

/// A message has been sent and we're waiting for the reply.
class ChatSending extends ChatState {
  const ChatSending({required super.messages});
}

/// An error occurred while sending.
class ChatError extends ChatState {
  final String errorMessage;
  const ChatError({required super.messages, required this.errorMessage});

  @override
  List<Object?> get props => [messages, errorMessage];
}
