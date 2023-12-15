import 'dart:developer';

import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:flutter_readrss/use_case/model/feed_source_type.dart';

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

abstract class FeedPresenter {
  // should also add and delete the items of a feed source
  void addFeedSource(FeedSource feedSource);
  void removeFeedSource(FeedSource feedSource);

  void updateFeedSource(FeedSource feedSource);

  void updateFeedItem(FeedItem feedItem);
  void removeFeedItemsBySource(FeedSource feedSource);
}

abstract class FeedRepository {
  Future<FeedSource> getFeedSourceByUrl(
    String url,
    FeedSourceType feedSourceType,
  );
  Future saveFeedSource(FeedSource source);
  Future deleteFeedSource(FeedSource source);

  Future saveFeedItem(FeedItem item);
  Future deleteFeedItem(FeedItem item);
}

abstract class FeedUseCases {
  Future<void> loadFeedSourcesByUrls(List<String> feedUrls);
  Future<void> loadFeedSourceByUrl(String feedUrl);
  Future<void> toggleFeedSource(FeedSource feedSource);
  Future<void> deleteFeedSource(FeedSource feedSource);
  Future<void> bookmarkToggleFeedItem(FeedItem feedItem);
  Future<void> likeFeedItem(FeedItem feedItem);
  Future<void> viewFeedItem(FeedItem feedItem);
}

class FeedUseCasesImpl implements FeedUseCases {
  FeedUseCasesImpl({
    required FeedPresenter feedPresenter,
    required FeedRepository feedRepository,
  })  : _feedPresenter = feedPresenter,
        _feedRepository = feedRepository;

  final FeedPresenter _feedPresenter;
  final FeedRepository _feedRepository;

  @override
  Future<void> loadFeedSourcesByUrls(List<String> feedUrls) async {
    for (final url in feedUrls) {
      try {
        final source = await _feedRepository.getFeedSourceByUrl(
          url,
          FeedSourceType.predefined,
        );
        // TODO: this could be done more efficiently
        _feedPresenter.addFeedSource(source);
      } catch (e) {
        log("an error occurred while loading the feed from url $url", error: e);
      }
    }
  }

  // TODO: solutions for strange bug when bookmarking from one
  // feed overwrites the other bookmarked items
  // only occurs when the same feed is added to both feed pages
  // and the items from one of them overwrite the items from the other
  // one in the presentation layer

  // TODO: 1. whenever a personal feed is added which is
  // also a default feed, move the default to the personal feeds
  // instead of duplicating

  // TODO: 2. don't allow users to add personal feeds which are
  // already present as default feeds

  // TODO: 3. if a personal feed is loaded which is already present
  // as a default (predefined) feed, set the feed's type to
  // "predefinedAndPersonal" or smth to indicate that it
  // needs to be shown on multiple presentation pages

  @override
  Future<void> loadFeedSourceByUrl(String feedUrl) async {
    try {
      final source = await _feedRepository.getFeedSourceByUrl(
        feedUrl,
        FeedSourceType.personal,
      );
      _feedPresenter.addFeedSource(source);
    } catch (e) {
      final msg = "an error occurred while loading the feed from url $feedUrl";
      log(msg, error: e);
      throw FeedLoadException(msg);
    }
  }

  @override
  Future<void> toggleFeedSource(FeedSource source) async {
    try {
      source.enabled = !source.enabled;
      await _feedRepository.saveFeedSource(source);

      if (!source.enabled) {
        _feedPresenter.removeFeedItemsBySource(source);
      } else {
        _feedPresenter.addFeedSource(source);
      }
      _feedPresenter.updateFeedSource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw FeedToggleException();
    }
  }

  @override
  Future<void> deleteFeedSource(FeedSource source) async {
    try {
      await _feedRepository.deleteFeedSource(source);
      _feedPresenter.removeFeedSource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw FeedToggleException();
    }
  }

  @override
  Future<void> bookmarkToggleFeedItem(FeedItem item) async {
    try {
      item.bookmarked = !item.bookmarked;
      await _feedRepository.saveFeedItem(item);
      _feedPresenter.updateFeedItem(item);
    } catch (e) {
      log("error while bookmarking feed item $item", error: e);
      throw FeedBookmarkException();
    }
  }

  @override
  Future<void> likeFeedItem(FeedItem item) async {
    log("likeFeedItem stub !");
  }

  @override
  Future<void> viewFeedItem(FeedItem item) async {
    log("viewFeedItem stub !");
  }
}
