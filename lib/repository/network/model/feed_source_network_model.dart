
// returned by the rss fetcher (network 'model')
class FeedSourceNetworkModel {
  final String title;
  final String rssUrl;
  final String? siteUrl;
  final String? iconUrl;
  final int ttl;

  FeedSourceNetworkModel({
    required this.title,
    required this.rssUrl,
    required this.siteUrl,
    required this.iconUrl,
    required this.ttl,
  });
}