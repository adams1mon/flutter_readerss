import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

// called by the presenter
abstract class FeedSink {
  void setFeedSource(FeedSource feedSource);
  void removeFeedSource(FeedSource feedSource);
  void setFeedItems(String rssUrl, List<FeedItem> feedItems);
  void updateFeedItem(FeedItem feeditem);
}