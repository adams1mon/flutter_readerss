
import 'dart:async';
import 'dart:developer';

import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/presenter/feed_provider.dart';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

// presenter uses it to push feeds into it,
// ui components subscribe to the provided feeds

class FeedConnector implements FeedProvider, FeedSink {
  final _feedSources = <String, FeedSource>{};
  final _feedItems = <String, Map<String, FeedItem>>{};

  final _sourcesController = StreamController<FeedSourcesEvent>.broadcast();
  final _itemsController = StreamController<FeedItemsEvent>.broadcast();

  @override
  Stream<FeedSourcesEvent> getFeedSourcesStream() {
    return _sourcesController.stream;
  }

  @override
  Stream<FeedItemsEvent> getFeedItemsStream() {
    return _itemsController.stream;
  }

  @override
  void dispose() {
    _sourcesController.close();
    _itemsController.close();
  }

  @override
  void setFeedSource(FeedSource source) {
    log("FeedProvider: adding feed source ${source.title}");
    _feedSources[source.rssUrl] = source;
    _publishFeedSources(_feedSources);
  }
  
  @override
  void removeFeedSource(FeedSource source) {
    log("FeedProvider: removing feed source ${source.title}");
    _feedSources.remove(source.rssUrl);
    _publishFeedSources(_feedSources);
  }

  @override
  void setFeedItems(String rssUrl, List<FeedItem> feedItems) {
    if (feedItems.isEmpty) {
      log("FeedProvider: adding EMPTY items for source $rssUrl");
      _feedItems.remove(rssUrl);
    } else {
      log("FeedProvider: adding items for source $rssUrl");
      _feedItems[rssUrl] = Map.fromEntries(
        feedItems.map(
          (e) => MapEntry<String, FeedItem>(e.articleUrl, e),
        ),
      );
    }
    _publishFeedItems(_feedItems);
  }

  @override
  void updateFeedItem(FeedItem feedItem) {
    final itemsMap = _feedItems[feedItem.feedSourceRssUrl];
    if (itemsMap == null) {
      return;
    }

    if (!itemsMap.containsKey(feedItem.articleUrl)) {
      return;
    }

    log("FeedProvider: updating feed item ${feedItem.articleUrl}");
    _feedItems[feedItem.feedSourceRssUrl]![feedItem.articleUrl] = feedItem;
    _publishFeedItems(_feedItems);
  }

  void _publishFeedSources(Map<String, FeedSource> sources) {
    _sourcesController.sink.add(
        FeedSourcesEvent(feedSources: sources.values.toList(growable: false)));
  }

  void _publishFeedItems(Map<String, Map<String, FeedItem>> items) {
    _itemsController.sink.add(FeedItemsEvent(
        feedItems: items.values
            .expand((mapEntry) => mapEntry.values)
            .toList(growable: false)
            ..sort(((a, b) => _comparePubDates(a, b)))));
  }

  int _comparePubDates(FeedItem a, FeedItem b) {
    if (a.pubDate == null) {
      // put 'a' to the end of the list
      return 1;
    } else if (b.pubDate == null) {
      // put 'b' to the end of the list
      return -1;
    } else {
      // descending order
      return -a.pubDate!.compareTo(b.pubDate!);
    }
  }
}