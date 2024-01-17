
import 'dart:async';
import 'dart:developer';

import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/presenter/feed_provider.dart';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';

// subscribes to a given list of feed providers 

class BookmarkFeedItemsConnector implements FeedItemsSink, FeedItemsProvider {
  final _bookmarkedItems = <String, FeedItem>{};

  final _controller = StreamController<FeedItemsEvent>.broadcast();

  // void _updateBookmarkedItems(List<FeedItem> items) {
  //   for (final item in items) {
  //     final alreadyPresent = _bookmarkedItems.containsKey(item.articleUrl);
  //     if (item.bookmarked && !alreadyPresent) {
  //       _bookmarkedItems[item.articleUrl] = item;
  //       log("update bookmark items with ${item.articleUrl}");
  //     } else if (!item.bookmarked && alreadyPresent) {
  //       log("removing bookmarked item ${item.articleUrl}");
  //       _bookmarkedItems.remove(item.articleUrl);
  //     }
  //   }
  // }
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

// class BookmarkFeedProviderImpl implements FeedProvider {
//   final _bookmarkedItems = <String, FeedItem>{};

//   final List<FeedProvider> feedProviders;
//   final _controller = StreamController<FeedItemsEvent>.broadcast();

//   BookmarkFeedProviderImpl({required this.feedProviders}) {
//     for (final p in feedProviders) {
//       // whenever a provider's stream gets an event, update the bookmarked items and publish
//       p.getFeedItemsStream().listen((itemsEvent) {
//         _updateBookmarkedItems(itemsEvent.feedItems);
//         log("updating bookmarked items: ${_bookmarkedItems.toString()}");
//         _publishFeedItems(_bookmarkedItems);
//       });
//     }
//   }

//   void _updateBookmarkedItems(List<FeedItem> items) {
//     for (final item in items) {
//       final alreadyPresent = _bookmarkedItems.containsKey(item.articleUrl);
//       if (item.bookmarked && !alreadyPresent) {
//         _bookmarkedItems[item.articleUrl] = item;
//         log("update bookmark items with ${item.articleUrl}");
//       } else if (!item.bookmarked && alreadyPresent) {
//         log("removing bookmarked item ${item.articleUrl}");
//         _bookmarkedItems.remove(item.articleUrl);
//       }
//     }
//   }

//   void _publishFeedItems(Map<String, FeedItem> items) {
//     _controller.sink
//         .add(FeedItemsEvent(feedItems: items.values.toList(growable: false)));
//   }

//   @override
//   Stream<FeedSourcesEvent> getFeedSourcesStream() {
//     return const Stream.empty();
//   }

//   @override
//   Stream<FeedItemsEvent> getFeedItemsStream() {
//     return _controller.stream;
//   }

//   @override
//   void dispose() {
//     _controller.close();
//   }
// }