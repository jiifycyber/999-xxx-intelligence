import 'package:flutter/material.dart';

enum Severity { secure, info, warning, critical }

extension SeverityStyle on Severity {
  Color get color => switch (this) {
        Severity.secure => const Color(0xFF22E89A),
        Severity.info => const Color(0xFF27C8F7),
        Severity.warning => const Color(0xFFFFC857),
        Severity.critical => const Color(0xFFFF4D5A),
      };

  String get label => name.toUpperCase();
}

class SecurityEvent {
  const SecurityEvent({
    required this.time,
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String time;
  final String title;
  final String detail;
  final Severity severity;
}

class ProtectedAsset {
  const ProtectedAsset({
    required this.name,
    required this.address,
    required this.type,
    required this.icon,
    this.online = true,
    this.risk = 0,
  });

  final String name;
  final String address;
  final String type;
  final IconData icon;
  final bool online;
  final int risk;
}

class NavDestinationItem {
  const NavDestinationItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class WatchlistReview {
  const WatchlistReview({
    required this.camera,
    required this.time,
    required this.confidence,
    required this.liveness,
  });

  final String camera;
  final String time;
  final int confidence;
  final bool liveness;
}
