import 'dart:developer';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/feed_presenter.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';


// TODO: this class has use case leaks which should be moved to the use case layer
// called by the use cases
class FeedPresenterImpl implements FeedPresenter {
  final FeedSink _mainFeedSink;
  final FeedSink _personalFeedSink;
  final FeedSink _bookmarkFeedSink;

  FeedPresenterImpl({
    required FeedSink mainFeedSink,
    required FeedSink personalFeedSink,
    required FeedSink bookmarkFeedSink,
  })  : _mainFeedSink = mainFeedSink,
        _personalFeedSink = personalFeedSink,
        _bookmarkFeedSink = bookmarkFeedSink;

  @override
  void setFeed(FeedSource source, List<FeedItem> items) {
    log("FeedPresenter: adding feed source ${source.title} and items");
    switch (source.type) {
      case FeedType.predefined:
        // don't publish predefined feed sources, they aren't shown anywhere in the UI
        _mainFeedSink.setFeedItems(source.rssUrl, items);
      case FeedType.personal:
        _personalFeedSink.setFeedSource(source);
        _personalFeedSink.setFeedItems(source.rssUrl, items);
    }
  }

  @override
  void setBookmarkedFeedItems(List<FeedItem> feedItems) {
    log("FeedPresenter: setting bookmarked feed items");
    // use a dummy rssUrl
    _bookmarkFeedSink.setFeedItems("bookmarkedItems", feedItems);
  }

  @override
  void removeFeedSource(FeedSource source) {
    log("FeedPresenter: removing feed source ${source.title}");
    switch (source.type) {
      case FeedType.predefined:
        // predefined feed sources cannot be removed 
        break;
      case FeedType.personal:
        _personalFeedSink.removeFeedSource(source);
    }
  }

  @override
  void updateFeedItem(FeedItem feedItem) {
    log("FeedPresenter: updating feed item ${feedItem.articleUrl}");
    // item update must occur in every feed,
    // so we have a consistent UI
    _mainFeedSink.updateFeedItem(feedItem);
    _personalFeedSink.updateFeedItem(feedItem);
    _bookmarkFeedSink.updateFeedItem(feedItem);
  }
}
