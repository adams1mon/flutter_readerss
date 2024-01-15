
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

abstract class FeedRepository {
  Future<(FeedSource, List<FeedItem>)> getFeedByUrl(
      String url, 
      FeedType feedType,
      // TODO: doesn't this leak scope outside of the use case layer??
      String? userId,
  );

  Future<List<(FeedSource, List<FeedItem>)>> getPersonalFeeds(String userId);

  Future saveFeedSource(FeedSource source, String userId);
  Future deleteFeedSource(FeedSource source, String userId);
  Future saveFeedItem(FeedItem item, String? userId);
  Future deleteFeedItem(FeedItem item, String userId);
}