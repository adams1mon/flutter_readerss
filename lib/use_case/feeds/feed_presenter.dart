import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';

abstract class FeedPresenter {

  void setFeedSource(FeedSource feedSource);
  void deleteFeedSource(FeedSource feedSource);

  void setFeedItems(List<FeedItem> feedItems);
  void updateFeedItem(FeedItem feedItem);
  void deleteFeedItemsForSource(FeedSource feedSource);
  void deletePersonalFeedItems();

  void setBookmarkedFeedItems(List<FeedItem> feedItems);
  void deleteBookmarkedFeedItems();
}