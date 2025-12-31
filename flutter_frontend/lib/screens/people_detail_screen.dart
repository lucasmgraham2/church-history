import 'package:flutter/material.dart';
import 'package:church_history_explorer/models/church_history_models.dart';
import 'package:church_history_explorer/screens/ai_assistant_screen.dart';

class PeopleDetailScreen extends StatefulWidget {
  final HistoricalFigure figure;
  final Color eraColor;

  const PeopleDetailScreen({
    super.key,
    required this.figure,
    required this.eraColor,
  });

  @override
  State<PeopleDetailScreen> createState() => _PeopleDetailScreenState();
}

class _PeopleDetailScreenState extends State<PeopleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.figure.name),
        backgroundColor: widget.eraColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image/portrait
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.figure.portraitUrl != null &&
                      widget.figure.portraitUrl!.isNotEmpty)
                    _buildHeroImage(widget.figure.portraitUrl!)
                  else
                    Center(
                      child: Icon(
                        Icons.person,
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
                                  '${widget.figure.birthYear} – ${widget.figure.deathYear}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.figure.portraitCredit != null &&
                              widget.figure.portraitCredit!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Portrait: ${widget.figure.portraitCredit}',
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
                  // Role
                  if (widget.figure.role.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          color: widget.eraColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.figure.role,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Biography
                  if (widget.figure.biography.isNotEmpty) ...[
                    Text(
                      'Biography',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.figure.biography,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Significance
                  if (widget.figure.significance.isNotEmpty) ...[
                    Text(
                      'Significance & Impact',
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
                        widget.figure.significance,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Major Achievements
                  if (widget.figure.majorAchievements.isNotEmpty) ...[
                    Text(
                      'Major Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.figure.majorAchievements.map(
                      (achievement) => Padding(
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
                                Icons.check_circle,
                                color: widget.eraColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  achievement,
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

                  // Influences
                  if (widget.figure.influences.isNotEmpty) ...[
                    Text(
                      'Influences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.figure.influences
                          .map(
                            (influence) => Chip(
                              label: Text(influence),
                              backgroundColor: widget.eraColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: widget.eraColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tags
                  if (widget.figure.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.eraColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.figure.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: widget.eraColor.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: widget.eraColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
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
                              initialContext: widget.figure.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('Ask AI About This Person'),
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
            fit: BoxFit.contain,
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
            fit: BoxFit.contain,
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
