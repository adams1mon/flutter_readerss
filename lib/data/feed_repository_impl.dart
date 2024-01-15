import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_readrss/data/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/feed_repository.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:crypto/crypto.dart';

// TODO: separate models fetched from the network and the ones saved in Firestore

class FeedItemModel {
  final String id;
  final String feedSourceTitle;
  final String feedSourceRssUrl; 
  final String title;
  final String? description;
  final String articleUrl;
  final String? sourceIconUrl;
  final DateTime? pubDate;
  int views;
  int likes;

  FeedItemModel({
    required this.feedSourceTitle,
    required this.feedSourceRssUrl,
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.sourceIconUrl,
    required this.pubDate,
    required this.views,
    required this.likes,
  }) : id = generateId(articleUrl);

  factory FeedItemModel.fromFeedItem(FeedItem item) {
    // TODO: this calculates the id again...
    return FeedItemModel(
      feedSourceTitle: item.feedSourceTitle,
      feedSourceRssUrl: item.feedSourceRssUrl,
      title: item.title,
      description: item.description,
      articleUrl: item.articleUrl,
      sourceIconUrl: item.sourceIconUrl,
      pubDate: item.pubDate,
      views: item.views,
      likes: item.likes,
    );
  }

  FeedItem toFeedItem(bool feedItemLiked, bool feedItemBookmarked) {
    return FeedItem(
      id: id,
      feedSourceTitle: feedSourceTitle,
      feedSourceRssUrl: feedSourceRssUrl,
      articleUrl: articleUrl,
      title: title,
      description: description,
      pubDate: pubDate,
      sourceIconUrl: sourceIconUrl,
      views: views,
      likes: likes,
      liked: feedItemLiked,
      bookmarked: feedItemBookmarked,
    );
  }

  static String generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }

  factory FeedItemModel.fromFirebaseDoc(
    DocumentSnapshot<Map<String, dynamic>> firebaseDoc,
  ) {
    // TODO: this calculates the id again...
    return FeedItemModel(
      feedSourceTitle: firebaseDoc.get("feedSourceTitle"),
      feedSourceRssUrl: firebaseDoc.get("feedSourceRssUrl"),
      title: firebaseDoc.get("title"),
      description: firebaseDoc.get("description"),
      articleUrl: firebaseDoc.get("articleUrl"),
      sourceIconUrl: firebaseDoc.get("sourceIconUrl"),
      pubDate: (firebaseDoc.get("pubDate") as Timestamp?)?.toDate(),
      views: firebaseDoc.get("views"),
      likes: firebaseDoc.get("likes"),
    );
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      "feedSourceTitle": feedSourceTitle,
      "feedSourceRssUrl": feedSourceRssUrl,
      "title": title,
      "description": description,
      "articleUrl": articleUrl,
      "sourceIconUrl": sourceIconUrl,
      "pubDate": pubDate,
      "views": views,
      "likes": likes,
    };
  }
}

// this is not stored in firebase, only returned by the rss fetcher (network 'model')
class FeedSourceModel {
  final String id;
  final String title;
  final String rssUrl;
  final String? siteUrl;
  final String? iconUrl;
  final int ttl;

  FeedSourceModel({
    required this.title,
    required this.rssUrl,
    required this.siteUrl,
    required this.iconUrl,
    required this.ttl,
  }) : id = generateId(rssUrl);

  static String generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }

  FeedSource toFeedSource(FeedType feedType, bool enabled) {
    return FeedSource(
      id: id,
      title: title,
      rssUrl: rssUrl,
      type: feedType,
      siteUrl: siteUrl,
      ttl: ttl,
      iconUrl: iconUrl,
      enabled: enabled,
    );
  }
}

class PersonalFeedSourceModel {
  final String id;
  final String feedSourceUrl;
  final bool enabled;

  PersonalFeedSourceModel({
    required this.feedSourceUrl,
    required this.enabled,
  }) : id = generateId(feedSourceUrl);

  static String generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }

  factory PersonalFeedSourceModel.fromFirebaseDoc(
    DocumentSnapshot<Map<String, dynamic>> firebaseDoc,
  ) {
    return PersonalFeedSourceModel(
      feedSourceUrl: firebaseDoc.get("feedSourceUrl"),
      enabled: firebaseDoc.get("enabled"),
    );
  }

  factory PersonalFeedSourceModel.fromFeedSource(FeedSource source) {
    return PersonalFeedSourceModel(
      feedSourceUrl: source.id,
      enabled: source.enabled,
    );
  }

  Map<String, dynamic> toFirestoreDoc() {
    return <String, dynamic>{
      "feedSourceId": feedSourceUrl,
      "enabled": enabled,
    };
  }
}

const feedSourcesCollection = "feedSources";
const feedItemsCollection = "feedItems";
const usersCollection = "users";
const likedItemsCollection = "likedFeedItems";
const bookmarkedItemsCollection = "bookmarkedFeedItems";
const personalFeedsCollection = "personalFeedSourceSettings";

class FeedRepositoryImpl implements FeedRepository {
  final firestore = FirebaseFirestore.instance;

  // TODO: remove feedType
  @override
  Future<(FeedSource, List<FeedItem>)> getFeedByUrl(
      String url, FeedType feedType, String? userId) async {
    log("getting feed by url $url");

    // TODO: error handling

    // 1. fetch source and items as models
    final (feedSourceModel, feedItemModels) = await RssFetcher.fetch(url);

    // 2. combine necessary stuff to make business objects, fetch likes and views, etc. for the current user
    var sourceEnabled = true;

    if (feedType == FeedType.personal && userId != null) {
      // is this source saved for the user?
      final personalFeedSource = await firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(personalFeedsCollection)
          .doc(PersonalFeedSourceModel.generateId(url))
          .get();

      if (personalFeedSource.exists) {
        sourceEnabled =
            PersonalFeedSourceModel.fromFirebaseDoc(personalFeedSource).enabled;
      }
    }

    final feedSource = feedSourceModel.toFeedSource(feedType, sourceEnabled);

    final feedItems = await Future.wait(
      feedItemModels.map((item) async {
        // update views & likes if it's stored
        final doc =
            await firestore.collection(feedItemsCollection).doc(item.id).get();

        var views = 0;
        var likes = 0;
        if (doc.data() != null) {
          final itemModel = FeedItemModel.fromFirebaseDoc(doc);
          views = itemModel.views;
          likes = itemModel.likes;
        }
        item.views = views;
        item.likes = likes;

        // bookmarked & liked ?
        var bookmarked = false;
        var liked = false;

        if (userId != null) {
          final userDoc = firestore.collection(usersCollection).doc(userId);
          bookmarked = (await userDoc
                  .collection(bookmarkedItemsCollection)
                  .doc(item.id)
                  .get())
              .exists;

          liked = (await userDoc
                  .collection(likedItemsCollection)
                  .doc(item.id)
                  .get())
              .exists;
          
          log("bookmarked = $bookmarked;  liked = $liked;  url = ${item.articleUrl}");
        }

        return item.toFeedItem(liked, bookmarked);
      }),
    );

    return (feedSource, feedItems);
  }

  @override
  Future<List<(FeedSource, List<FeedItem>)>> getPersonalFeeds(
      String userId) async {
    // get personal feeds
    final feedCollection = await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .get();

    final feedSourcesAndItems = <(FeedSource, List<FeedItem>)>[];

    for (final doc in feedCollection.docs) {
      final personalFeed = PersonalFeedSourceModel.fromFirebaseDoc(doc);

      // fetch every feed by url
      feedSourcesAndItems.add(
        await getFeedByUrl(
          personalFeed.feedSourceUrl,
          FeedType.personal,
          userId,
        ),
      );
    }
    return feedSourcesAndItems;
  }

  @override
  Future saveFeedItem(FeedItem item, String? userId) async {
    // TODO: implement saveFeedItem
    log("repo save feed item");

    final itemModel = FeedItemModel.fromFeedItem(item);
    await firestore
        .collection(feedItemsCollection)
        .doc(itemModel.id)
        .set(itemModel.toFirestoreDoc());

    if (userId == null) return;

    if (item.liked) {
      await firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(likedItemsCollection)
          .doc(item.id)
          .set({});
    } else {
      await firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(likedItemsCollection)
          .doc(item.id)
          .delete();
    }

    if (item.bookmarked) {
      await firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(bookmarkedItemsCollection)
          .doc(item.id)
          .set({});
    } else {
      await firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(bookmarkedItemsCollection)
          .doc(item.id)
          .delete();
    }
  }

  @override
  Future saveFeedSource(FeedSource source, String userId) async {
    log("repo save feed source");

    final personalFeedModel = PersonalFeedSourceModel.fromFeedSource(source);
    await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(personalFeedsCollection)
        .doc(personalFeedModel.id)
        .set(personalFeedModel.toFirestoreDoc());
  }

  @override
  Future deleteFeedItem(FeedItem item, String userId) async {
    // TODO: delete feed items if no one references them
    log("repo delete feed item");

    final itemModel = FeedItemModel.fromFeedItem(item);

    // only deletes from the user's items
    final userDoc = firestore.collection(usersCollection).doc(userId);

    await userDoc.collection(likedItemsCollection).doc(itemModel.id).delete();

    await userDoc
        .collection(bookmarkedItemsCollection)
        .doc(itemModel.id)
        .delete();
  }

  @override
  Future deleteFeedSource(FeedSource source, String userId) async {
    // TODO: delete feed sources if no one references them
    log("repo delete feed source");

    final personalFeedModel = PersonalFeedSourceModel.fromFeedSource(source);

    // only deletes from the user's feed settings, not the global feed source
    final userDoc = firestore.collection(usersCollection).doc(userId);

    await userDoc
        .collection(personalFeedsCollection)
        .doc(personalFeedModel.feedSourceUrl)
        .delete();
  }
}

// TODO:
// I. loading predefined feeds flow

// 1. fetch feed model + items from the network
// 2. fetch views + likes for all items from firebase (public collection, no auth required here)
// 3. if user is logged in, check if any items are saved for the user
// 4. present items of the feed


// II. loading personal feeds flow

// 1. fetch feed model + items from the network
// 2. fetch views + likes for all items from firebase (public collection, no auth required)
// 3. [user should be logged in] fetch liked + bookmarked status for all items from firebase
// 4. [user should be logged in] fetch enabled status for feed sources from firebase
// 5. present personal feed and its items
