
import 'package:flutter_readrss/data/feed_repository_impl.dart';
import 'package:flutter_readrss/use_case/impl/feed_use_cases_impl.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

abstract class FeedRepository {
  // Future<(FeedSource, List<FeedItem>)> getFeedByUrl(
  //     String url, 
  //     FeedType feedType,
  //     // TODO: doesn't this leak scope outside of the use case layer??
  //     String? userId,
  // );

  // Future<List<(FeedSource, List<FeedItem>)>> getPersonalFeeds(String userId);
  
  // Future saveFeedSource(FeedSource source, String userId);
  // Future deleteFeedSource(FeedSource source, String userId);
  // Future saveFeedItem(FeedItem item, String? userId);
  // Future deleteFeedItem(FeedItem item, String userId);

  Future<(FeedSourceRepoModel, List<FeedItemRepoModel>)> fetchFeedByUrl(String url);
  Future<List<(FeedSourceDetails, FeedSourceRepoModel, List<FeedItemRepoModel>)>> fetchPersonalFeeds(String userId);

  Future<FeedSourceDetails?> getFeedSourceDetails(String userId, FeedSourceRepoModel feedSourceRepoModel);
  Future<FeedItemDetails?> getFeedItemDetails(String userId, FeedItemRepoModel feedItemRepoModel);

  Future<List<(FeedItemDetails, FeedItemRepoModel)>> fetchBookmarkedFeedItems(String userId);

  Future saveFeedSourceDetails(String userId, FeedSourceDetails feedSourceDetails);
  Future deleteFeedSourceDetails(String userId, FeedSourceDetails feedSourceDetails);

  Future saveFeedItem(FeedItemRepoModel feedItem);
  Future saveFeedItemDetails(String userId, FeedItemDetails feedItemDetails);
  Future deleteFeedItemDetails(String userId, FeedItemDetails feedItemDetails);
}