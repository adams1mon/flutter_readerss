
import 'dart:async';
import 'dart:developer';

import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/presenter/feed_provider.dart';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';

class BookmarkFeedItemsConnector implements FeedItemsSink, FeedItemsProvider {
  final _bookmarkedItems = <String, FeedItem>{};

  final _controller = StreamController<FeedItemsEvent>.broadcast();

  @override
  Stream<FeedItemsEvent> getFeedItemsStream() => _controller.stream; 
  
  @override
  void dispose() {
    _controller.close();
  }
  
  @override
  void setFeedItems(List<FeedItem> feedItems) {
    for (final item in feedItems) {
      log("BookmarkFeedItemsConnector: setting item ${item.articleUrl}");
      _bookmarkedItems[item.articleUrl] = item;
    }
    _publishFeedItems(_bookmarkedItems);
  }

  @override
  void removeFeedItemsForSource(String rssUrl) {
    log("BookmarkFeedItemsConnector: removing items for $rssUrl");
    _bookmarkedItems.remove(rssUrl);
  }
  
  @override
  void updateFeedItem(FeedItem feedItem) {
    log("BookmarkFeedItemsConnector: updating feed item ${feedItem.articleUrl}");
    _bookmarkedItems[feedItem.articleUrl] = feedItem;
    if (!feedItem.bookmarked) {
      _bookmarkedItems.remove(feedItem.articleUrl);
    } else {
      _bookmarkedItems[feedItem.articleUrl] = feedItem;
    }
    _publishFeedItems(_bookmarkedItems);
  }

  void _publishFeedItems(Map<String, FeedItem> items) {
    _controller.sink
        .add(FeedItemsEvent(feedItems: items.values.toList(growable: false)));
  }
}