import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../models/topic.dart';
import '../models/recording.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  final Topic topic;

  const PracticeScreen({super.key, required this.topic});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isUploading = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _recordingPath;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _elapsedSeconds++);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền microphone để ghi âm'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();

    setState(() => _isRecording = false);

    if (path != null) {
      _recordingPath = path;
      _uploadAndAnalyze();
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_recordingPath == null) return;

    setState(() => _isUploading = true);

    try {
      final result = await ApiService.uploadRecording(
        audioFilePath: _recordingPath!,
        topicId: widget.topic.id,
        duration: _elapsedSeconds,
      );

      if (mounted) {
        if (result.containsKey('feedback')) {
          final recording = Recording.fromJson(result);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => _FeedbackResultScreen(recording: recording),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Lỗi xử lý recording'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String get _timerDisplay {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Topic info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.prompt,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.gray700,
                        height: 1.5,
                      ),
                    ),
                    if (widget.topic.questions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Câu hỏi gợi ý:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.topic.questions.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${e.key + 1}. ${e.value}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Timer
            Text(
              _timerDisplay,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: AppColors.gray900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording
                  ? 'Đang ghi âm...'
                  : _isUploading
                      ? 'Đang phân tích bằng AI...'
                      : 'Nhấn để bắt đầu ghi âm',
              style: TextStyle(
                fontSize: 16,
                color: _isRecording ? AppColors.error : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 40),

            // Record button
            if (_isUploading)
              Column(
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI đang phân tích bài nói của bạn...\nQuá trình này có thể mất vài giây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isRecording ? 80 : 100,
                  height: _isRecording ? 80 : 100,
                  decoration: BoxDecoration(
                    color: _isRecording ? AppColors.error : AppColors.primary,
                    shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: _isRecording
                        ? BorderRadius.circular(16)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? AppColors.error : AppColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            if (!_isRecording && !_isUploading)
              Text(
                _isRecording
                    ? 'Nhấn  để dừng ghi âm'
                    : 'Thời lượng gợi ý: ${widget.topic.duration}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============== Feedback Result Screen ==============

class _FeedbackResultScreen extends StatelessWidget {
  final Recording recording;

  const _FeedbackResultScreen({required this.recording});

  @override
  Widget build(BuildContext context) {
    final fb = recording.feedback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả phân tích'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall score
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Score breakdown
            const Text(
              'Chi tiết điểm số',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _ScoreRow(label: 'Fluency (Lưu loát)', score: fb.fluency),
            _ScoreRow(label: 'Pronunciation (Phát âm)', score: fb.pronunciation),
            _ScoreRow(label: 'Grammar (Ngữ pháp)', score: fb.grammar),
            _ScoreRow(label: 'Vocabulary (Từ vựng)', score: fb.vocabulary),
            _ScoreRow(label: 'Coherence (Mạch lạc)', score: fb.coherence),
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
            if (fb.strengths.isNotEmpty) ...[
              _FeedbackSection(
                title: 'Điểm mạnh',
                items: fb.strengths,
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
            ],

            // Issues
            if (fb.issues.isNotEmpty) ...[
              _FeedbackSection(
                title: 'Cần cải thiện',
                items: fb.issues,
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
            ],

            // Suggestions
            if (fb.suggestions.isNotEmpty) ...[
              _FeedbackSection(
                title: 'Gợi ý luyện tập',
                items: fb.suggestions,
                icon: Icons.lightbulb_outline,
                color: AppColors.info,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Quay về trang chính'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.warning;
    return AppColors.error;
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;

  const _ScoreRow({required this.label, required this.score});

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
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
              ),
            ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _FeedbackSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
