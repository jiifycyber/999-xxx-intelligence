class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.occurredAt,
    required this.provider,
    required this.category,
    required this.severity,
    required this.confidence,
    required this.threatScore,
    required this.confirmed,
    this.sourceCountry,
    this.targetCountry,
    this.sourceIpPrefix,
    this.targetAssetId,
    this.endpointId,
    this.ruleName,
    this.action,
    this.confirmationBasis,
    this.sanitizedPath,
    this.itemPath,
    this.processName,
    this.processPath,
    this.details,
    this.protocol,
    this.port,
  });

  final String id;
  final DateTime occurredAt;

  final String provider;
  final String category;
  final String severity;

  final double confidence;
  final int threatScore;

  final bool confirmed;

  final String? sourceCountry;
  final String? targetCountry;
  final String? sourceIpPrefix;

  final String? targetAssetId;
  final String? endpointId;

  final String? ruleName;
  final String? action;

  final String? confirmationBasis;

  final String? sanitizedPath;
  final String? itemPath;
  final String? processName;
  final String? processPath;
  final String? details;
  final String? protocol;
  final int? port;

  bool get hasFileEvidence {
    final path = (itemPath ?? sanitizedPath ?? '').trim();
    return path.isNotEmpty;
  }

  bool get hasProcessEvidence {
    return (processPath ?? '').trim().isNotEmpty;
  }

  factory SecurityEvent.fromMap(Map<String, dynamic> map) {
    final rawMetadata = map['metadata'];
    final metadata = rawMetadata is Map
        ? Map<String, dynamic>.from(rawMetadata)
        : <String, dynamic>{};

    return SecurityEvent(
      id: map['id'] as String,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      provider: map['provider'] as String? ?? 'manual',
      category: map['category'] as String? ?? 'OBSERVATION',
      severity: map['severity'] as String? ?? 'INFO',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      threatScore: (map['threat_score'] as num?)?.toInt() ?? 0,
      confirmed: map['confirmed'] as bool? ?? false,
      sourceCountry: map['source_country'] as String?,
      targetCountry: map['target_country'] as String?,
      sourceIpPrefix: map['source_ip_prefix'] as String?,
      targetAssetId: map['target_asset_id'] as String?,
      endpointId: map['endpoint_id'] as String?,
      ruleName: map['rule_name'] as String?,
      action: map['action'] as String?,
      confirmationBasis: map['confirmation_basis'] as String?,
      sanitizedPath: map['sanitized_path'] as String?,
      itemPath: metadata['item_path'] as String?,
      processName: metadata['process_name'] as String?,
      processPath: metadata['process_path'] as String?,
      details: metadata['details'] as String?,
      protocol: metadata['protocol'] as String?,
      port: (metadata['port'] as num?)?.toInt(),
    );
  }

  bool get isGlobalTraffic => category == 'GLOBAL_TRAFFIC';

  bool get isConfirmedIncident => category == 'CONFIRMED_INCIDENT' && confirmed;

  bool get requiresImmediateAttention =>
      severity == 'CRITICAL' || severity == 'HIGH' || isConfirmedIncident;
}
