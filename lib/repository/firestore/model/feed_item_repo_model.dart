
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class FeedItemRepoModel {
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

  // TODO: this calculates the id every time...
  FeedItemRepoModel({
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

  static String generateId(String url) {
    final identity = utf8.encode(url);
    return sha256.convert(identity).toString();
  }

  factory FeedItemRepoModel.fromFirebaseDoc(
    DocumentSnapshot<Map<String, dynamic>> firebaseDoc,
  ) {
    return FeedItemRepoModel(
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