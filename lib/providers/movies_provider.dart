import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:movies_application/helpers/debouncer.dart';
import 'package:movies_application/models/models.dart';
import 'package:movies_application/models/search_movies_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseURl = 'api.themoviedb.org';
  final String _apiKey = '098b3827b741f17f7458cde1cddb7070';
  final String _language = 'es-Es';
  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  int _popularPage = 0;

  Map<int, List<Cast>> moviesCast = {};

  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint,
      {int page = 1, Map<String, String>? params}) async {
    final requestParams = {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page'
    };
    if (params != null) {
      requestParams.addAll(params);
    }
    var url = Uri.https(_baseURl, endpoint, requestParams);

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final nowPlayingResponse =
        NowPlayingResponse.fromJson(await _getJsonData('3/movie/now_playing'));
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final popularResponse = PopularResponse.fromJson(
        await _getJsonData('3/movie/popular', page: _popularPage));
    popularMovies = [...popularMovies, ...popularResponse.results];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) {
      return moviesCast[movieId]!;
    }
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final jsonData =
        await _getJsonData('3/search/movie', params: {'query': query});
    final searchMoviesResponse = SearchMoviesResponse.fromJson(jsonData);
    return searchMoviesResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = ((value) async {
      final results = await searchMovie(searchTerm);
      _suggestionStreamController.add(results);
    });
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });
    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
