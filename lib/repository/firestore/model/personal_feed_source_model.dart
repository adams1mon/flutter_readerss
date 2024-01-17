
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

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

  Map<String, dynamic> toFirestoreDoc() {
    return <String, dynamic>{
      "feedSourceUrl": feedSourceUrl,
      "enabled": enabled,
    };
  }
}