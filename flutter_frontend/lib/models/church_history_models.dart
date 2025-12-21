/// Models for Church History Explorer app
library;

/// Represents an iconic historical figure
class HistoricalFigure {
  final String id;
  final String name;
  final String period; // Era they belong to
  final String role; // e.g., "Theologian", "Reformer", "Church Father"
  final String birthYear;
  final String deathYear;
  final String biography; // Detailed learner-friendly biography
  final String significance; // Why they're important
  final List<String> majorAchievements; // Key accomplishments
  final List<String> influences; // People or ideas that influenced them
  final String? portraitUrl; // Image URL
  final List<String> tags; // Categorization

  HistoricalFigure({
    required this.id,
    required this.name,
    required this.period,
    required this.role,
    required this.birthYear,
    required this.deathYear,
    required this.biography,
    required this.significance,
    required this.majorAchievements,
    required this.influences,
    this.portraitUrl,
    required this.tags,
  });

  factory HistoricalFigure.fromJson(Map<String, dynamic> json) {
    return HistoricalFigure(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      period: json['period'] as String? ?? '',
      role: json['role'] as String? ?? '',
      birthYear: (json['birth_year'] ?? json['birthYear']) as String? ?? '',
      deathYear: (json['death_year'] ?? json['deathYear']) as String? ?? '',
      biography: json['biography'] as String? ?? '',
      significance: json['significance'] as String? ?? '',
      majorAchievements: List<String>.from(
        (json['major_achievements'] ?? json['majorAchievements'])
                as List<dynamic>? ??
            [],
      ),
      influences: List<String>.from(json['influences'] as List<dynamic>? ?? []),
      portraitUrl: (json['portrait_url'] ?? json['portraitUrl']) as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'period': period,
      'role': role,
      'birth_year': birthYear,
      'death_year': deathYear,
      'biography': biography,
      'significance': significance,
      'major_achievements': majorAchievements,
      'influences': influences,
      'portrait_url': portraitUrl,
      'tags': tags,
    };
  }
}

/// Represents a major era of church history
class ChurchHistoryEra {
  final String id;
  final String title;
  final String startYear;
  final String endYear;
  final String description;
  final String color; // Hex color for UI
  final String icon; // Icon identifier
  final List<HistoricalEvent> events;
  final List<HistoricalFigure> figures; // New: iconic people from this era

  ChurchHistoryEra({
    required this.id,
    required this.title,
    required this.startYear,
    required this.endYear,
    required this.description,
    required this.color,
    required this.icon,
    required this.events,
    required this.figures,
  });

  factory ChurchHistoryEra.fromJson(Map<String, dynamic> json) {
    return ChurchHistoryEra(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      // Accept both snake_case and camelCase keys
      startYear: (json['start_year'] ?? json['startYear']) as String? ?? '',
      endYear: (json['end_year'] ?? json['endYear']) as String? ?? '',
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '#2196F3',
      icon: json['icon'] as String? ?? 'history',
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => HistoricalEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      figures:
          (json['figures'] as List<dynamic>?)
              ?.map((f) => HistoricalFigure.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_year': startYear,
      'end_year': endYear,
      'description': description,
      'color': color,
      'icon': icon,
      'events': events.map((e) => e.toJson()).toList(),
      'figures': figures.map((f) => f.toJson()).toList(),
    };
  }
}

/// Represents a specific historical event within an era
class HistoricalEvent {
  final String id;
  final String title;
  final String year;
  final String location;
  final String description;
  final String details; // Expandable detailed information
  final List<String> keyFigures; // Important people involved
  final List<String> significance; // Why this event matters
  final String? imageUrl; // Optional image URL
  final String? mapUrl; // Optional map visualization URL
  final List<String> tags; // Tags for categorization
  final List<String> sources; // Academic sources and citations

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.year,
    required this.location,
    required this.description,
    required this.details,
    required this.keyFigures,
    required this.significance,
    this.imageUrl,
    this.mapUrl,
    required this.tags,
    required this.sources,
  });

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    return HistoricalEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      year: json['year'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      details: json['details'] as String? ?? '',
      keyFigures: List<String>.from(
        (json['key_figures'] ?? json['keyFigures']) as List<dynamic>? ?? [],
      ),
      significance: List<String>.from(
        json['significance'] as List<dynamic>? ?? [],
      ),
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      mapUrl: (json['map_url'] ?? json['mapUrl']) as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      sources: List<String>.from(json['sources'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'location': location,
      'description': description,
      'details': details,
      'key_figures': keyFigures,
      'significance': significance,
      'image_url': imageUrl,
      'map_url': mapUrl,
      'tags': tags,
      'sources': sources,
    };
  }
}

/// Represents user learning progress
class LearningProgress {
  final String userId;
  final List<String> viewedEventIds;
  final List<String> bookmarkedEventIds;
  final List<String> askedQuestions;
  final DateTime lastViewed;

  LearningProgress({
    required this.userId,
    required this.viewedEventIds,
    required this.bookmarkedEventIds,
    required this.askedQuestions,
    required this.lastViewed,
  });

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      userId: json['user_id'] as String? ?? '',
      viewedEventIds: List<String>.from(
        json['viewed_event_ids'] as List<dynamic>? ?? [],
      ),
      bookmarkedEventIds: List<String>.from(
        json['bookmarked_event_ids'] as List<dynamic>? ?? [],
      ),
      askedQuestions: List<String>.from(
        json['asked_questions'] as List<dynamic>? ?? [],
      ),
      lastViewed: DateTime.parse(
        json['last_viewed'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'viewed_event_ids': viewedEventIds,
      'bookmarked_event_ids': bookmarkedEventIds,
      'asked_questions': askedQuestions,
      'last_viewed': lastViewed.toIso8601String(),
    };
  }
}
