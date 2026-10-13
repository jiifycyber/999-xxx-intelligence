import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../core/genesis_theme.dart';

class AgentXScreen extends StatefulWidget {
  const AgentXScreen({super.key});

  @override
  State<AgentXScreen> createState() => _AgentXScreenState();
}

class _AgentXScreenState extends State<AgentXScreen> {
  static const String _url = 'https://ic391-defense-command.tail49e2f2.ts.net';

  late final String _viewType;

  @override
  void initState() {
    super.initState();

    _viewType = 'agent-x-web-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        return html.IFrameElement()
          ..src = _url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'microphone'
          ..setAttribute(
            'sandbox',
            'allow-same-origin allow-scripts allow-forms '
                'allow-popups allow-modals allow-downloads',
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GenesisColors.voidBlack,
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF050B1A),
              border: Border(
                bottom: BorderSide(color: GenesisColors.border),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  color: GenesisColors.gold,
                ),
                SizedBox(width: 9),
                Text(
                  'AGENT X',
                  style: TextStyle(
                    color: GenesisColors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: _viewType),
          ),
        ],
      ),
    );
  }
}
