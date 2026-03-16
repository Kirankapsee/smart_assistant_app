part of 'suggestions_cubit.dart';

abstract class SuggestionsState extends Equatable {
  const SuggestionsState();

  @override
  List<Object?> get props => [];
}

/// No data loaded yet.
class SuggestionsInitial extends SuggestionsState {
  const SuggestionsInitial();
}

/// First-page fetch in progress.
class SuggestionsLoading extends SuggestionsState {
  const SuggestionsLoading();
}

/// At least one page loaded; may still be fetching more.
class SuggestionsLoaded extends SuggestionsState {
  final List<Suggestion> suggestions;
  final PaginationMeta pagination;
  final bool isLoadingMore;

  const SuggestionsLoaded({
    required this.suggestions,
    required this.pagination,
    this.isLoadingMore = false,
  });

  bool get hasMore => pagination.hasNext;

  SuggestionsLoaded copyWith({
    List<Suggestion>? suggestions,
    PaginationMeta? pagination,
    bool? isLoadingMore,
  }) =>
      SuggestionsLoaded(
        suggestions: suggestions ?? this.suggestions,
        pagination: pagination ?? this.pagination,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [suggestions, pagination, isLoadingMore];
}

/// Terminal error – shown when the initial load fails.
class SuggestionsError extends SuggestionsState {
  final String message;
  const SuggestionsError(this.message);

  @override
  List<Object?> get props => [message];
}
