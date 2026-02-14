class Quote {
  Quote({
    required this.id,
    required this.author,
    required this.text,
    required this.sourceWork,
    required this.sourceRef,
    required this.behaviorIntent,
    required this.contextTags,
  });

  final String id;
  final String author;
  final String text;
  final String sourceWork;
  final String sourceRef;
  final String behaviorIntent;
  final List<String> contextTags;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      author: json['author'] as String,
      text: json['text'] as String,
      sourceWork: json['source_work'] as String,
      sourceRef: json['source_ref'] as String,
      behaviorIntent: (json['behavior_intent'] as String?) ?? '',
      contextTags: ((json['context_tags'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Recommendation {
  Recommendation({
    required this.context,
    required this.title,
    required this.quoteLinkExplanation,
    required this.steps,
    required this.minutes,
    required this.expectedOutcome,
    required this.completionCriteria,
    required this.journalPrompt,
  });

  final String context;
  final String title;
  final String quoteLinkExplanation;
  final List<String> steps;
  final int minutes;
  final String expectedOutcome;
  final String completionCriteria;
  final String journalPrompt;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      context: json['context'] as String,
      title: json['action_title'] as String,
      quoteLinkExplanation: (json['quote_link_explanation'] as String?) ?? '',
      steps: ((json['action_steps'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
      minutes: (json['estimated_minutes'] as num).toInt(),
      expectedOutcome: (json['expected_outcome'] as String?) ?? '',
      completionCriteria: (json['completion_criteria'] as String?) ?? '',
      journalPrompt: json['journal_prompt'] as String,
    );
  }
}

class DailyPackage {
  DailyPackage({
    required this.dateLocal,
    required this.timezone,
    required this.userContext,
    required this.quote,
    required this.recommendation,
  });

  final String dateLocal;
  final String timezone;
  final String? userContext;
  final Quote quote;
  final Recommendation recommendation;

  factory DailyPackage.fromJson(Map<String, dynamic> json) {
    return DailyPackage(
      dateLocal: json['date_local'] as String,
      timezone: json['timezone'] as String,
      userContext: json['user_context'] as String?,
      quote: Quote.fromJson(json['quote'] as Map<String, dynamic>),
      recommendation:
          Recommendation.fromJson(json['recommendation'] as Map<String, dynamic>),
    );
  }
}

class Favorite {
  Favorite({
    required this.id,
    required this.userId,
    required this.quoteId,
    required this.createdAtUtc,
  });

  final String id;
  final String userId;
  final String quoteId;
  final String createdAtUtc;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quoteId: json['quote_id'] as String,
      createdAtUtc: json['created_at_utc'] as String,
    );
  }
}
