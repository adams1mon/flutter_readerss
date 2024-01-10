import 'dart:developer';
import 'package:flutter_readrss/presentation/presenter/feed_sink.dart';
import 'package:flutter_readrss/use_case/feed_presenter.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';


// called by the use cases
class FeedPresenterImpl implements FeedPresenter {
  final FeedSink _mainFeedSink;
  final FeedSink _personalFeedSink;

  FeedPresenterImpl({
    required FeedSink mainFeedSink,
    required FeedSink personalFeedSink,
  })  : _mainFeedSink = mainFeedSink,
        _personalFeedSink = personalFeedSink;

  @override
  void setFeed(FeedSource source, List<FeedItem> items) {
    log("FeedPresenter: adding feed source ${source.title} and items");
    switch (source.type) {
      case FeedType.predefined:
        _mainFeedSink.setFeedSource(source);
        _mainFeedSink.setFeedItems(source.rssUrl, items);
      case FeedType.personal:
        _personalFeedSink.setFeedSource(source);
        _personalFeedSink.setFeedItems(source.rssUrl, items);
    }
  }

  @override
  void removeFeedSource(FeedSource source) {
    log("FeedPresenter: removing feed source ${source.title}");
    switch (source.type) {
      case FeedType.predefined:
        _mainFeedSink.removeFeedSource(source);
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
  }
}
