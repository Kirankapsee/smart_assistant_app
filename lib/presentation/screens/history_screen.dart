import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/chat_message_model.dart';
import '../cubits/chat/chat_cubit.dart';
import '../widgets/common_widgets.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (_, state) => state.messages.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClear(context))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state.messages.isEmpty) {
            return EmptyState(
              icon: Icons.history_rounded,
              title: 'No history yet',
              subtitle: 'Your conversations will appear here',
              action: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChatScreen())),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Start chatting'),
              ),
            );
          }

          final grouped = _groupByDate(state.messages);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped[index];
              if (entry is String) {
                return _buildDateDivider(entry, theme);
              }
              return _buildHistoryTile(
                  context, entry as ChatMessage, theme, isDark);
            },
          );
        },
      ),
    );
  }

  List<dynamic> _groupByDate(List<ChatMessage> messages) {
    final result = <dynamic>[];
    String? lastDate;
    for (final msg in messages.reversed) {
      final dateStr = _formatDate(msg.timestamp);
      if (dateStr != lastDate) {
        result.add(dateStr);
        lastDate = dateStr;
      }
      result.add(msg);
    }
    return result;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  Widget _buildDateDivider(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ]),
    );
  }

  Widget _buildHistoryTile(
      BuildContext context, ChatMessage msg, ThemeData theme, bool isDark) {
    final isUser = msg.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser
            ? AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08)
            : isDark
                ? AppTheme.darkCard
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUser
              ? AppTheme.primary.withOpacity(0.3)
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppTheme.divider,
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: isUser
                ? null
                : const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent]),
            color: isUser ? AppTheme.primary.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isUser ? Icons.person_rounded : Icons.auto_awesome,
            color: isUser ? AppTheme.primary : Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  isUser ? 'You' : 'Assistant',
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: isUser ? AppTheme.primary : null, fontSize: 13),
                ),
                const Spacer(),
                Text(DateFormat('h:mm a').format(msg.timestamp),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ]),
              const SizedBox(height: 4),
              Text(msg.message,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear history?'),
        content:
            const Text('All chat history will be permanently deleted.'),
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
