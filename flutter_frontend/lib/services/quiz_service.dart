import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = 'http://localhost:8002'; // Storage service
  final AuthService _authService = AuthService();
  
  // Era IDs for syncing local scores
  static const List<String> allEraIds = [
    'early_church',
    'imperial_church',
    'medieval_church',
    'reformation',
    'modern_era',
  ];

  Future<Map<String, dynamic>> saveQuizScore({
    required String eraId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/me/$userId/quiz-scores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'era_id': eraId,
          'score': score,
          'total_questions': totalQuestions,
        }),
      );

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Failed to save quiz score'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getQuizScores({String? eraId}) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final uri = eraId != null
          ? Uri.parse('$baseUrl/me/$userId/quiz-scores?era_id=$eraId')
          : Uri.parse('$baseUrl/me/$userId/quiz-scores');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Failed to get quiz scores'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<int?> getHighScore(String eraId) async {
    final result = await getQuizScores(eraId: eraId);
    if (result['success'] == true && result['data'] != null) {
      final scores = result['data']['scores'] as List?;
      if (scores != null && scores.isNotEmpty) {
        return scores.first['score'] as int?;
      }
    }
    return null;
  }

  /// Syncs local SharedPreferences quiz scores to the backend
  /// Should be called after user login to ensure all local scores are uploaded
  Future<void> syncLocalScoresToBackend() async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Check each era for local scores
      for (final eraId in allEraIds) {
        final localScore = prefs.getInt('quiz_highscore_$eraId');
        if (localScore != null) {
          // Upload local score to backend
          await saveQuizScore(
            eraId: eraId,
            score: localScore,
            totalQuestions: 8, // Standard quiz length
          );
        }
      }
    } catch (e) {
      print('Error syncing local scores to backend: $e');
    }
  }
}
