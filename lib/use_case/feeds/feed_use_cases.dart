import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';

abstract class FeedUseCases {
  Future<void> loadPredefinedFeeds();
  Future<void> loadPersonalFeeds();
  Future<void> loadBookmarkedFeedItems();
  Future<void> addPersonalFeedSourceByUrl(String feedUrl);
  Future<void> toggleFeedSource(FeedSource feedSource);
  Future<void> deleteFeedSource(FeedSource feedSource);
  Future<void> toggleBookmarkFeedItem(FeedItem feedItem);
  Future<void> toggleLikeFeedItem(FeedItem feedItem);
  Future<void> viewFeedItem(FeedItem feedItem);
}
