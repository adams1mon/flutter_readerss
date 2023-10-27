import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

// for the feed pages
class FeedItem {
  final String feedSourceTitle;
  final String title;
  bool bookmarked;
  final String? description;
  final String link;
  final String? author;
  final Image sourceIcon;

  final DateTime? pubDate;

  final int views;
  final int likes;

  FeedItem({
    required this.feedSourceTitle,
    required this.title,
    this.bookmarked = false, 
    this.description,
    required this.link,
    this.author,
    Image? sourceIcon,
    this.pubDate,
    required this.views,
    required this.likes,
  }) : sourceIcon = sourceIcon ?? Image.asset(defaultFeedIcon);
}
