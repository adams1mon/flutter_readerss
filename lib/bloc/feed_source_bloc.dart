import 'dart:async';

import 'package:flutter_readrss/model/feed_source.dart';
import 'package:flutter_readrss/bloc/feed_items_bloc.dart';
import 'package:flutter_readrss/data/rss_fetcher.dart';

class FeedSourceEvent {
  const FeedSourceEvent({
    required this.feedSource,
  });

  final FeedSource feedSource;
}

class FeedSourceBloc {
  FeedSourceBloc({
    required String rssUrl,
  }) {
    getNewData(rssUrl);
  }

  // internal state which gets published on every change
  FeedSource? _feedSource;

  // broadcast stream because we could have more listeners
  final _feedSourceStreamController =
  StreamController<FeedSourceEvent>.broadcast();

  Stream<FeedSourceEvent> get sourcesStream =>
      _feedSourceStreamController.stream;

  final _itemsBloc = FeedItemsBloc();

  Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

  void getNewData(String rssUrl) async {
    bool enabled = _feedSource?.enabled ?? false;

    if (!enabled) {
      return;
    }

    var newFeedSource = await parseRss(rssUrl);
    newFeedSource.enabled = enabled;

    _feedSource = newFeedSource;
    _publish(newFeedSource);
    Future.delayed(Duration(minutes: newFeedSource.ttl), () {
      getNewData(rssUrl);
    });
  }

  void toggleEnabled(FeedSource source) {
    source.toggleEnabled();

    if (source.enabled) {
      _itemsBloc.addAll(source.feedItems);

    } else {
      _itemsBloc.deleteBySource(source);
    }

    _publish(source);
  }

  void _publish(FeedSource source) {
    _feedSourceStreamController.sink.add(FeedSourceEvent(feedSource: source));
  }

  dispose() {
    _feedSourceStreamController.close();
  }
}
