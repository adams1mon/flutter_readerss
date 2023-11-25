import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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

  Future<bool> _openUriInExternalApp(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log("failed to launch uri $uri in external app", error: e);
      return Future.error(e);
    }
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
        appBar: ReadrssAppBar(title: "", context: context),
        backgroundColor: colors(context).background,
        body: FutureBuilder(
          future: _openUriInWebView(uri),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.none) {
              if (snapshot.hasError) {
                // missing uri scheme
                return Center(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Failed to load the article from the article's url.\nYou can try loading it with another app by clicking the link below.\n",
                          style: textTheme(context).bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          // TODO: handle PlatformException or other Future<false> if it cannot be opened
                          onTap: () => _openUriInExternalApp(uri),
                          child: Text(
                            url,
                            style: textTheme(context)
                                .bodyLarge
                                ?.copyWith(color: Colors.blue),
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ),
                  ),
                );
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
