import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';

class FeedSourcesEvent {
  const FeedSourcesEvent({required this.feedSources});
  final List<FeedSource> feedSources;
}

class FeedItemsEvent {
  const FeedItemsEvent({required this.feedItems});
  final List<FeedItem> feedItems;
}
