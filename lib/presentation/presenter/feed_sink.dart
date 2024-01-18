import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';

// called by the presenter
abstract class FeedSourceSink {
  void setFeedSource(FeedSource feedSource);
  void setFeedSources(List<FeedSource> feedSources);
  void removeFeedSource(FeedSource feedSource);
  void removeFeedSources();
}

abstract class FeedItemsSink {
  void setFeedItems(List<FeedItem> feedItems);
  void removeFeedItemsForSource(String rssUrl);
  void removeFeedItems();
  void updateFeedItem(FeedItem feeditem);
}