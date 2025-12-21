import 'dart:math';
import 'package:flutter/material.dart';

class EraQuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const EraQuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory EraQuizQuestion.fromJson(Map<String, dynamic> json) {
    return EraQuizQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: List<String>.from(json['options'] as List<dynamic>? ?? const []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class EraQuizScreen extends StatefulWidget {
  final String eraId;
  final String eraTitle;
  final Color accentColor;
  final List<EraQuizQuestion> questions;
  final void Function(int score, int total) onCompleted;
  final int questionCount;

  const EraQuizScreen({
    super.key,
    required this.eraId,
    required this.eraTitle,
    required this.accentColor,
    required this.questions,
    required this.onCompleted,
    this.questionCount = 6,
  });

  @override
  State<EraQuizScreen> createState() => _EraQuizScreenState();
}

class _EraQuizScreenState extends State<EraQuizScreen> {
  List<_ActiveQuestion> _quizQuestions = [];
  final Map<int, String> _answers = {};
  int _currentIndex = 0;
  int _score = 0;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _prepareQuiz();
  }

  void _prepareQuiz({bool rebuild = false}) {
    final pool = List<EraQuizQuestion>.from(widget.questions)..shuffle();
    final selection = pool
        .take(min(widget.questionCount, pool.length))
        .map(
          (q) => _ActiveQuestion(
            base: q,
            shuffledOptions: List<String>.from(q.options)..shuffle(),
          ),
        )
        .toList();

    void assign() {
      _quizQuestions = selection;
      _answers.clear();
      _currentIndex = 0;
      _score = 0;
      _showResults = false;
    }

    if (rebuild) {
      setState(assign);
    } else {
      assign();
    }
  }

  void _selectAnswer(String value) {
    setState(() {
      _answers[_currentIndex] = value;
    });
  }

  void _finishQuiz() {
    var totalScore = 0;
    _answers.forEach((idx, answer) {
      if (answer == _quizQuestions[idx].base.correctAnswer) {
        totalScore++;
      }
    });

    setState(() {
      _score = totalScore;
      _showResults = true;
    });

    widget.onCompleted(totalScore, _quizQuestions.length);
  }

  void _next() {
    if (_currentIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previous() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.eraTitle} Quiz'),
      ),
      body: _quizQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _showResults
              ? _buildResultsView()
              : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    final active = _quizQuestions[_currentIndex];
    final selected = _answers[_currentIndex];
    final total = _quizQuestions.length;
    final isLast = _currentIndex == total - 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.accentColor.withOpacity(0.15),
                foregroundColor: widget.accentColor,
                child: Text('${_currentIndex + 1}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of $total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / total,
                      backgroundColor: Colors.grey[200],
                      color: widget.accentColor,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    active.base.prompt,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...active.shuffledOptions.map(
                    (option) => RadioListTile<String>(
                      value: option,
                      groupValue: selected,
                      onChanged: (val) {
                        if (val != null) _selectAnswer(val);
                      },
                      title: Text(option),
                      activeColor: widget.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              if (_currentIndex > 0)
                OutlinedButton.icon(
                  onPressed: _previous,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                )
              else
                const SizedBox.shrink(),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: selected == null ? null : _next,
                icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                label: Text(isLast ? 'Submit' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final total = _quizQuestions.length;
    final accuracy = total == 0 ? 0.0 : _score / total;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: widget.accentColor, size: 32),
              const SizedBox(width: 12),
              Text(
                'You scored $_score of $total',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: accuracy,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            color: widget.accentColor,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _quizQuestions.length,
              itemBuilder: (context, index) {
                final q = _quizQuestions[index];
                final selected = _answers[index];
                final isCorrect = selected == q.base.correctAnswer;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.highlight_off,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q.base.prompt,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Your answer: ${selected ?? '—'}'),
                        Text('Correct answer: ${q.base.correctAnswer}'),
                        const SizedBox(height: 8),
                        Text(
                          q.base.explanation,
                          style: TextStyle(color: Colors.grey[700], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _prepareQuiz(rebuild: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retake'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to era'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveQuestion {
  final EraQuizQuestion base;
  final List<String> shuffledOptions;

  _ActiveQuestion({required this.base, required this.shuffledOptions});
}
