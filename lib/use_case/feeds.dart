import 'dart:developer';

import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

class UseCaseException implements Exception {
  final dynamic message;
  final String exceptionName = "UseCaseException";

  UseCaseException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return exceptionName;
    return "$exceptionName: $message";
  }
}

class FeedLoadException extends UseCaseException {
  FeedLoadException([super.message]);

  @override
  String get exceptionName => "FeedLoadException";
}

class FeedToggleException extends UseCaseException {
  FeedToggleException([super.message]);

  @override
  String get exceptionName => "FeedToggleException";
}

class FeedBookmarkException extends UseCaseException {
  FeedBookmarkException([super.message]);

  @override
  String get exceptionName => "FeedBookmarkException";
}

abstract class FeedPresentationState {
  void addFeedSource(FeedSource feedSource);
  void updateFeedItem(FeedItem feedItem);
  void removeFeedItemsBySource(FeedSource feedSource);
}

abstract class FeedRepository {
  Future<FeedSource> loadFeedSourceByUrl(String url);
  Future toggleFeedSource(FeedSource source);
  Future saveFeedItem(FeedItem item);
}

class FeedUseCases {
  FeedUseCases({
    required FeedPresentationState feedPresentation,
    required FeedRepository feedRepository,
  })  : _feedPresentation = feedPresentation,
        _feedRepository = feedRepository;

  final FeedPresentationState _feedPresentation;
  final FeedRepository _feedRepository;

  void loadFeed(String feedUrl) async {
    try {
      final source = await _feedRepository.loadFeedSourceByUrl(feedUrl);
      _feedPresentation.addFeedSource(source);
    } catch (e) {
      final msg = "an error occurred while loading the feed from url $feedUrl";
      log(msg);
      throw FeedLoadException(msg); 
    }
  }

  void toggleFeedSource(FeedSource source) async {
    try {
      await _feedRepository.toggleFeedSource(source);
      _feedPresentation.removeFeedItemsBySource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source");
      throw FeedToggleException(); 
    }
  }

  void bookmarkFeedItem(FeedItem item) async {
    try {
      await _feedRepository.saveFeedItem(item);
      item.bookmarked = true;
      _feedPresentation.updateFeedItem(item);
    } catch (e) {
      log("error while bookmarking feed item $item");
      throw FeedBookmarkException();
    }
  }

  void likeFeedItem(FeedItem item) async {
    log("likeFeedItem stub !");
  }

  void viewFeedItem(FeedItem item) async {
    log("viewFeedItem stub !");
  }
}
