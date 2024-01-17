
import 'package:flutter_readrss/use_case/feeds/model/feed_type.dart';

class FeedItem {
  final String id; 
  final String feedSourceTitle;
  final String feedSourceRssUrl; // this is like a foreign key
  final String title;
  bool bookmarked;
  bool liked;
  final String? description;
  final String articleUrl;
  final String? sourceIconUrl;

  final DateTime? pubDate;

  int views;
  int likes;

  final FeedType type;

  FeedItem({
    required this.id,
    required this.feedSourceTitle,
    required this.feedSourceRssUrl,
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.sourceIconUrl,
    required this.pubDate,
    required this.views,
    required this.likes,
    required this.bookmarked,
    required this.liked, 
    required this.type,
  });

  String getDate() {
    return "${pubDate!.year}/${pubDate!.month}/${pubDate!.day}";
  }
}
