import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/genesis_theme.dart';

class AgentXScreen extends StatefulWidget {
  const AgentXScreen({super.key});

  @override
  State<AgentXScreen> createState() => _AgentXScreenState();
}

class _AgentXScreenState extends State<AgentXScreen> {
  static final Uri _url =
      Uri.parse('https://ic391-defense-command.tail49e2f2.ts.net');

  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(GenesisColors.voidBlack)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) {
              setState(() => _progress = value);
            }
          },
        ),
      )
      ..loadRequest(_url);
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
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  color: GenesisColors.gold,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'AGENT X',
                    style: TextStyle(
                      color: GenesisColors.text,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _controller.reload,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: GenesisColors.cyan,
                  ),
                ),
              ],
            ),
          ),
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 2,
            ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
