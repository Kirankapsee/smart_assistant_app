import '../models/suggestion_model.dart';
import '../services/api_service.dart';

class SuggestionsRepository {
  final ApiService _api;

  /// Pass [MockApiService()] during development/demo,
  /// or leave blank to use the real [ApiService].
  SuggestionsRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  Future<SuggestionPage> fetchSuggestions({
    required int page,
    int limit = 10,
  }) =>
      _api.getSuggestions(page: page, limit: limit);
}
