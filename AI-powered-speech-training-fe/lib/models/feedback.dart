class Feedback {
  final double overall;
  final double fluency;
  final double pronunciation;
  final double grammar;
  final double vocabulary;
  final double coherence;
  final List<String> strengths;
  final List<String> issues;
  final List<String> suggestions;

  Feedback({
    required this.overall,
    required this.fluency,
    required this.pronunciation,
    required this.grammar,
    required this.vocabulary,
    required this.coherence,
    required this.strengths,
    required this.issues,
    required this.suggestions,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      overall: (json['overall'] as num).toDouble(),
      fluency: (json['fluency'] as num).toDouble(),
      pronunciation: (json['pronunciation'] as num).toDouble(),
      grammar: (json['grammar'] as num).toDouble(),
      vocabulary: (json['vocabulary'] as num).toDouble(),
      coherence: (json['coherence'] as num).toDouble(),
      strengths: List<String>.from(json['strengths'] as List),
      issues: List<String>.from(json['issues'] as List),
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'fluency': fluency,
      'pronunciation': pronunciation,
      'grammar': grammar,
      'vocabulary': vocabulary,
      'coherence': coherence,
      'strengths': strengths,
      'issues': issues,
      'suggestions': suggestions,
    };
  }
}
