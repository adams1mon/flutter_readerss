
import 'dart:convert';

import 'package:crypto/crypto.dart';

class FeedSourceRepoModel {
  final String id;
  final String title;
  final String rssUrl;
  final String? siteUrl;
  final String? iconUrl;
  final int ttl;

  FeedSourceRepoModel({
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
}