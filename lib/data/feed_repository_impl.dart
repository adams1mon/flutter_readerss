import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_readrss/data/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/feed_repository.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:crypto/crypto.dart';

class FeedItemModel {
  final String id;
  final String feedSourceTitle;
  final String feedSourceRssUrl; // this is like a foreign key
  final String title;
  final String? description;
  final String articleUrl;

  // TODO: this image URL should be cached on client side instead of storing it redundandtly, Flutter also caches Image objects
  final String? sourceIconUrl;
  final DateTime? pubDate;
  final int views;
  final int likes;

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
  }) : id = _generateId(articleUrl);

  static String _generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }
}

class FeedSourceModel {
  final String id;
  final String title;
  final String rssUrl;
  final String siteUrl;
  final String? iconUrl;
  final int ttl;

  FeedSourceModel({
    required this.title,
    required this.rssUrl,
    required this.siteUrl,
    required this.iconUrl,
    required this.ttl,
  }) : id = _generateId(rssUrl);
  
  static String _generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }
}

const feedSourcesCollection = "feedSources";
const feedItemsCollection = "feedItems";
const usersCollection = "users";
const likedItemsCollection = "likedFeedItems";
const bookmarkedItemsCollection = "bookmarkedFeedItems";

class FeedItemMapper {
  static Map<String, dynamic> toFirestoreDoc(FeedItem feedItem) {
    return {
      "feedSourceTitle": feedItem.feedSourceTitle,
      "feedSourceRssUrl": feedItem.feedSourceRssUrl,
      "title": feedItem.title,
      "description": feedItem.description,
      "articleUrl": feedItem.articleUrl,
      // TODO: fix this
      "sourceIconUrl": null,
      "pubDate": feedItem.pubDate,
      "views": feedItem.views,
      "likes": feedItem.likes,
    };
  }
}

class FeedRepositoryImpl implements FeedRepository {
  final firestore = FirebaseFirestore.instance;

  // String _generateIdFromUrl(String url) {
  //   final identity = utf8.encode(url);
  //   return sha256.convert(identity).toString();
  // }

  // String _generateFeedItemModelId(FeedItemModel model) {
  //   final identity = utf8.encode(model.articleUrl);
  //   return sha256.convert(identity).toString();
  // }

  // String _generateFeedItemId(String articleUrl) {
  //   final identity = utf8.encode(articleUrl);
  //   return sha256.convert(identity).toString();
  // }

  // String _generateFeedSourceId(String sourceRssUrl) {
  //   final identity = utf8.encode(sourceRssUrl);
  //   return sha256.convert(identity).toString();
  // }

  // TODO: remove feedType
  @override
  Future<(FeedSource, List<FeedItem>)> getFeedByUrl(
      String url, FeedType feedType) async {
    // TODO: error handling

    // 1. fetch source and items as models

    // 2. combine necessary stuff to make business objects, fetch likes and views, etc. for the current user

    // 3. return

    final (feedSourceModel, feedItemModels) = await RssFetcher.fetch(url);

    final feedSource = FeedSource(
      id: feedSourceModel.id,
      title: feedSourceModel.title,
      rssUrl: feedSourceModel.rssUrl,
      type: feedType,
      siteUrl: feedSourceModel.siteUrl,
      ttl: feedSourceModel.ttl,
    );

    final feedItems = await Future.wait(
      feedItemModels.map((item) async {
        final doc =
            await firestore.collection(feedItemsCollection).doc(item.id).get();

        var views = doc.data()?["views"] ?? 0;
        var likes = doc.data()?["likes"] ?? 0;

        // TODO: bookmarked & liked ?
        // bookmarked?
        // liked?

        return FeedItem(
          id: item.id,
          feedSourceTitle: item.feedSourceTitle,
          feedSourceRssUrl: item.feedSourceRssUrl,
          articleUrl: item.articleUrl,
          title: item.title,
          description: item.description,
          pubDate: item.pubDate,
          views: views,
          likes: likes,
          liked: false,
          bookmarked: false,
        );
      }),
    );

    return (feedSource, feedItems);
  }

  @override
  Future saveFeedItem(FeedItem item, String userId) async {
    // TODO: implement saveFeedItem
    log("repo save feed item");

    final itemDoc = FeedItemMapper.toFirestoreDoc(item);
    await firestore.collection(feedItemsCollection).doc(item.id).set(itemDoc);
    
    if (item.liked) {
      await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(likedItemsCollection)
        .doc(item.id)
        .set({});
    }

    if (item.bookmarked) {
      await firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(bookmarkedItemsCollection)
        .doc(item.id)
        .set({});
    }

    return Future.value();
  }

  @override
  Future saveFeedSource(FeedSource source, String userId) {
    // TODO: implement saveFeedSource
    log("repo save feed stub");
    return Future.value();
  }

  @override
  Future deleteFeedItem(FeedItem item, String userId) {
    // TODO: implement deleteFeedItem
    log("repo delete item stub");

    return Future.value();
  }

  @override
  Future deleteFeedSource(FeedSource source, String userId) {
    // TODO: implement deleteFeedSource
    log("repo delete source stub");
    return Future.value();
  }
}
