import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/components/app_bar.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebViewPage extends StatefulWidget {
  const ArticleWebViewPage({
    super.key,
  });

  @override
  State<ArticleWebViewPage> createState() => _ArticleWebViewPageState();
}

class _ArticleWebViewPageState extends State<ArticleWebViewPage> {
  late final WebViewController _webViewController;

  String? _getUrlFromRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _openUriInWebView(Uri uri) async {
    try {
      return await _webViewController.loadRequest(uri,
          method: LoadRequestMethod.get);
    } catch (e) {
      // only a missing uri scheme can trigger this error
      log("webview failed to load uri: $e");
      return Future.error(e);
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    final url = _getUrlFromRoute(context);
    if (url == null) {
      log("webview got null url from route: $url");

      // navigating back here cancels the build method so the user doesn't see anything
      _navigateBack();
      return nullWidget;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      log("webview failed to parse $url into Uri object");

      // navigating back here cancels the build method so the user doesn't see anything
      _navigateBack();
      return nullWidget;
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: colors(context).background,
        body: FutureBuilder(
          future: _openUriInWebView(uri),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.none) {
              if (snapshot.hasError) {
                // missing uri scheme
                return ArticleWebViewError(url: url);
              }

              // data is ready
              return WebViewWidget(
                controller: _webViewController,
              );
            }

            // this should never be returned
            return nullWidget;
          },
        ),
      ),
    );
  }
}

class ArticleWebViewError extends StatelessWidget {
  const ArticleWebViewError({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Failed to load the article from the following url:",
              style: textTheme(context).bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              url,
              style:
                  textTheme(context).bodyLarge?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
