import 'dart:async';

import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/model/feed_source.dart';

class FeedItemsEvent {
  const FeedItemsEvent({
    required this.feedItems,
  });

  final List<FeedItem> feedItems;
}

class FeedItemsBloc {
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
