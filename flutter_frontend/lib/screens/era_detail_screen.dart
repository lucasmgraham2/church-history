import 'package:flutter/material.dart';
import 'package:church_history_explorer/models/church_history_models.dart';
import 'package:church_history_explorer/screens/event_detail_screen.dart';

class EraDetailScreen extends StatefulWidget {
  final ChurchHistoryEra era;
  const EraDetailScreen({super.key, required this.era});

  @override
  State<EraDetailScreen> createState() => _EraDetailScreenState();
}

class _EraDetailScreenState extends State<EraDetailScreen> {
  String? _expandedEventId;

  Color _hexToColor(String hexColor) {
    var v = hexColor.replaceAll('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse('0x$v'));
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.era;
    final eraColor = _hexToColor(era.color);
    return Scaffold(
      appBar: AppBar(
        title: Text(era.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: era.events.length,
        itemBuilder: (context, index) {
          final event = era.events[index];
          final isExpanded = _expandedEventId == event.id;
          return _buildEventCard(context, event, eraColor, isExpanded);
        },
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    HistoricalEvent event,
    Color eraColor,
    bool isExpanded,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isExpanded ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _expandedEventId = isExpanded ? null : event.id;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded ? eraColor : Colors.grey[300]!,
                width: isExpanded ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: eraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: eraColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          event.year,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: eraColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title + location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (event.location.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: eraColor,
                      ),
                    ],
                  ),
                ),

                // Body (collapsed + expanded) animated together
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isExpanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              event.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),

                        if (isExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full description
                                Text(
                                  event.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Details
                                if (event.details.isNotEmpty) ...[
                                  Text(
                                    'Details',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      event.details,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Key figures
                                if (event.keyFigures.isNotEmpty) ...[
                                  Text(
                                    'Key Figures',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: event.keyFigures
                                        .map(
                                          (figure) => Chip(
                                            label: Text(figure),
                                            backgroundColor:
                                                eraColor.withOpacity(0.2),
                                            labelStyle: TextStyle(
                                              color: eraColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Significance
                                if (event.significance.isNotEmpty) ...[
                                  Text(
                                    'Why It Matters',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...event.significance.map(
                                    (sig) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 20,
                                            color: eraColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sig,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Details button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EventDetailScreen(
                                            event: event,
                                            eraColor: eraColor,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_full),
                                    label: const Text('View Full Details'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (!isExpanded) const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
