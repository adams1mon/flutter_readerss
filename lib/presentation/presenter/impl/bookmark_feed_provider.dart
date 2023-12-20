
import 'dart:async';
import 'dart:developer';

import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/presenter/feed_provider.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';

// subscribes to a given list of feed providers 

class BookmarkFeedProviderImpl implements FeedProvider {
  final _bookmarkedItems = <String, FeedItem>{};

  final List<FeedProvider> feedProviders;
  final _controller = StreamController<FeedItemsEvent>.broadcast();

  BookmarkFeedProviderImpl({required this.feedProviders}) {
    for (final p in feedProviders) {
      // whenever a provider's stream gets an event, update the bookmarked items and publish
      p.getFeedItemsStream().listen((itemsEvent) {
        _updateBookmarkedItems(itemsEvent.feedItems);
        log("updating bookmarked items: ${_bookmarkedItems.toString()}");
        _publishFeedItems(_bookmarkedItems);
      });
    }
  }

  void _updateBookmarkedItems(List<FeedItem> items) {
    for (final item in items) {
      final alreadyPresent = _bookmarkedItems.containsKey(item.articleUrl);
      if (item.bookmarked && !alreadyPresent) {
        _bookmarkedItems[item.articleUrl] = item;
        log("update bookmark items with ${item.articleUrl}");
      } else if (!item.bookmarked && alreadyPresent) {
        log("removing bookmarked item ${item.articleUrl}");
        _bookmarkedItems.remove(item.articleUrl);
      }
    }
  }

  void _publishFeedItems(Map<String, FeedItem> items) {
    _controller.sink
        .add(FeedItemsEvent(feedItems: items.values.toList(growable: false)));
  }

  @override
  Stream<FeedSourcesEvent> getFeedSourcesStream() {
    return const Stream.empty();
  }

  @override
  Stream<FeedItemsEvent> getFeedItemsStream() {
    return _controller.stream;
  }

  @override
  void dispose() {
    _controller.close();
  }
}