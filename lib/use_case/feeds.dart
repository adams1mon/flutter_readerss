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

abstract class FeedPresenter {
  // should also add and delete the items of a feed source
  void addFeedSource(FeedSource feedSource);
  void removeFeedSource(FeedSource feedSource);

  void updateFeedSource(FeedSource feedSource);

  void updateFeedItem(FeedItem feedItem);
  void removeFeedItemsBySource(FeedSource feedSource);
}

abstract class FeedRepository {
  Future<FeedSource> getFeedSourceByUrl(String url);
  Future saveFeedSource(FeedSource source);
  Future deleteFeedSource(FeedSource source);

  Future saveFeedItem(FeedItem item);
  Future deleteFeedItem(FeedItem item);
}

abstract class BaseFeedUseCases {
  Future<void> loadFeedSource(String feedUrl);
  Future<void> bookmarkToggleFeedItem(FeedItem feedItem);
  Future<void> likeFeedItem(FeedItem feedItem);
  Future<void> viewFeedItem(FeedItem feedItem);
}

abstract class PersonalFeedUseCases extends BaseFeedUseCases {
  Future<void> toggleFeedSource(FeedSource feedSource);
  Future<void> deleteFeedSource(FeedSource feedSource);
}

class MainFeedUseCasesImpl implements BaseFeedUseCases {
  MainFeedUseCasesImpl({
    required FeedPresenter feedPresentation,
    required FeedRepository feedRepository,
  })  : _feedPresentation = feedPresentation,
        _feedRepository = feedRepository;

  final FeedPresenter _feedPresentation;
  final FeedRepository _feedRepository;

  @override
  Future<void> loadFeedSource(String feedUrl) async {
    try {
      final source = await _feedRepository.getFeedSourceByUrl(feedUrl);
      _feedPresentation.addFeedSource(source);
    } catch (e) {
      final msg = "an error occurred while loading the feed from url $feedUrl";
      log(msg);
      throw FeedLoadException(msg);
    }
  }

  @override
  Future<void> bookmarkToggleFeedItem(FeedItem item) async {
    try {
      item.bookmarked = !item.bookmarked;
      await _feedRepository.saveFeedItem(item);
      _feedPresentation.updateFeedItem(item);
    } catch (e) {
      log("error while bookmarking feed item $item");
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

class PersonalFeedUseCasesImpl extends MainFeedUseCasesImpl
    implements PersonalFeedUseCases {
  PersonalFeedUseCasesImpl({
    required FeedPresenter feedPresentation,
    required FeedRepository feedRepository,
  }) : super(
          feedPresentation: feedPresentation,
          feedRepository: feedRepository,
        );
  
  @override
  Future<void> toggleFeedSource(FeedSource source) async {
    try {
      source.enabled = !source.enabled;
      await _feedRepository.saveFeedSource(source);
      
      if (!source.enabled) {
        _feedPresentation.removeFeedItemsBySource(source);
      } else {
        _feedPresentation.addFeedSource(source);
      }
      _feedPresentation.updateFeedSource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source");
      throw FeedToggleException();
    }
  }
  
  @override
  Future<void> deleteFeedSource(FeedSource source) async {
    try {
      await _feedRepository.deleteFeedSource(source);
      _feedPresentation.removeFeedSource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source");
      throw FeedToggleException();
    }
  }
}
