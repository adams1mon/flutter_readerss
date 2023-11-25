import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/styles/styles.dart';
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

  // TODO: think of a way to show errors to the user, or recover from them somehow
  // snackbar can't be triggered from the build method
  void _showWebViewError({String msg = "An unknown error occurred"}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  String? _getUrlFromRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _openUriInWebView(Uri uri) {
    try {
      return _webViewController.loadRequest(uri, method: LoadRequestMethod.get);
    } on ArgumentError catch (e) {
      // missing uri scheme can trigger this error
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
      // _showWebViewError(msg: "Failed to load the article");
      log("webview got null url from route: $url");

      // navigating back here cancels the build method so the user doesn't even see anything
      _navigateBack();
      return Text("error");
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      // _showWebViewError(msg: "Failed to load bad URL");
      log("webview failed to parse $url into Uri object");

      // navigating back here cancels the build method so the user doesn't even see anything
      _navigateBack();
      return Text("error");
    }

    return SafeArea(
      child: Scaffold(
        appBar: ReadrssAppBar(title: "", context: context),
        backgroundColor: colors(context).background,
        body: Center(
          child: FutureBuilder(
            future: _openUriInWebView(uri),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {

                  // missing uri scheme
                  // TODO: maybe display the url and let the user try to open it with a built-in app
                  // e.g. Chrome, Safari, etc. via the launch_url package?
                  return Text("Failed to load the article");
                }

                // data is ready
                return WebViewWidget(
                  controller: _webViewController,
                );
              } else {

                // TODO: what should be returned when we need a null widget?
                return Text("should not appear ever");
              }
            },
          ),
        ),
      ),
    );
  }
}
