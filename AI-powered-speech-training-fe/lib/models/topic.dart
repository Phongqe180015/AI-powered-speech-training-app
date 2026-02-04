class Topic {
  final String id;
  final String title;
  final String prompt;
  final TopicLevel level;
  final List<String> tags;
  final List<String> questions;
  final String duration;
  final String createdAt;

  Topic({
    required this.id,
    required this.title,
    required this.prompt,
    required this.level,
    required this.tags,
    required this.questions,
    required this.duration,
    required this.createdAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      level: TopicLevel.values.firstWhere(
        (e) => e.name == json['level'].toString().toLowerCase(),
      ),
      tags: List<String>.from(json['tags'] as List),
      questions: List<String>.from(json['questions'] as List),
      duration: json['duration'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'level': level.name,
      'tags': tags,
      'questions': questions,
      'duration': duration,
      'createdAt': createdAt,
    };
  }
}

enum TopicLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case TopicLevel.beginner:
        return 'Beginner';
      case TopicLevel.intermediate:
        return 'Intermediate';
      case TopicLevel.advanced:
        return 'Advanced';
    }
  }
}
