import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_assistant_app/core/theme/app_theme.dart';
import 'package:smart_assistant_app/data/models/chat_message_model.dart';
import 'package:smart_assistant_app/data/models/suggestion_model.dart';
import 'package:smart_assistant_app/presentation/cubits/chat/chat_cubit.dart';
import 'package:smart_assistant_app/presentation/cubits/suggestions/suggestions_cubit.dart';
import 'package:smart_assistant_app/presentation/cubits/theme/theme_cubit.dart';
import 'package:smart_assistant_app/presentation/widgets/chat_bubble.dart';
import 'package:smart_assistant_app/presentation/widgets/common_widgets.dart';

// ── Helpers ───────────────────────────────────────────────
Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );


// ── Model tests ───────────────────────────────────────────
void main() {
  group('ChatMessage model', () {
    test('fromJson parses user message correctly', () {
      final msg = ChatMessage.fromJson({
        'sender': 'user',
        'message': 'Hello!',
        'timestamp': '2024-01-01T10:00:00.000Z',
      });
      expect(msg.message, 'Hello!');
      expect(msg.sender, MessageSender.user);
      expect(msg.isUser, isTrue);
    });

    test('fromJson parses assistant message correctly', () {
      final msg = ChatMessage.fromJson({
        'sender': 'assistant',
        'message': 'Hi there!',
        'timestamp': '2024-01-01T10:00:01.000Z',
      });
      expect(msg.sender, MessageSender.assistant);
      expect(msg.isUser, isFalse);
    });

    test('toJson / fromJson round-trip', () {
      final original = ChatMessage(
        message: 'Test message',
        sender: MessageSender.user,
        timestamp: DateTime(2024, 6, 15, 9, 30),
      );
      final restored = ChatMessage.fromJson(original.toJson());
      expect(restored.message, original.message);
      expect(restored.sender, original.sender);
    });

    test('listToJson / listFromJson round-trip', () {
      final messages = [
        ChatMessage(message: 'Hi', sender: MessageSender.user),
        ChatMessage(message: 'Hello!', sender: MessageSender.assistant),
      ];
      final restored =
          ChatMessage.listFromJson(ChatMessage.listToJson(messages));
      expect(restored.length, 2);
      expect(restored[0].message, 'Hi');
      expect(restored[1].isUser, isFalse);
    });
  });

  group('Suggestion model', () {
    test('fromJson parses correctly', () {
      final s = Suggestion.fromJson(
          {'id': 1, 'title': 'Summarize', 'description': 'Get a summary'});
      expect(s.id, 1);
      expect(s.title, 'Summarize');
    });

    test('PaginationMeta fromJson', () {
      final p = PaginationMeta.fromJson({
        'current_page': 1,
        'total_pages': 5,
        'total_items': 50,
        'limit': 10,
        'has_next': true,
        'has_previous': false,
      });
      expect(p.hasNext, isTrue);
      expect(p.hasPrevious, isFalse);
      expect(p.totalPages, 5);
    });
  });

  // ── Cubit unit tests ──────────────────────────────────────
  group('SuggestionsCubit', () {
    test('initial state is SuggestionsInitial', () {
      final cubit = SuggestionsCubit();
      expect(cubit.state, isA<SuggestionsInitial>());
    });

    test('fetchSuggestions emits Loading then Loaded', () async {
      final cubit = SuggestionsCubit();
      await expectLater(
        cubit.stream,
        emitsInOrder([
          isA<SuggestionsLoading>(),
          isA<SuggestionsLoaded>(),
        ]),
      );
      cubit.fetchSuggestions();
    });

    test('loaded state contains suggestions', () async {
      final cubit = SuggestionsCubit();
      await cubit.fetchSuggestions();
      expect(cubit.state, isA<SuggestionsLoaded>());
      expect((cubit.state as SuggestionsLoaded).suggestions, isNotEmpty);
    });

    test('loadNextPage appends more suggestions', () async {
      final cubit = SuggestionsCubit();
      await cubit.fetchSuggestions();
      final before = (cubit.state as SuggestionsLoaded).suggestions.length;
      await cubit.loadNextPage();
      final after = (cubit.state as SuggestionsLoaded).suggestions.length;
      expect(after, greaterThan(before));
    });

    test('isLoadingMore is true during loadNextPage', () async {
      final cubit = SuggestionsCubit();
      await cubit.fetchSuggestions();

      bool sawLoadingMore = false;
      final sub = cubit.stream.listen((state) {
        if (state is SuggestionsLoaded && state.isLoadingMore) {
          sawLoadingMore = true;
        }
      });
      await cubit.loadNextPage();
      await sub.cancel();
      expect(sawLoadingMore, isTrue);
    });

    test('SuggestionsLoaded.copyWith updates correctly', () {
      const meta = PaginationMeta(
          currentPage: 1,
          totalPages: 3,
          totalItems: 30,
          limit: 10,
          hasNext: true,
          hasPrevious: false);
      const original = SuggestionsLoaded(suggestions: [], pagination: meta);
      final copy = original.copyWith(isLoadingMore: true);
      expect(copy.isLoadingMore, isTrue);
      expect(copy.suggestions, isEmpty);
    });
  });

  group('ChatCubit', () {
    test('initial state has empty messages', () {
      final cubit = ChatCubit();
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state, isA<ChatIdle>());
    });

    test('sendMessage adds user + assistant messages', () async {
      final cubit = ChatCubit();
      await cubit.sendMessage('Hello');
      expect(cubit.state.messages.length, 2);
      expect(cubit.state.messages[0].isUser, isTrue);
      expect(cubit.state.messages[1].isUser, isFalse);
    });

    test('state is ChatSending while awaiting reply', () async {
      final cubit = ChatCubit();
      bool wasSendingDuringCall = false;
      final future = cubit.sendMessage('Test').then((_) {
        wasSendingDuringCall = cubit.isSending;
      });
      expect(cubit.isSending, isTrue);
      await future;
      expect(wasSendingDuringCall, isFalse);
    });

    test('clearHistory empties messages and emits ChatIdle', () async {
      final cubit = ChatCubit();
      await cubit.sendMessage('Hi');
      expect(cubit.state.messages, isNotEmpty);
      await cubit.clearHistory();
      expect(cubit.state, isA<ChatIdle>());
      expect(cubit.state.messages, isEmpty);
    });

    test('ChatState equality via Equatable', () {
      const s1 = ChatIdle(messages: []);
      const s2 = ChatIdle(messages: []);
      expect(s1, equals(s2));
    });
  });

  group('ThemeCubit', () {
    test('initial state isDark is false', () {
      final cubit = ThemeCubit();
      expect(cubit.state.isDark, isFalse);
    });

    test('toggle switches isDark', () async {
      final cubit = ThemeCubit();
      await cubit.toggle();
      expect(cubit.state.isDark, isTrue);
      await cubit.toggle();
      expect(cubit.state.isDark, isFalse);
    });
  });

  // ── Widget tests ──────────────────────────────────────────
  group('ChatBubble widget', () {
    testWidgets('renders user message', (tester) async {
      final msg =
          ChatMessage(message: 'Hello from user', sender: MessageSender.user);
      await tester.pumpWidget(
          _wrap(SizedBox(width: 400, child: ChatBubble(message: msg))));
      expect(find.text('Hello from user'), findsOneWidget);
    });

    testWidgets('renders assistant message', (tester) async {
      final msg = ChatMessage(
          message: 'Reply', sender: MessageSender.assistant);
      await tester.pumpWidget(
          _wrap(SizedBox(width: 400, child: ChatBubble(message: msg))));
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('shows timestamp when showTimestamp is true', (tester) async {
      final msg = ChatMessage(
        message: 'Test',
        sender: MessageSender.user,
        timestamp: DateTime(2024, 1, 1, 14, 30),
      );
      await tester.pumpWidget(_wrap(
          SizedBox(width: 400, child: ChatBubble(message: msg, showTimestamp: true))));
      expect(find.text('2:30 PM'), findsOneWidget);
    });
  });

  group('SuggestionCard widget', () {
    testWidgets('renders title and description', (tester) async {
      const s = Suggestion(id: 1, title: 'Test Title', description: 'Desc');
      await tester.pumpWidget(_wrap(const SuggestionCard(suggestion: s)));
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Desc'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      const s = Suggestion(id: 2, title: 'Tap me', description: 'desc');
      await tester.pumpWidget(
          _wrap(SuggestionCard(suggestion: s, onTap: () => tapped = true)));
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });
  });

  group('EmptyState widget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.inbox,
        title: 'Nothing here',
        subtitle: 'Come back later',
      )));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Come back later'), findsOneWidget);
    });
  });
}
