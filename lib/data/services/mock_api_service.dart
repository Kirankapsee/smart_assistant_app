import 'dart:math';

import '../models/chat_message_model.dart';
import '../models/suggestion_model.dart';
import 'api_service.dart';

/// Drop-in replacement for [ApiService] that returns hardcoded data
/// so the app is fully runnable without a real backend.
///
/// Usage — swap in main.dart or inject via repository constructor:
///   BlocProvider(create: (_) => SuggestionsCubit(
///     repository: SuggestionsRepository(apiService: MockApiService()),
///   ))
class MockApiService extends ApiService {
  MockApiService._() : super.protected();

  static final MockApiService _instance = MockApiService._();
  factory MockApiService() => _instance;

  final Random _rng = Random();

  static const List<Map<String, dynamic>> _suggestions = [
    {'id': 1,  'title': 'Summarize my notes',        'description': 'Get a concise summary of your lengthy text notes'},
    {'id': 2,  'title': 'Generate email reply',       'description': 'Create a professional email response instantly'},
    {'id': 3,  'title': 'Explain a concept',          'description': 'Break down complex topics into simple language'},
    {'id': 4,  'title': 'Write a cover letter',       'description': 'Craft a compelling job application cover letter'},
    {'id': 5,  'title': 'Debug my code',              'description': 'Find and fix bugs in your code snippets'},
    {'id': 6,  'title': 'Create a workout plan',      'description': 'Get a personalized fitness schedule for your goals'},
    {'id': 7,  'title': 'Plan a trip',                'description': 'Get itinerary ideas for your next vacation'},
    {'id': 8,  'title': 'Write a poem',               'description': 'Generate creative poetry on any theme'},
    {'id': 9,  'title': 'Translate text',             'description': 'Translate content into multiple languages accurately'},
    {'id': 10, 'title': 'Meal prep ideas',            'description': 'Get healthy and easy meal prep suggestions for the week'},
    {'id': 11, 'title': 'Brainstorm ideas',           'description': 'Generate creative ideas for projects or businesses'},
    {'id': 12, 'title': 'Write a social post',        'description': 'Craft engaging content for Instagram, LinkedIn, or X'},
    {'id': 13, 'title': 'Analyze my data',            'description': 'Get insights and patterns from your datasets'},
    {'id': 14, 'title': 'Create a study plan',        'description': 'Organize your learning schedule for exams'},
    {'id': 15, 'title': 'Draft a contract',           'description': 'Generate a simple legal contract template'},
    {'id': 16, 'title': 'Write product descriptions', 'description': 'Create compelling copy for e-commerce listings'},
    {'id': 17, 'title': 'Solve math problems',        'description': 'Get step-by-step solutions to math questions'},
    {'id': 18, 'title': 'Generate quiz questions',    'description': 'Create questions to test knowledge on any topic'},
    {'id': 19, 'title': 'Summarize an article',       'description': 'Get the key points from long articles quickly'},
    {'id': 20, 'title': 'Write a resume',             'description': 'Build a professional resume tailored to job roles'},
    {'id': 21, 'title': 'Create a budget',            'description': 'Get a personalized monthly budget plan'},
    {'id': 22, 'title': 'Learn a new skill',          'description': 'Get a structured roadmap to learn anything fast'},
    {'id': 23, 'title': 'Write a speech',             'description': 'Draft a memorable speech for any occasion'},
    {'id': 24, 'title': 'Explain Flutter widgets',    'description': 'Get clear explanations of Flutter UI components'},
    {'id': 25, 'title': 'Review my writing',          'description': 'Get grammar, style, and clarity feedback on your text'},
    {'id': 26, 'title': 'Generate logo ideas',        'description': 'Get creative concept suggestions for your brand'},
    {'id': 27, 'title': 'Write interview answers',    'description': 'Practice common interview questions with model answers'},
    {'id': 28, 'title': 'Create a business plan',     'description': 'Generate a structured plan for your startup idea'},
    {'id': 29, 'title': 'Compress an image prompt',   'description': 'Get optimized prompts for AI image generators'},
    {'id': 30, 'title': 'Write unit tests',           'description': 'Generate comprehensive test cases for your code'},
  ];

  static const List<String> _replies = [
    "That's a great question! Flutter is Google's open-source UI toolkit for building natively compiled applications from a single codebase for mobile, web, and desktop.",
    "Flutter state management helps you manage UI updates efficiently. Popular solutions include Provider, Riverpod, Bloc, and GetX — each with different tradeoffs in complexity and scalability.",
    "I'd be happy to help with that! Here's a structured approach: First, break the problem into smaller tasks. Then tackle each one systematically. Would you like me to go deeper on any specific step?",
    "Great choice! To get started, you'll want to set up your development environment, understand the core concepts, and practice by building small projects. I can create a step-by-step learning plan for you.",
    "Sure! The key idea here is to separate concerns. Keep your business logic away from your UI layer, use clean interfaces between layers, and write testable code from the start.",
    "Interesting! Here are some creative ideas you could explore: (1) Start with a minimum viable product, (2) Get feedback early from real users, (3) Iterate quickly based on data rather than assumptions.",
    "Of course! Here's a concise summary: the content focuses on practical applications, emphasises simplicity, and provides actionable steps you can implement immediately.",
    "That's a common challenge. The most effective solution is to break it down into smaller, manageable tasks, set clear milestones, and celebrate small wins along the way.",
  ];

  @override
  Future<SuggestionPage> getSuggestions({int page = 1, int limit = 10}) async {
    await Future.delayed(Duration(milliseconds: 500 + _rng.nextInt(400)));

    final total = _suggestions.length;
    final totalPages = (total / limit).ceil();
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, total);

    final items = _suggestions
        .sublist(start, end)
        .map((e) => Suggestion.fromJson(e))
        .toList();

    return SuggestionPage(
      suggestions: items,
      pagination: PaginationMeta(
        currentPage: page,
        totalPages: totalPages,
        totalItems: total,
        limit: limit,
        hasNext: page < totalPages,
        hasPrevious: page > 1,
      ),
    );
  }

  @override
  Future<String> sendMessage(String message) async {
    await Future.delayed(Duration(milliseconds: 700 + _rng.nextInt(600)));
    return _replies[message.length % _replies.length];
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
}
