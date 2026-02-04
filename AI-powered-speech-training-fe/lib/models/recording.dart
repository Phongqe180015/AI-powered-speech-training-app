import 'feedback.dart';

class Recording {
  final String id;
  final String topicId;
  final String topicTitle;
  final String audioUrl;
  final int duration;
  final String createdAt;
  final String transcript;
  final Feedback feedback;

  Recording({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    required this.transcript,
    required this.feedback,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      topicTitle: json['topicTitle'] as String,
      audioUrl: json['audioUrl'] as String,
      duration: json['duration'] as int,
      createdAt: json['createdAt'] as String,
      transcript: json['transcript'] as String,
      feedback: Feedback.fromJson(json['feedback'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'topicTitle': topicTitle,
      'audioUrl': audioUrl,
      'duration': duration,
      'createdAt': createdAt,
      'transcript': transcript,
      'feedback': feedback.toJson(),
    };
  }
}
