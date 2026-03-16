import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/suggestions_repository.dart';
import '../../../data/models/suggestion_model.dart';
import '../../../data/services/api_service.dart';

part 'suggestions_state.dart';

class SuggestionsCubit extends Cubit<SuggestionsState> {
  final SuggestionsRepository _repository;
  int _currentPage = 1;
  static const int _limit = 10;

  SuggestionsCubit({SuggestionsRepository? repository})
      : _repository = repository ?? SuggestionsRepository(),
        super(const SuggestionsInitial());

  // ── Initial / refresh load ────────────────────────────────
  Future<void> fetchSuggestions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      emit(const SuggestionsLoading());
    } else if (state is SuggestionsInitial) {
      emit(const SuggestionsLoading());
    } else {
      return; // already loaded – caller should use refresh: true
    }

    try {
      final page = await _repository.fetchSuggestions(
          page: _currentPage, limit: _limit);
      emit(SuggestionsLoaded(
          suggestions: page.suggestions, pagination: page.pagination));
    } catch (e) {
      emit(SuggestionsError(_errorMessage(e)));
    }
  }

  // ── Load next page ────────────────────────────────────────
  Future<void> loadNextPage() async {
    final current = state;
    if (current is! SuggestionsLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    _currentPage++;
    emit(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repository.fetchSuggestions(
          page: _currentPage, limit: _limit);
      emit(current.copyWith(
        suggestions: [...current.suggestions, ...page.suggestions],
        pagination: page.pagination,
        isLoadingMore: false,
      ));
    } catch (_) {
      _currentPage--;
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  String _errorMessage(Object e) {
    if (e is NetworkException) return 'No internet connection. Please check your network.';
    if (e is ServerException) return 'Server error (${e.statusCode}). Please try again.';
    if (e is ParseException) return 'Unexpected response from server.';
    if (e is ApiException) return e.message;
    return e.toString();
  }
}
