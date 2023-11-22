import 'dart:async';

import 'package:flutter_readrss/model/feed_source.dart';
import 'package:flutter_readrss/bloc/feed_items_bloc.dart';

class FeedSourcesEvent {
  const FeedSourcesEvent({
    required this.feedSources,
  });

  final List<FeedSource> feedSources;
}

class FeedSourcesBloc {
  // internal state which gets published on every change
  final _feedSources = <FeedSource>[];

  // broadcast stream because we could have more listeners
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
