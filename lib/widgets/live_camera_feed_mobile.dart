import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/genesis_theme.dart';

class LiveCameraFeed extends StatefulWidget {
  const LiveCameraFeed({
    this.name = 'MACBOOK CAMERA',
    this.streamUrl =
        'https://jontariuss-macbook-pro.tail49e2f2.ts.net:8443/macbook',
    super.key,
  });

  final String name;
  final String streamUrl;

  @override
  State<LiveCameraFeed> createState() => _LiveCameraFeedState();
}

class _LiveCameraFeedState extends State<LiveCameraFeed> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF07131D))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint(
              '999 Cipher camera WebView error: '
              '${error.errorCode} ${error.description}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.streamUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
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
                  WebViewWidget(controller: _controller),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: GenesisColors.emerald,
                      ),
                    ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      color: const Color(0xCC02070B),
                      child: const Text(
                        '● LIVE',
                        style: TextStyle(
                          color: GenesisColors.emerald,
                          fontSize: 7,
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
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              color: const Color(0xDD06111B),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.name} • SECURE LIVE FEED',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GenesisColors.emerald,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 26,
                      height: 26,
                    ),
                    onPressed: () => _controller.reload(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
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
