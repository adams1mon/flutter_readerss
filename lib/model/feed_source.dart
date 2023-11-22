import 'package:flutter/material.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/styles/styles.dart';

// for the settings page
class FeedSource {
  final String title;
  final String rssUrl;
  final String siteUrl;
  bool enabled;

  final Image image;
  final int ttl;

  final List<FeedItem> feedItems;

  FeedSource({
    required this.title,
    required this.rssUrl,
    String? siteUrl,
    this.enabled = true,
    required image,
    int? ttl,
    feedItems,
  })  : siteUrl = siteUrl ?? "",
        image = image ?? defaultFeedImage,
        feedItems = feedItems ?? <FeedItem>[],
        ttl = ttl ?? 10;

  void toggleEnabled() {
    enabled = !enabled;
  }

  bool equals(FeedSource other) {
    return identical(this, other) ||
        (title == other.title && siteUrl == other.siteUrl);
  }
}
