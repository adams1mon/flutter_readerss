
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

abstract class FeedRepository {
  Future<(FeedSource, List<FeedItem>)> getFeedByUrl(
      String url, 
      FeedType feedType
  );
  Future saveFeedSource(FeedSource source);
  Future deleteFeedSource(FeedSource source);
  Future saveFeedItem(FeedItem item);
  Future deleteFeedItem(FeedItem item);
}