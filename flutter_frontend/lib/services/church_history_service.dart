import 'dart:convert';
import 'package:flutter/services.dart';
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

      // Build eras, then normalize events (sort chronologically and dedupe)
      final loadedEras = erasList
          .map((era) => ChurchHistoryEra.fromJson(era as Map<String, dynamic>))
          .toList();

      _cachedEras = loadedEras.map(_normalizeEra).toList();

      return _cachedEras!;
    } catch (e) {
      throw Exception('Failed to load church history data: $e');
    }
  }

  /// Normalize an era's events: sort chronologically and remove duplicates
  static ChurchHistoryEra _normalizeEra(ChurchHistoryEra era) {
    // Dedupe by id and by (title+year) pair
    final seenIds = <String>{};
    final seenTitleYear = <String>{};
    final deduped = <HistoricalEvent>[];

    for (final e in era.events) {
      final idKey = e.id.trim().toLowerCase();
      final tyKey = ('${e.title}|${e.year}').trim().toLowerCase();
      if (idKey.isEmpty) {
        // If no id, fallback to title+year uniqueness
        if (seenTitleYear.contains(tyKey)) continue;
        seenTitleYear.add(tyKey);
        deduped.add(e);
      } else {
        // Prefer id uniqueness; also guard by title+year
        if (seenIds.contains(idKey) || seenTitleYear.contains(tyKey)) continue;
        seenIds.add(idKey);
        seenTitleYear.add(tyKey);
        deduped.add(e);
      }
    }

    // Sort by parsed year ascending
    deduped.sort((a, b) => _yearKey(a.year).compareTo(_yearKey(b.year)));

    return ChurchHistoryEra(
      id: era.id,
      title: era.title,
      startYear: era.startYear,
      endYear: era.endYear,
      description: era.description,
      color: era.color,
      icon: era.icon,
      events: deduped,
      figures: era.figures,
    );
  }

  /// Convert a year string (e.g., "1517 AD", "1536–1541 AD", "270-400 AD", "~67 AD")
  /// into a sortable integer key. BC becomes negative.
  static int _yearKey(String yearStr) {
    final s = yearStr.trim();
    if (s.isEmpty) return 999999; // push unknown years to the end

    // Extract the first number in the string
    final match = RegExp(r'(\d{1,4})').firstMatch(s);
    if (match == null) return 999999;
    final n = int.tryParse(match.group(1)!) ?? 999999;

    final isBC = s.toUpperCase().contains('BC');
    return isBC ? -n : n;
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
