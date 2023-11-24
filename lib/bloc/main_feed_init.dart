import 'dart:developer';

import 'package:flutter_readrss/bloc/feed_bloc.dart';
import 'package:flutter_readrss/const/main_rss_feeds.dart';
import 'package:flutter_readrss/data/rss_fetcher.dart';

void initMainFeed() async {
  for (final url in mainFeedRssUrls) {
    try {
      final feedSource = await RssFetcher.fetch(url);
      mainFeedBloc.add(feedSource);
    } on RssFetchException catch (e) {
      log(
        "error while populating default main feed with rss from url: $url",
        error: e,
      );
    } catch (e) {
      log(
        "unknown error while populating main feed with rss from url: $url",
        error: e,
      );
    }
  }
}
