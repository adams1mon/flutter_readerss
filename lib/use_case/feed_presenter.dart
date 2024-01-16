import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

abstract class FeedPresenter {
  void setFeed(FeedSource feedSource, List<FeedItem> feedItems);
  void setBookmarkedFeedItems(List<FeedItem> feedItems);
  void removeFeedSource(FeedSource feedSource);
  void updateFeedItem(FeedItem feedItem);
}