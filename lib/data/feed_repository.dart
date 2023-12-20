import 'dart:developer';

import 'package:flutter_readrss/data/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/feed_repository.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  @override
  Future deleteFeedItem(FeedItem item) {
    // TODO: implement deleteFeedItem
    log("repo delete item stub");
    return Future.value();
  }

  @override
  Future deleteFeedSource(FeedSource source) {
    // TODO: implement deleteFeedSource
    log("repo delete source stub");
    return Future.value();
  }

  @override
  Future<(FeedSource, List<FeedItem>)> getFeedByUrl(String url, FeedType feedType) {
    // TODO: error handling
    return RssFetcher.fetch(url, feedType);
  }

  @override
  Future saveFeedItem(FeedItem item) {
    // TODO: implement saveFeedItem
    log("repo save item stub");
    return Future.value();
  }

  @override
  Future saveFeedSource(FeedSource source) {
    // TODO: implement saveFeedSource
    log("repo save feed stub");
    return Future.value();
  }
}
