import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../cubits/chat/chat_cubit.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    _focusNode.requestFocus();
    await context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Assistant', style: theme.textTheme.titleMedium),
            Text('Always here to help',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
          ]),
        ]),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (_, state) => state.messages.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear chat',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmClear(context))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(child: _buildMessageList(isDark)),
        _buildInputBar(theme, isDark),
      ]),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (_, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ));
        }
        _scrollToBottom();
      },
      builder: (context, state) {
        final messages = state.messages;
        final isSending = state is ChatSending;

        if (messages.isEmpty && !isSending) {
          return EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Start a conversation',
            subtitle: 'Ask me anything or pick a suggestion from the home screen',
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: messages.length + (isSending ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && isSending) {
              return const TypingIndicator();
            }
            return ChatBubble(message: messages[index], showTimestamp: true);
          },
        );
      },
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppTheme.divider),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (_, state) {
          final isSending = state is ChatSending;
          return Row(children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                enabled: !isSending,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask me anything…',
                  hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5)),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkCard : AppTheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isSending
                  ? AppTheme.primary.withOpacity(0.5)
                  : AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isSending ? null : _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('All messages will be deleted. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ChatCubit>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
