import 'dart:async';
import 'dart:developer';
import 'package:flutter_readrss/use_case/feeds.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:flutter_readrss/use_case/model/feed_source_type.dart';

class FeedSourcesEvent {
  const FeedSourcesEvent({required this.feedSources});
  final List<FeedSource> feedSources;
}

class FeedItemsEvent {
  const FeedItemsEvent({required this.feedItems});
  final List<FeedItem> feedItems;
}

// called by the ui
abstract class FeedProvider {
  Stream<FeedSourcesEvent> getFeedSourcesStream();
  Stream<FeedItemsEvent> getFeedItemsStream();
  void dispose();
}

// subscribes to the list of feed items given
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

class FeedProviderImpl implements FeedProvider {
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

  void setFeedSource(FeedSource source) {
    log("FeedProvider: adding feed source ${source.title}");
    _feedSources[source.rssUrl] = source;
    _publishFeedSources(_feedSources);
  }

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

  void removeFeedSource(FeedSource source) {
    log("FeedProvider: removing feed source ${source.title}");
    _feedSources.remove(source.rssUrl);
    _publishFeedSources(_feedSources);
  }

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
            .toList(growable: false)));
  }
}

// called by the use cases
class FeedPresenterImpl implements FeedPresenter {
  final FeedProviderImpl _mainFeedProvider;
  final FeedProviderImpl _personalFeedProvider;

  FeedPresenterImpl({
    required FeedProviderImpl mainFeedProvider,
    required FeedProviderImpl personalFeedProvider,
  })  : _mainFeedProvider = mainFeedProvider,
        _personalFeedProvider = personalFeedProvider;

  @override
  void setFeed(FeedSource source, List<FeedItem> items) {
    log("FeedPresenter: adding feed source ${source.title} and items");
    switch (source.type) {
      case FeedType.predefined:
        _mainFeedProvider.setFeedSource(source);
        _mainFeedProvider.setFeedItems(source.rssUrl, items);
      case FeedType.personal:
        _personalFeedProvider.setFeedSource(source);
        _personalFeedProvider.setFeedItems(source.rssUrl, items);
    }
  }

  @override
  void removeFeedSource(FeedSource source) {
    log("FeedPresenter: removing feed source ${source.title}");
    switch (source.type) {
      case FeedType.predefined:
        _mainFeedProvider.removeFeedSource(source);
      case FeedType.personal:
        _personalFeedProvider.removeFeedSource(source);
    }
  }

  @override
  void updateFeedItem(FeedItem feedItem) {
    log("FeedPresenter: updating feed item ${feedItem.articleUrl}");
    // item update must occur in every feed
    // so we have a consistent UI
    _mainFeedProvider.updateFeedItem(feedItem);
    _personalFeedProvider.updateFeedItem(feedItem);
  }
}
