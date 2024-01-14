import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

// for the feed pages
class FeedItem {
  final String id; 
  final String feedSourceTitle;
  final String feedSourceRssUrl; // this is like a foreign key
  final String title;
  bool bookmarked;
  bool liked;
  final String? description;
  final String articleUrl;

  final Image sourceIcon;

  final DateTime? pubDate;

  final int views;
  final int likes;

  FeedItem({
    required this.id,
    required this.feedSourceTitle,
    required this.feedSourceRssUrl,
    required this.title,
    required this.description,
    required this.articleUrl,
    Image? sourceIcon,
    required this.pubDate,
    required this.views,
    required this.likes,
    required this.bookmarked,
    required this.liked, 
  }) : sourceIcon = sourceIcon ?? defaultFeedImage;

  String getDate() {
    return "${pubDate!.year}/${pubDate!.month}/${pubDate!.day}";
  }
}
