import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

// for the feed pages
class FeedItem {
  final String feedSourceTitle;
  final String title;
  bool bookmarked;
  bool liked;
  final String? description;
  final String link;

  // TODO: do we need the author? if yes, where do we display it?
  final String? author;
  final Image sourceIcon;

  // TODO: where do we display the date?
  final DateTime? pubDate;

  final int views;
  final int likes;

  FeedItem({
    required this.feedSourceTitle,
    required this.title,
    this.bookmarked = false, 
    this.liked = false, 
    this.description,
    required this.link,
    this.author,
    Image? sourceIcon,
    this.pubDate,
    required this.views,
    required this.likes,
  }) : sourceIcon = sourceIcon ?? Image.asset(defaultFeedIcon);
}
