
import 'package:flutter_readrss/repository/firestore/model/feed_item_repo_model.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_source_repo_model.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item_details.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source_details.dart';

abstract class FeedRepository {
  // TODO: break dependency on repo layer because of *RepoModel classes
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