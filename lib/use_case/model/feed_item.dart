
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
  final String? sourceIconUrl;

  final DateTime? pubDate;

  int views;
  int likes;

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
  });

  String getDate() {
    return "${pubDate!.year}/${pubDate!.month}/${pubDate!.day}";
  }
}
