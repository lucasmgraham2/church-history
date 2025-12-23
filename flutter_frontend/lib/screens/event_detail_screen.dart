import 'package:flutter/material.dart';
import 'package:church_history_explorer/models/church_history_models.dart';
import 'package:church_history_explorer/screens/ai_assistant_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final HistoricalEvent event;
  final Color eraColor;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.eraColor,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        backgroundColor: widget.eraColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.event.imageUrl != null &&
                      widget.event.imageUrl!.isNotEmpty)
                    _buildHeroImage(widget.event.imageUrl!)
                  else
                    Center(
                      child: Icon(
                        Icons.history,
                        size: 100,
                        color: widget.eraColor.withOpacity(0.3),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.eraColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.event.year,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.event.imageCredit != null &&
                              widget.event.imageCredit!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Image: ${widget.event.imageCredit}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  if (widget.event.location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: widget.eraColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Overview
                  if (widget.event.description.isNotEmpty) ...[
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.event.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Full details + citations
                  if (widget.event.details.isNotEmpty) ...[
                    Text(
                      'Full Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.eraColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.eraColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        widget.event.details,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Key figures
                  if (widget.event.keyFigures.isNotEmpty) ...[
                    Text(
                      'Key Figures',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.event.keyFigures.map(
                      (figure) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.eraColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: widget.eraColor,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: widget.eraColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  figure,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Significance
                  if (widget.event.significance.isNotEmpty) ...[
                    Text(
                      'Significance & Impact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.event.significance.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.eraColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sources
                  if (widget.event.sources.isNotEmpty) ...[
                    Text(
                      'Sources & Citations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.event.sources.map(
                      (source) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.eraColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: widget.eraColor,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.source,
                                color: widget.eraColor,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  source,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Ask AI Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AiAssistantScreen(
                              initialContext: widget.event.title,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('Ask AI About This Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.eraColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    final isNetwork = Uri.tryParse(url)?.hasScheme == true &&
        (url.startsWith('http://') || url.startsWith('https://'));
    final imageWidget = isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
          );
    return imageWidget;
  }
}
