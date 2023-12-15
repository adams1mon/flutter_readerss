import 'dart:developer';

import 'package:flutter_readrss/data/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/feeds.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:flutter_readrss/use_case/model/feed_source_type.dart';

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
  Future<FeedSource> getFeedSourceByUrl(
    String url,
    FeedSourceType feedSourceType,
  ) {
    // TODO: implement getFeedSourceByUrl
    log("repo get source by url stub");
    return RssFetcher.fetch(url, feedSourceType);
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
