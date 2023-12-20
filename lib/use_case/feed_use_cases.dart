import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

abstract class FeedUseCases {
  Future<void> loadPredefinedFeedsByUrls(List<String> feedUrls);
  Future<void> loadPersonalFeedSourceByUrl(String feedUrl);
  Future<void> toggleFeedSource(FeedSource feedSource);
  Future<void> deleteFeedSource(FeedSource feedSource);
  Future<void> bookmarkToggleFeedItem(FeedItem feedItem);
  Future<void> likeFeedItem(FeedItem feedItem);
  Future<void> viewFeedItem(FeedItem feedItem);
}
