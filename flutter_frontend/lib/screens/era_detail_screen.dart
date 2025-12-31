import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:church_history_explorer/models/church_history_models.dart';
import 'package:church_history_explorer/screens/ai_assistant_screen.dart';
import 'package:church_history_explorer/screens/era_quiz_screen.dart';
import 'package:church_history_explorer/screens/event_detail_screen.dart';
import 'package:church_history_explorer/screens/people_detail_screen.dart';
import 'package:church_history_explorer/screens/timeline_widget.dart';

class EraDetailScreen extends StatefulWidget {
  final ChurchHistoryEra era;
  const EraDetailScreen({super.key, required this.era});

  @override
  State<EraDetailScreen> createState() => _EraDetailScreenState();
}

class _EraDetailScreenState extends State<EraDetailScreen> {
  String? _expandedEventId;
  int? _quizHighScore;
  List<EraQuizQuestion> _quizQuestions = [];
  bool _quizLoading = false;
  bool _quizLoadFailed = false;

  static const int _quizQuestionLimit = 8;

  @override
  void initState() {
    super.initState();
    _loadQuizHighScore();
    _loadQuizQuestions();
  }

  Color _hexToColor(String hexColor) {
    var v = hexColor.replaceAll('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse('0x$v'));
  }

  Future<void> _loadQuizHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('quiz_highscore_${widget.era.id}');
    if (!mounted) return;
    setState(() {
      _quizHighScore = score;
    });
  }

  Future<void> _persistHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_highscore_${widget.era.id}', score);
  }

  Future<void> _loadQuizQuestions() async {
    setState(() {
      _quizLoading = true;
      _quizLoadFailed = false;
    });

    try {
      final path = 'assets/data/${widget.era.id}_quiz.json';
      final jsonStr = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = decoded['questions'] as List<dynamic>? ?? [];
      final questions = list
          .map((e) => EraQuizQuestion.fromJson(e as Map<String, dynamic>))
          .where((q) => q.id.isNotEmpty && q.prompt.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _quizQuestions = questions;
        _quizLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _quizLoading = false;
        _quizLoadFailed = true;
        _quizQuestions = [];
      });
    }
  }

  void _openQuiz(Color eraColor) {
    if (_quizLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz is still loading...')),
      );
      return;
    }

    if (_quizLoadFailed || _quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz unavailable. Please try again.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EraQuizScreen(
          eraId: widget.era.id,
          eraTitle: widget.era.title,
          accentColor: eraColor,
          questions: _quizQuestions,
          questionCount: _quizQuestionLimit,
          onCompleted: (score, total) async {
            if (!mounted) return;
            final prev = _quizHighScore ?? 0;
            if (score > prev) {
              setState(() => _quizHighScore = score);
              await _persistHighScore(score);
            }

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You scored $score of $total'),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizIconWithScore(Color eraColor) {
    final label = _quizHighScore == null
        ? '-'
        : _quizHighScore!.clamp(0, _quizQuestionLimit).toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.quiz_outlined),
        if (_quizHighScore != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: eraColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: eraColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$label/$_quizQuestionLimit',
              style: TextStyle(
                fontSize: 11,
                color: eraColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuizCard(Color eraColor) {
    final scoreText = _quizHighScore == null
        ? 'No score yet'
        : 'High score: $_quizHighScore/$_quizQuestionLimit';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: eraColor.withOpacity(0.35)),
          gradient: LinearGradient(
            colors: [
              eraColor.withOpacity(0.12),
              eraColor.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: eraColor.withOpacity(0.18),
              foregroundColor: eraColor,
              child: const Icon(Icons.quiz_outlined, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test your knowledge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quick ${_quizQuestionLimit}-question quiz with shuffled prompts each time.',
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scoreText,
                    style: TextStyle(
                      color: eraColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openQuiz(eraColor),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Take quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: eraColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.era;
    final eraColor = _hexToColor(era.color);
    final hasQuiz = _quizQuestions.isNotEmpty && !_quizLoading;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(era.title),
          actions: [
            if (hasQuiz)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: _quizHighScore == null
                      ? 'Take the era quiz'
                      : 'High score: $_quizHighScore/$_quizQuestionLimit',
                  onPressed: () => _openQuiz(eraColor),
                  icon: _buildQuizIconWithScore(eraColor),
                ),
              ),
          ],
          bottom: TabBar(
            indicatorColor: eraColor,
            labelColor: eraColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.event, color: eraColor), text: 'Events'),
              Tab(icon: Icon(Icons.people, color: eraColor), text: 'People'),
              Tab(icon: Icon(Icons.timeline, color: eraColor), text: 'Timeline'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Events list
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: era.events.length,
              itemBuilder: (context, index) {
                final event = era.events[index];
                final isExpanded = _expandedEventId == event.id;
                return _buildEventCard(
                  context,
                  event,
                  eraColor,
                  isExpanded,
                );
              },
            ),
            // People list
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: era.figures.length,
              itemBuilder: (context, index) {
                final fig = era.figures[index];
                return _buildFigureCard(context, fig, eraColor);
              },
            ),
            // Timeline
            TimelineWidget(
              events: era.events,
              figures: era.figures,
              eraColor: eraColor,
            ),
          ],
        ),
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
                color: isExpanded ? eraColor : eraColor.withOpacity(0.3),
                width: 2,
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
                                            backgroundColor: eraColor
                                                .withOpacity(0.2),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                // Action buttons: Ask AI + View Details
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AiAssistantScreen(
                                                    initialContext:
                                                        '${event.title} (${event.year})',
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.smart_toy, color: Colors.white),
                                        label: const Text(
                                          'Ask AI',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: eraColor,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventDetailScreen(
                                                    event: event,
                                                    eraColor: eraColor,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.open_in_full),
                                        label: const Text('View Full Details'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: eraColor,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildFigureCard(
    BuildContext context,
    HistoricalFigure figure,
    Color eraColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        figure.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        figure.role,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${figure.birthYear} – ${figure.deathYear}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (figure.portraitUrl != null &&
                    figure.portraitUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildPortraitImage(
                      figure.portraitUrl!,
                      eraColor,
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: eraColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.person, color: eraColor, size: 32),
                  ),
              ],
            ),
            if (figure.portraitCredit != null &&
                figure.portraitCredit!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Portrait: ${figure.portraitCredit}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              figure.biography,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: figure.tags
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      backgroundColor: eraColor.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: eraColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPortraitImage(String url, Color eraColor) {
    final isNetwork = Uri.tryParse(url)?.hasScheme == true &&
        (url.startsWith('http://') || url.startsWith('https://'));
    
    final errorWidget = Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: eraColor.withOpacity(0.3),
        ),
      ),
      child: Icon(Icons.person, color: eraColor, size: 32),
    );

    if (isNetwork) {
      return Image.network(
        url,
        height: 64,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) => errorWidget,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: eraColor.withOpacity(0.2),
              ),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? (progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!)
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        url,
        height: 64,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }
}
