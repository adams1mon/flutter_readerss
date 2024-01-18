
// returned by the rss fetcher (network 'model')
class FeedItemNetworkModel {
  final String title;
  final String? description;
  final String articleUrl;
  final DateTime? pubDate;

  FeedItemNetworkModel({
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.pubDate,
  });
}
