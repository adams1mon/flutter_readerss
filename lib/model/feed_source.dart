import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

// for the settings page
class FeedSource {
  final String title;
  final String link;
  bool enabled;

  final Image image;
  final int ttl;

  FeedSource({
    required this.title,
    required this.link,
    this.enabled = true,
    required image,
    this.ttl = 10,
  }) : image = image ?? defaultFeedImage;

  void toggleEnabled() {
    enabled = !enabled;
  }

  bool equals(FeedSource other) {
    return identical(this, other) || (title == other.title && link == other.link);
  }
}