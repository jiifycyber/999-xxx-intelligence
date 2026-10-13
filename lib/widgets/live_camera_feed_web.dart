import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../core/genesis_theme.dart';

class LiveCameraFeed extends StatefulWidget {
  const LiveCameraFeed({
    this.name = 'MACBOOK CAMERA',
    this.streamUrl =
        'https://ic391-defense-command.tail49e2f2.ts.net:8443/macbook',
    super.key,
  });

  final String name;
  final String streamUrl;

  @override
  State<LiveCameraFeed> createState() => _LiveCameraFeedState();
}

class _LiveCameraFeedState extends State<LiveCameraFeed> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();

    _viewType = 'macbook-webrtc-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final frame = web.HTMLIFrameElement()
          ..src = widget.streamUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = '0'
          ..setAttribute('allow', 'autoplay; fullscreen')
          ..setAttribute('allowfullscreen', 'true');

        return frame;
      },
    );
  }

  void _openFullscreen() {
    web.window.open(widget.streamUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF07131D),
        border: Border.all(color: GenesisColors.emerald),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HtmlElementView(viewType: _viewType),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      color: const Color(0xCC02070B),
                      child: const Text(
                        '● WEBRTC LIVE',
                        style: TextStyle(
                          color: GenesisColors.emerald,
                          fontSize: 6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              color: const Color(0xDD06111B),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.name} • SECURE LOW-LATENCY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GenesisColors.emerald,
                        fontSize: 5.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    constraints:
                        const BoxConstraints.tightFor(width: 24, height: 24),
                    padding: EdgeInsets.zero,
                    tooltip: 'Open full screen',
                    onPressed: _openFullscreen,
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      size: 15,
                      color: GenesisColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
