class Suggestion {
  final int id;
  final String title;
  final String description;

  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };
}

class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] as int,
        totalPages: json['total_pages'] as int,
        totalItems: json['total_items'] as int,
        limit: json['limit'] as int,
        hasNext: json['has_next'] as bool,
        hasPrevious: json['has_previous'] as bool,
      );
}

class SuggestionPage {
  final List<Suggestion> suggestions;
  final PaginationMeta pagination;

  const SuggestionPage({required this.suggestions, required this.pagination});

  factory SuggestionPage.fromJson(Map<String, dynamic> json) => SuggestionPage(
        suggestions: (json['data'] as List)
            .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: PaginationMeta.fromJson(
            json['pagination'] as Map<String, dynamic>),
      );
}
