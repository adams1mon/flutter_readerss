import 'package:flutter/material.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

// for the settings page
class FeedSource {
  final String id;
  final String title;
  final String rssUrl;
  final String siteUrl;
  bool enabled;
  FeedType type;

  final Image image;
  final int ttl;

  FeedSource({
    required this.id,
    required this.title,
    required this.rssUrl,
    required this.type,
    required this.siteUrl,
    this.enabled = true,
    Image? image,
    required this.ttl,
    Set<FeedItem>? feedItems,
  }) : image = image ?? defaultFeedImage;

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