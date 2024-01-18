import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_readrss/repository/firestore/collections.dart';
import 'package:flutter_readrss/repository/firestore/mapper/feed_mappers.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_item_repo_model.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_source_repo_model.dart';
import 'package:flutter_readrss/repository/firestore/model/personal_feed_item_model.dart';
import 'package:flutter_readrss/repository/firestore/model/personal_feed_source_model.dart';
import 'package:flutter_readrss/repository/network/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/feeds/feed_repository.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item_details.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source_details.dart';


class FeedRepositoryImpl implements FeedRepository {
  final firestore = FirebaseFirestore.instance;

  @override
  Future<(FeedSourceRepoModel, List<FeedItemRepoModel>)> fetchFeedByUrl(
      String url) async {
    log("fetching feed by url $url");

    // TODO: error handling

    // 1. fetch source and items from the rss sites
    final (sourceNetworkModel, itemNetworkModels) = await RssFetcher.fetch(url);

    // 2. fetch views + likes from the db
    final feedItemModels = await Future.wait(
      itemNetworkModels.map(
        (itemNetworkModel) async {
          final itemId =
              FeedItemRepoModel.generateId(itemNetworkModel.articleUrl);

          final firestoreDoc =
              await firestore.collection(feedItemsCollection).doc(itemId).get();

          var views = 0;
          var likes = 0;
          if (firestoreDoc.exists) {
            final itemModel = FeedItemRepoModel.fromFirebaseDoc(firestoreDoc);
            views = itemModel.views;
            likes = itemModel.likes;
          }

          return RepoFeedItemMapper.fromNetworkModel(
            itemNetworkModel,
            sourceNetworkModel,
            views,
            likes,
          );
        },
      ),
    );

    final feedSourceModel =
        RepoFeedSourceMapper.fromNetworkModel(sourceNetworkModel);
    return (feedSourceModel, feedItemModels);
  }

  @override
  Future<
      List<
          (
            FeedSourceDetails,
            FeedSourceRepoModel,
            List<FeedItemRepoModel>,
          )>> fetchPersonalFeeds(String userId) async {
    // get personal feeds
    final feedCollection = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .get();

    return Future.wait(
      feedCollection.docs.map((doc) async {
        final personalFeed = PersonalFeedSourceModel.fromFirebaseDoc(doc);

        final sourceDetails = FeedSourceDetails(
            feedSourceUrl: personalFeed.feedSourceUrl,
            enabled: personalFeed.enabled);

        // fetch every feed by url
        final (source, items) =
            await fetchFeedByUrl(personalFeed.feedSourceUrl);
        return (sourceDetails, source, items);
      }),
    );
  }
  
  @override
  Future<List<FeedSourceDetails>> getPersonalFeeds(String userId) async {
    // get personal feeds
    final feedCollection = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .get();

    return feedCollection.docs.map((doc) {
        final personalFeed = PersonalFeedSourceModel.fromFirebaseDoc(doc);

        final sourceDetails = FeedSourceDetails(
            feedSourceUrl: personalFeed.feedSourceUrl,
            enabled: personalFeed.enabled);

        return sourceDetails;
      }).toList();
  }

  @override
  Future<List<(FeedItemDetails, FeedItemRepoModel)>> fetchBookmarkedFeedItems(
      String userId) async {
    final query = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedItemsCollection)
        .where("bookmarked", isEqualTo: true)
        .get();

    return Future.wait(query.docs.map((doc) async {
      final personalItemModel = PersonalFeedItemModel.fromFirebaseDoc(doc);

      final itemDoc = await firestore
          .collection(feedItemsCollection)
          .doc(personalItemModel.feedItemId)
          // .doc(doc.id)
          .get();

      // TODO: this gets thrown for some reason...
      if (!itemDoc.exists) throw Exception("item doesn't exist...");

      final commonModel = FeedItemRepoModel.fromFirebaseDoc(itemDoc);
      final detailsModel = FeedItemDetails(
          feedItemId: personalItemModel.feedItemId,
          liked: personalItemModel.liked,
          bookmarked: personalItemModel.bookmarked);

      return (detailsModel, commonModel);
    }));
  }

  @override
  Future<FeedSourceDetails?> getFeedSourceDetails(
      String userId, FeedSourceRepoModel source) async {
    final doc = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .doc(source.id)
        .get();
    if (!doc.exists) return null;
    final model = PersonalFeedSourceModel.fromFirebaseDoc(doc);
    return FeedSourceDetails(
        feedSourceUrl: model.feedSourceUrl, enabled: model.enabled);
  }

  @override
  Future<FeedItemDetails?> getFeedItemDetails(
    String userId,
    FeedItemRepoModel repoModel,
  ) async {
    final doc = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedItemsCollection)
        .doc(repoModel.id)
        .get();
    if (!doc.exists) return null;

    final model = PersonalFeedItemModel.fromFirebaseDoc(doc);
    return FeedItemDetails(
        feedItemId: model.feedItemId,
        liked: model.liked,
        bookmarked: model.bookmarked);
  }

  // save a feed item in a global collection
  @override
  Future saveFeedItem(FeedItemRepoModel feedItem) async {
    log("repo save feed item");
    await firestore
        .collection(feedItemsCollection)
        .doc(feedItem.id)
        .set(feedItem.toFirestoreDoc());
  }

  @override
  Future saveFeedItemDetails(String userId, FeedItemDetails itemDetails) async {
    log("repo save feed item details");

    final itemDoc = PersonalFeedItemModel(
        feedItemId: itemDetails.feedItemId,
        liked: itemDetails.liked,
        bookmarked: itemDetails.bookmarked);

    await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedItemsCollection)
        .doc(itemDoc.feedItemId)
        .set(itemDoc.toFirestoreDoc());
  }

  @override
  Future deleteFeedItemDetails(
      String userId, FeedItemDetails itemDetails) async {
    // TODO: delete feed items if no one references them
    log("repo delete feed item");

    final itemModel = PersonalFeedItemModel(
        feedItemId: itemDetails.feedItemId,
        liked: itemDetails.liked,
        bookmarked: itemDetails.bookmarked);

    // only deletes from the user's items
    final userDoc = firestore.collection(usersCollection).doc(userId);

    await userDoc
        .collection(personalFeedItemsCollection)
        .doc(itemModel.feedItemId)
        .delete();
  }

  @override
  Future saveFeedSourceDetails(
      String userId, FeedSourceDetails feedSourceDetails) async {
    log("repo save feed source details");

    final personalFeedModel = PersonalFeedSourceModel(
        feedSourceUrl: feedSourceDetails.feedSourceUrl,
        enabled: feedSourceDetails.enabled);

    await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .doc(personalFeedModel.id)
        .set(personalFeedModel.toFirestoreDoc());
  }

  @override
  Future deleteFeedSourceDetails(
      String userId, FeedSourceDetails feedSourceDetails) async {
    log("repo delete feed source");

    final personalFeedModel = PersonalFeedSourceModel(
        feedSourceUrl: feedSourceDetails.feedSourceUrl,
        enabled: feedSourceDetails.enabled);

    await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .doc(personalFeedModel.id)
        .set(personalFeedModel.toFirestoreDoc());
  }
}
