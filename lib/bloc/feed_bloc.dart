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

class FeedBloc {
  // internal state which gets published on every change
  final _feedSources = <FeedSource>[];

  // broadcast stream because the items stream consumers indirectly listen to it
  final _feedSourcesStreamController =
      StreamController<FeedSourcesEvent>.broadcast();

  Stream<FeedSourcesEvent> get sourcesStream =>
      _feedSourcesStreamController.stream;
  Stream<FeedItemsEvent> get itemsStream =>
      _flatMapFeedSourcesToFeedItems(_feedSourcesStreamController.stream);
  Stream<FeedItemsEvent> get bookmarkedItemsStream =>
      _filterBookmarkedFeedItems(itemsStream);

  Stream<FeedItemsEvent> _flatMapFeedSourcesToFeedItems(
      Stream<FeedSourcesEvent> sourceStream) {
    return sourceStream
        .expand(
          (sourcesEvent) =>
              //     sourcesEvent.event.map((source) => source.feedItems))
              // .map((feedItems) => FeedItemsEvent(feedItems));
              sourcesEvent.feedSources.map((source) => source.feedItems),
        )
        .map(
          (feedItems) => FeedItemsEvent(feedItems: feedItems),
        );
  }

  Stream<FeedItemsEvent> _filterBookmarkedFeedItems(
      Stream<FeedItemsEvent> itemsStream) {
    return itemsStream.map(
      (event) => FeedItemsEvent(
        feedItems: event.feedItems
            .where(
              (item) => item.bookmarked,
            )
            .toList(),
      ),
    );
  }

  void add(FeedSource source) {
    if (!_feedSources.any((s) => s.equals(source))) {
      _feedSources.add(source);
    }
    _publish(_feedSources);
  }

  void delete(FeedSource source) {
    _feedSources.removeWhere((s) => s.equals(source));
    _publish(_feedSources);
  }

  void toggleEnabled(FeedSource source) {
    final i = _feedSources.indexWhere((s) => s.equals(source));
    if (i > -1) {
      _feedSources[i].toggleEnabled();
      _publish(_feedSources);
    }
  }

  void _publish(List<FeedSource> sources) {
    // _feedSourcesStreamController.sink.add(FeedSourcesEvent(sources));
    _feedSourcesStreamController.sink
        .add(FeedSourcesEvent(feedSources: sources));
  }

  // TODO: where do we call this ?
  dispose() {
    _feedSourcesStreamController.close();
  }
}

class FeedItemsBloc {
  // internal state which gets published on every change
  final _feedItems = <FeedItem>[];

  // broadcast stream because the items stream consumers indirectly listen to it
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

  // broadcast stream because the items stream consumers indirectly listen to it
  final _feedSourcesStreamController =
      StreamController<FeedSourcesEvent>.broadcast();

  Stream<FeedSourcesEvent> get sourcesStream =>
      _feedSourcesStreamController.stream;

  final _itemsBloc = FeedItemsBloc();

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

  final _itemsBloc = FeedItemsBloc();
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


Stream<T> mergeStreams<T>(List<Stream<T>> streams) {
  late final StreamController<T> controller;
  final subs = <StreamSubscription<T>>[];

  void listen() {
    for (final stream in streams) {
      subs.add(
        stream.listen(
          (event) {
            controller.sink.add(event);
          },
        ),
      );
    }
  }

  void cancel() {
    for (final sub in subs) {
      sub.cancel();
    }
  }

  void pause() {
    for (final sub in subs) {
      sub.pause();
    }
  }

  void resume() {
    for (final sub in subs) {
      sub.resume();
    }
  }

  controller = StreamController(
      onListen: listen, onCancel: cancel, onPause: pause, onResume: resume);

  return controller.stream;
}


// final mainFeedBloc = FeedItemsBloc();
// final personalFeedBloc = FeedItemsBloc();
// final bookmarkFeedBloc = FeedItemsBloc();

// final mainFeedBloc = FeedBloc();
// final personalFeedBloc = FeedBloc();

final mainFeedBloc = FeedSourcesBloc();
final personalFeedBloc = FeedSourcesBloc();
final bookmarksBloc = BookmarksBloc();