import 'package:flutter/material.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

// for the settings page
class FeedSource {
  final String title;
  final String rssUrl;
  final String siteUrl;
  bool enabled;
  FeedType type;

  final Image image;
  final int ttl;

  FeedSource({
    required this.title,
    required this.rssUrl,
    required this.type,
    String? siteUrl,
    this.enabled = true,
    Image? image,
    int? ttl,
    Set<FeedItem>? feedItems,
  })  : siteUrl = siteUrl ?? "",
        image = image ?? defaultFeedImage,
        ttl = ttl ?? 10;

  void toggleEnabled() {
    enabled = !enabled;
  }

  bool equals(FeedSource other) {
    return identical(this, other) ||
        (title == other.title && rssUrl == other.rssUrl);
  }
}

enum FeedType {
  predefined,
  personal
}