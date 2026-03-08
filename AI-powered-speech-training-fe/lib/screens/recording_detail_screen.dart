import 'package:flutter/material.dart';
import '../models/recording.dart';
import '../theme/app_theme.dart';

class RecordingDetailScreen extends StatelessWidget {
  final Recording recording;

  const RecordingDetailScreen({super.key, required this.recording});

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final fb = recording.feedback;

    return Scaffold(
      appBar: AppBar(
        title: Text(recording.topicTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _scoreColor(fb.overall).withOpacity(0.1),
                  border: Border.all(
                    color: _scoreColor(fb.overall),
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fb.overall.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(fb.overall),
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Scores
            const Text(
              'Chi tiết điểm số',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _ScoreBar(label: 'Fluency', score: fb.fluency),
            _ScoreBar(label: 'Pronunciation', score: fb.pronunciation),
            _ScoreBar(label: 'Grammar', score: fb.grammar),
            _ScoreBar(label: 'Vocabulary', score: fb.vocabulary),
            _ScoreBar(label: 'Coherence', score: fb.coherence),
            const SizedBox(height: 24),

            // Transcript
            if (recording.transcript.isNotEmpty) ...[
              const Text(
                'Bài nói của bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    recording.transcript,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Strengths
            if (fb.strengths.isNotEmpty)
              _FeedbackCard(
                title: 'Điểm mạnh',
                items: fb.strengths,
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),

            // Issues
            if (fb.issues.isNotEmpty)
              _FeedbackCard(
                title: 'Cần cải thiện',
                items: fb.issues,
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),

            // Suggestions
            if (fb.suggestions.isNotEmpty)
              _FeedbackCard(
                title: 'Gợi ý luyện tập',
                items: fb.suggestions,
                icon: Icons.lightbulb_outline,
                color: AppColors.info,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreBar({required this.label, required this.score});

  Color get _color {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.gray700)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: AppColors.gray200,
                color: _color,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 36,
            child: Text(
              score.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _color),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _FeedbackCard({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: color, fontSize: 16)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14, color: AppColors.gray700, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
