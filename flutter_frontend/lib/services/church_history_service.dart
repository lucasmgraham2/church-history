import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/church_history_models.dart';

class ChurchHistoryService {
  static const String baseUrl = 'http://localhost:8003/api';
  static List<ChurchHistoryEra>? _cachedEras;

  /// Load church history data from JSON file
  static Future<List<ChurchHistoryEra>> _loadFromJSON() async {
    if (_cachedEras != null) {
      return _cachedEras!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/church_history.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> erasList = jsonData['eras'] as List<dynamic>;

      _cachedEras = erasList
          .map((era) => ChurchHistoryEra.fromJson(era as Map<String, dynamic>))
          .toList();

      return _cachedEras!;
    } catch (e) {
      throw Exception('Failed to load church history data: $e');
    }
  }

  /// Get mock data for church history (loads from JSON)
  static Future<List<ChurchHistoryEra>> getMockEras() async {
    return await _loadFromJSON();
  }

  /// Fetch all church history eras and events
  Future<Map<String, dynamic>> getChurchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      // Load from JSON
      final eras = await getMockEras();
      return {'success': true, 'eras': eras};
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get a specific era with all its events
  Future<Map<String, dynamic>> getEra(String eraId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final eras = await getMockEras();
      ChurchHistoryEra? era;
      try {
        era = eras.firstWhere((e) => e.id == eraId);
      } catch (e) {
        era = null;
      }

      if (era != null) {
        return {'success': true, 'era': era};
      } else {
        return {'success': false, 'error': 'Era not found'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get a specific event
  Future<Map<String, dynamic>> getEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final eras = await getMockEras();
      for (var era in eras) {
        try {
          final event = era.events.firstWhere((e) => e.id == eventId);
          return {'success': true, 'event': event};
        } catch (e) {
          // Event not in this era, continue searching
        }
      }

      return {'success': false, 'error': 'Event not found'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Mark an event as viewed
  Future<bool> markEventViewed(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      // In a real app, this would call an API
      // For now, just return success
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Bookmark/unbookmark an event
  Future<bool> toggleBookmark(String eventId, bool bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      // In a real app, this would call an API
      // For now, just return success
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Search events
  Future<Map<String, dynamic>> searchEvents(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final eras = await getMockEras();
      final results = <HistoricalEvent>[];

      for (var era in eras) {
        for (var event in era.events) {
          if (event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase())) {
            results.add(event);
          }
        }
      }

      return {'success': true, 'events': results};
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
