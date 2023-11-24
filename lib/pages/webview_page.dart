
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  
  late final WebViewController _webViewController;

  void _showWebViewError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("An error occurred..."),
      ),
    );
  }

  void _openUrlInWebView(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      _showWebViewError();

      // go back to the previous page
      // Navigator.of(context).pop();
      return;
    }

    try {
      _webViewController.loadRequest(uri);
    } catch (e) {
      _showWebViewError();
      log("error while loading webview url $url", error: e);
    }
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _openUrlInWebView(widget.url);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: colors(context).background,
      body: Center(
        child: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}