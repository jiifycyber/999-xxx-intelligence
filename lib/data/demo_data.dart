import 'package:flutter/material.dart';

import '../models/security_models.dart';

abstract final class DemoData {
  static const destinations = <NavDestinationItem>[
    NavDestinationItem('COMMAND', Icons.home_rounded),
    NavDestinationItem('THREAT HUNT', Icons.radar_rounded),
    NavDestinationItem('ATTACK GRAPH', Icons.hub_rounded),
    NavDestinationItem('IDENTITIES', Icons.badge_outlined),
    NavDestinationItem('BIOMETRICS', Icons.fingerprint_rounded),
    NavDestinationItem('ENDPOINTS', Icons.devices_rounded),
    NavDestinationItem('NETWORK', Icons.account_tree_rounded),
    NavDestinationItem('AI AUTHORITY', Icons.psychology_alt_rounded),
    NavDestinationItem('WATCHLIST', Icons.face_retouching_natural_rounded),
    NavDestinationItem('FORENSICS', Icons.manage_search_rounded),
    NavDestinationItem('INCIDENTS', Icons.warning_amber_rounded),
    NavDestinationItem('RECOVERY', Icons.settings_backup_restore_rounded),
    NavDestinationItem('POLICY CHAMBER', Icons.policy_rounded),
    NavDestinationItem('EVIDENCE VAULT', Icons.inventory_2_outlined),
  ];

  static const assets = <ProtectedAsset>[
    ProtectedAsset(
      name: 'MACBOOK PRO',
      address: '100.107.15.99',
      type: 'PRIMARY COCKPIT',
      icon: Icons.laptop_mac_rounded,
    ),
    ProtectedAsset(
      name: 'IPHONE',
      address: '100.119.50.61',
      type: 'MOBILE COMMAND',
      icon: Icons.phone_iphone_rounded,
    ),
    ProtectedAsset(
      name: 'MAC MINI',
      address: 'PLANNED',
      type: 'GENESIS ENGINE',
      icon: Icons.dns_rounded,
    ),
    ProtectedAsset(
      name: 'CLOUD CORE',
      address: 'PRIVATE RELAY',
      type: 'SECURE SERVICES',
      icon: Icons.cloud_done_rounded,
    ),
    ProtectedAsset(
      name: 'FIREWALL',
      address: 'EDGE GATEWAY',
      type: 'NETWORK CONTROL',
      icon: Icons.grid_view_rounded,
    ),
    ProtectedAsset(
      name: 'CAMERA NETWORK',
      address: 'AUTHORIZED ONLY',
      type: 'PHYSICAL SECURITY',
      icon: Icons.videocam_outlined,
    ),
  ];

  static const events = <SecurityEvent>[
    SecurityEvent(
      time: '14:20:11',
      title: 'Evidence sealed',
      detail: 'Incident artifacts written to protected vault',
      severity: Severity.secure,
    ),
    SecurityEvent(
      time: '14:19:48',
      title: 'Endpoint isolated',
      detail: 'Simulation approved by Founder Authority',
      severity: Severity.info,
    ),
    SecurityEvent(
      time: '14:19:15',
      title: 'Token revoked',
      detail: 'All suspicious sessions terminated',
      severity: Severity.secure,
    ),
    SecurityEvent(
      time: '14:19:02',
      title: 'Biometric challenge issued',
      detail: 'Liveness and hardware key requested',
      severity: Severity.warning,
    ),
    SecurityEvent(
      time: '14:18:33',
      title: 'Impossible travel detected',
      detail: 'Identity access pattern entered investigation',
      severity: Severity.critical,
    ),
  ];

  static const watchlistReview = WatchlistReview(
    camera: 'NORTH ENTRY - CAMERA 03',
    time: '14:12:09',
    confidence: 94,
    liveness: true,
  );
}
