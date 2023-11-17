import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

// for the feed pages
class FeedItem {
  final String feedSourceTitle;
  final String feedSourceLink; // this is like a foreign key
  final String title;
  bool bookmarked;
  bool liked;
  final String? description;
  final String link;

  final Image sourceIcon;

  final DateTime? pubDate;

  final int views;
  final int likes;

  FeedItem({
    required this.feedSourceTitle,
    required this.feedSourceLink,
    required this.title,
    this.bookmarked = false, 
    this.liked = false, 
    this.description,
    required this.link,
    Image? sourceIcon,
    this.pubDate,
    required this.views,
    required this.likes,
  }) : sourceIcon = sourceIcon ?? defaultFeedImage;

  String getDate() {
    return "${pubDate!.year}/${pubDate!.month}/${pubDate!.day}";
  }
}
