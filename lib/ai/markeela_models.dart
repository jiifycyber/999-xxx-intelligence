class MarkeelaMessage {
  final String role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const MarkeelaMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
  });
}

class MarkeelaResponse {
  final String text;
  final String mode;
  final String? model;
  final List<String> suggestedActions;
  final Map<String, dynamic> raw;

  const MarkeelaResponse({
    required this.text,
    required this.mode,
    this.model,
    this.suggestedActions = const [],
    this.raw = const {},
  });

  factory MarkeelaResponse.fromMap(Map<String, dynamic> m) {
    return MarkeelaResponse(
      text: '${m['text'] ?? m['message'] ?? ''}',
      mode: '${m['mode'] ?? 'assistant'}',
      model: m['model']?.toString(),
      suggestedActions: (m['suggested_actions'] as List? ?? const [])
          .map((e) => '$e')
          .toList(),
      raw: m,
    );
  }
}
