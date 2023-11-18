import 'dart:async';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/model/feed_source.dart';

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
    _publish(_feedItems);
  }

  void deleteBySource(FeedSource source) {
    _feedItems.removeWhere((item) => item.feedSourceLink == source.link);
    _publish(_feedItems);
  }

  void delete(FeedItem item) {
    _feedItems.remove(item);
    _publish(_feedItems);
  }

  void _publish(List<FeedItem> items) {
    _feedItemsController.sink.add(FeedItemsEvent(feedItems: items));
  }

  // TODO: where do we call this ?
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

  // TODO: where do we call this ?
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

  // TODO: where do we call this ?
  dispose() {
    _itemsBloc.dispose();
  }
}

// TODO: initialize these where they are disposable (InheritedWidget maybe ?)
// (does the global scope get collected correctly, or do we leak memory here??)
final mainFeedBloc = FeedSourcesBloc();
final personalFeedBloc = FeedSourcesBloc();
final bookmarksBloc = BookmarksBloc();