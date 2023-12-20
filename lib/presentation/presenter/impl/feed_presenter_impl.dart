import 'dart:developer';
import 'package:flutter_readrss/presentation/presenter/impl/feed_connector.dart';
import 'package:flutter_readrss/use_case/feed_presenter.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';


// called by the use cases
class FeedPresenterImpl implements FeedPresenter {
  final FeedConnector _mainFeedProvider;
  final FeedConnector _personalFeedProvider;

  FeedPresenterImpl({
    required FeedConnector mainFeedProvider,
    required FeedConnector personalFeedProvider,
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
    // item update must occur in every feed,
    // so we have a consistent UI
    _mainFeedProvider.updateFeedItem(feedItem);
    _personalFeedProvider.updateFeedItem(feedItem);
  }
}
