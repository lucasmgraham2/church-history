import 'package:flutter/material.dart';
import 'package:church_history_explorer/models/church_history_models.dart';
import 'package:church_history_explorer/screens/event_detail_screen.dart';
import 'package:church_history_explorer/screens/people_detail_screen.dart';

class TimelineWidget extends StatelessWidget {
  final List<HistoricalEvent> events;
  final List<HistoricalFigure> figures;
  final Color eraColor;

  const TimelineWidget({
    super.key,
    required this.events,
    required this.figures,
    required this.eraColor,
  });

  /// Extract numeric year from year string (e.g., "33 AD" -> 33)
  int _extractYear(String yearStr) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(yearStr);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '0') ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Create timeline items from events and figures
    List<TimelineItem> items = [];

    // Add events
    for (var event in events) {
      items.add(
        TimelineItem(
          year: _extractYear(event.year),
          title: event.title,
          subtitle: event.location,
          type: TimelineItemType.event,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                  event: event,
                  eraColor: eraColor,
                ),
              ),
            );
          },
          originalYearStr: event.year,
        ),
      );
    }

    // Add figures
    for (var figure in figures) {
      final birthYear = _extractYear(figure.birthYear);
      items.add(
        TimelineItem(
          year: birthYear,
          title: figure.name,
          subtitle: figure.role,
          type: TimelineItemType.person,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PeopleDetailScreen(
                  figure: figure,
                  eraColor: eraColor,
                ),
              ),
            );
          },
          originalYearStr: figure.birthYear,
        ),
      );
    }

    // Sort by year
    items.sort((a, b) => a.year.compareTo(b.year));

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No events or people in this era',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEvent = item.type == TimelineItemType.event;
        final isLast = index == items.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Events
              Expanded(
                child: isEvent
                    ? GestureDetector(
                        onTap: item.onTap,
                        child: _buildTimelineCard(
                          item,
                          eraColor,
                          isEvent: true,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Center: Timeline line and dot
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    // Year label
                    Text(
                      item.originalYearStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: eraColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Dot
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isEvent ? eraColor : Colors.grey[400],
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: isEvent
                                ? eraColor.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Vertical line
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 60,
                          child: Center(
                            child: Container(
                              width: 2,
                              height: double.infinity,
                              color: eraColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Right side: People
              Expanded(
                child: !isEvent
                    ? GestureDetector(
                        onTap: item.onTap,
                        child: _buildTimelineCard(
                          item,
                          eraColor,
                          isEvent: false,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineCard(
    TimelineItem item,
    Color eraColor, {
    required bool isEvent,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: eraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isEvent
              ? eraColor.withOpacity(0.08)
              : Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEvent ? Icons.event : Icons.person,
                  size: 18,
                  color: isEvent ? eraColor : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum TimelineItemType {
  event,
  person,
}

class TimelineItem {
  final int year;
  final String title;
  final String subtitle;
  final TimelineItemType type;
  final VoidCallback onTap;
  final String originalYearStr;

  TimelineItem({
    required this.year,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.onTap,
    required this.originalYearStr,
  });
}
