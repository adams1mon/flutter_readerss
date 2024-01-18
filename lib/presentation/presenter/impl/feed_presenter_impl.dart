import 'dart:developer';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/feeds/feed_presenter.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_type.dart';

// TODO: use separate presenters instead of FeedType field in feed sources and items

// distributes feeds and items based on their types (predefined, personal)
class FeedPresenterImpl implements FeedPresenter {

  final FeedItemsSink _mainFeedItemsSink;
  final FeedSourceSink _personalFeedSourceSink;
  final FeedItemsSink _personalFeedItemsSink;
  final FeedItemsSink _bookmarkFeedItemsSink;

  FeedPresenterImpl({
    required FeedItemsSink mainFeedItemsSink,
    required FeedSourceSink personalFeedSourceSink,
    required FeedItemsSink personalFeedItemsSink,
    required FeedItemsSink bookmarkFeedItemsSink,
  })  : _mainFeedItemsSink = mainFeedItemsSink,
        _personalFeedSourceSink = personalFeedSourceSink,
        _personalFeedItemsSink = personalFeedItemsSink,
        _bookmarkFeedItemsSink = bookmarkFeedItemsSink;

  @override
  void setFeedSource(FeedSource feedSource) {
    log("FeedPresenter: setting feed source ${feedSource.title}");
    switch (feedSource.type) {
      case FeedType.predefined:
        // don't publish predefined feed sources, they aren't shown anywhere in the UI
        break;
      case FeedType.personal:
        _personalFeedSourceSink.setFeedSource(feedSource);
    }
  }

  @override
  void setFeedSources(List<FeedSource> feedSources) {
    log("FeedPresenter: setting feed sources");
    // don't publish predefined feed sources, they aren't shown anywhere in the UI
    final personal = feedSources.where((source) => source.type == FeedType.personal).toList();
    _personalFeedSourceSink.setFeedSources(personal);
  }

  @override
  void deleteFeedSource(FeedSource feedSource) {
    log("FeedPresenter: removing feed ${feedSource.title}");
    switch (feedSource.type) {
      case FeedType.predefined:
        // predefined feeds cannot be removed 
        break;
      case FeedType.personal:
        _personalFeedSourceSink.removeFeedSource(feedSource);
    }
  }

  @override
  void setFeedItems(List<FeedItem> feedItems) {
    log("FeedPresenter: setting feed items from ${feedItems.first.feedSourceRssUrl}");    

    // filter the items
    final predefined = <FeedItem>[];
    final personal = <FeedItem>[]; 
    
    for (final item in feedItems) {
      switch (item.type) {
        case FeedType.predefined: predefined.add(item);
        case FeedType.personal: personal.add(item);
      }
    };

    _mainFeedItemsSink.setFeedItems(predefined);
    _personalFeedItemsSink.setFeedItems(personal);
  }

  @override
  void updateFeedItem(FeedItem feedItem) {
    log ("FeedPresenter: updating feed item ${feedItem.articleUrl}");
    // item update must occur in every feed,
    // so we have a consistent UI
    _mainFeedItemsSink.updateFeedItem(feedItem);
    _personalFeedItemsSink.updateFeedItem(feedItem);
    _bookmarkFeedItemsSink.updateFeedItem(feedItem);
  }

  @override
  void deleteFeedItemsForSource(FeedSource feedSource) {
    log("FeedPresenter: removing feed items for source ${feedSource.title}");
    switch (feedSource.type) {
      case FeedType.predefined:
        // predefined feeds cannot be removed 
        break;
      case FeedType.personal:
        _personalFeedItemsSink.removeFeedItemsForSource(feedSource.rssUrl);
    }
  }

  @override
  void setBookmarkedFeedItems(List<FeedItem> feedItems) {
    log("FeedPresenter: setting bookmarked feed items");
    _bookmarkFeedItemsSink.setFeedItems(feedItems);
  }

  @override
  void clearAllFeeds() {
    log("FeedPresenter: clearing all feed sources and feed items");
    _mainFeedItemsSink.removeFeedItems();
    _personalFeedSourceSink.removeFeedSources();
    _personalFeedItemsSink.removeFeedItems();
    _bookmarkFeedItemsSink.removeFeedItems();
  }
  
}
