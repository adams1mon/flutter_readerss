import 'dart:async';
import 'dart:developer';
import 'package:flutter_readrss/use_case/feeds.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

class FeedSourcesEvent {
  const FeedSourcesEvent({required this.feedSources});
  final List<FeedSource> feedSources;
}

class FeedItemsEvent {
  const FeedItemsEvent({required this.feedItems});
  final List<FeedItem> feedItems;
}

// TODO: persist some elements to the DB?

class _FeedItemsBloc {
  // internal state which gets published on every change
  final _feedItems = <FeedItem>[];

  // broadcast stream because we could have more listeners
  final _feedItemsController = StreamController<FeedItemsEvent>.broadcast();

  Stream<FeedItemsEvent> get itemsStream => _feedItemsController.stream;

  void add(FeedItem item) {
    _feedItems.add(item);
    _publish(_feedItems);
  }

  void addAll(List<FeedItem> items) {
    _feedItems.addAll(items);
    _feedItems.sort(_comparePubDates);
    log("adding feed items");
    _publish(_feedItems);
  }

  void deleteBySource(FeedSource source) {
    _feedItems.removeWhere((item) => item.feedSourceRssUrl == source.siteUrl);
    _publish(_feedItems);
  }

  void delete(FeedItem item) {
    _feedItems.remove(item);
    _publish(_feedItems);
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

  void _publish(List<FeedItem> items) {
    _feedItemsController.sink.add(FeedItemsEvent(feedItems: items));
  }

  dispose() {
    _feedItemsController.close();
  }
}

class FeedSourcesBloc {
  // internal state which gets published on every change
  final _feedSources = <FeedSource>[];

  // broadcast stream because we could have more listeners
  final _feedSourcesStreamController =
      StreamController<FeedSourcesEvent>.broadcast();

  Stream<FeedSourcesEvent> get sourcesStream =>
      _feedSourcesStreamController.stream;

  final _itemsBloc = _FeedItemsBloc();

  Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

  void add(FeedSource source) {
    if (!_feedSources.any((s) => s.equals(source))) {
      _feedSources.add(source);
      log("adding feed source ${source.title}");
      _itemsBloc.addAll(source.feedItems);
    }
    _publish(_feedSources);
  }

  void delete(FeedSource source) {
    _feedSources.removeWhere((s) => s.equals(source));
    _itemsBloc.deleteBySource(source);
    _publish(_feedSources);
  }

  void toggleEnabled(FeedSource source) {
    final i = _feedSources.indexWhere((s) => s.equals(source));
    if (i > -1) {
      final s = _feedSources[i];
      s.toggleEnabled();

      if (s.enabled) {
        _itemsBloc.addAll(s.feedItems);
      } else {
        _itemsBloc.deleteBySource(s);
      }

      _publish(_feedSources);
    }
  }

  void _publish(List<FeedSource> sources) {
    _feedSourcesStreamController.sink
        .add(FeedSourcesEvent(feedSources: sources));
  }

  dispose() {
    _feedSourcesStreamController.close();
  }
}

class BookmarksBloc {
  final _itemsBloc = _FeedItemsBloc();
  Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

  void toggleBookmarked(FeedItem item) {
    item.bookmarked = !item.bookmarked;
    if (item.bookmarked) {
      _itemsBloc.add(item);
    } else {
      _itemsBloc.delete(item);
    }
  }

  dispose() {
    _itemsBloc.dispose();
  }
}

// TODO: initialize these where they are disposable (InheritedWidget maybe ?)
// (does the global scope get collected correctly, or do we leak memory here??)
final mainFeedBloc = FeedSourcesBloc();
final personalFeedBloc = FeedSourcesBloc();
final bookmarksBloc = BookmarksBloc();

abstract class FeedSrcBloc {
  Stream<FeedSourcesEvent> getFeedSourcesStream();
}

class _FeedPresenterImpl implements FeedPresenter {
  // final _feedSources = <FeedSource>[];
  final _feedSources = <String, FeedSource>{};
  final _feedItems = <String, List<FeedItem>>{};

  final _sourcesController = StreamController<FeedSourcesEvent>.broadcast();
  Stream<FeedSourcesEvent> get sourcesStream => _sourcesController.stream;

  final _itemsController = StreamController<FeedItemsEvent>.broadcast();
  Stream<FeedItemsEvent> get itemsStream => _itemsController.stream;

  // final _itemsBloc = _FeedItemsBloc();
  // Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

  @override
  void addFeedSource(FeedSource source) {
    if (!_feedSources.containsKey(source.rssUrl)) {
      log("adding feed source ${source.title}");
      _feedSources[source.rssUrl] = source;
      _publishFeedSources(_feedSources);
    }

    if (!_feedItems.containsKey(source.rssUrl)) {
      log("adding feed items from source ${source.title}");
      _feedItems[source.rssUrl] = source.feedItems;
      _publishFeedItems(_feedItems);
    }
  }

  void _publishFeedItems(Map<String, List<FeedItem>> items) {
    _itemsController.sink.add(FeedItemsEvent(
        feedItems: items.values
            .expand((itemList) => itemList)
            .toList(growable: false)));
  }

  void _publishFeedSources(Map<String, FeedSource> sources) {
    _sourcesController.sink.add(
        FeedSourcesEvent(feedSources: sources.values.toList(growable: false)));
  }

  @override
  void removeFeedItemsBySource(FeedSource source) {
    if (_feedItems.remove(source.rssUrl) != null) {
      _publishFeedItems(_feedItems);
    }
  }

  @override
  void updateFeedItem(FeedItem feedItem) {
    if (!_feedItems.containsKey(feedItem.feedSourceRssUrl)) {
      return;
    }

    final items = _feedItems[feedItem.feedSourceRssUrl];
    final index = items
        ?.indexWhere((element) => element.articleUrl == feedItem.articleUrl);

    if (index == -1) {
      return;
    }
    items?[index!] = feedItem;
    _publishFeedItems(_feedItems);
  }

  // void toggleEnabled(FeedSource source) {
  //   final i = _feedSources.indexWhere((s) => s.equals(source));
  //   if (i > -1) {
  //     final s = _feedSources[i];
  //     s.toggleEnabled();

  //     if (s.enabled) {
  //       _itemsBloc.addAll(s.feedItems);
  //     } else {
  //       _itemsBloc.deleteBySource(s);
  //     }

  //     _publish(_feedSources);
  //   }
  // }

  // void _publish(List<FeedSource> sources) {
  //   _feedSourcesStreamController.sink
  //       .add(FeedSourcesEvent(feedSources: sources));
  // }

  dispose() {
    _sourcesController.close();
    _itemsController.close();
  }
}

// class BookmarksBloc {
//   final _itemsBloc = _FeedItemsBloc();
//   Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

//   void toggleBookmarked(FeedItem item) {
//     item.bookmarked = !item.bookmarked;
//     if (item.bookmarked) {
//       _itemsBloc.add(item);
//     } else {
//       _itemsBloc.delete(item);
//     }
//   }

//   dispose() {
//     _itemsBloc.dispose();
//   }
// }
