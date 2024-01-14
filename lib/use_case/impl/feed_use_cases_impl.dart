
import 'dart:developer';

import 'package:flutter_readrss/use_case/auth_use_cases.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exceptions.dart';
import 'package:flutter_readrss/use_case/feed_presenter.dart';
import 'package:flutter_readrss/use_case/feed_repository.dart';
import 'package:flutter_readrss/use_case/feed_use_cases.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

class FeedUseCasesImpl implements FeedUseCases {
  FeedUseCasesImpl({
    required FeedPresenter feedPresenter,
    required FeedRepository feedRepository,
    required AuthUseCases authUseCases,
  })  : _feedPresenter = feedPresenter,
        _feedRepository = feedRepository,
        _authUseCases = authUseCases;

  final FeedPresenter _feedPresenter;
  final FeedRepository _feedRepository;
  final AuthUseCases _authUseCases;

  @override
  Future<void> loadPredefinedFeedsByUrls(List<String> feedUrls) async {
    log("loading predefined feeds");
    for (final url in feedUrls) {
      try {
        final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
          url,
          FeedType.predefined,
        );
        // TODO: this could be done more efficiently
        _feedPresenter.setFeed(feedSource, feedItems);
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
  Future<void> loadPersonalFeedSourceByUrl(String feedUrl) async {
    if (_authUseCases.getUser() == null) {
      log("User must be logged in to add personal feeds");
      return;
    }

    try {
      final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
        feedUrl,
        FeedType.personal,
      );
      _feedPresenter.setFeed(feedSource, feedItems);
    } catch (e) {
      final msg = "an error occurred while loading the feed from url $feedUrl";
      log(msg, error: e);
      throw FeedLoadException(msg);
    }
  }

  @override
  Future<void> toggleFeedSource(FeedSource source) async {
    if (_authUseCases.getUser() == null) {
      log("User must be logged in to toggle feed sources");
      return;
    }

    try {
      source.enabled = !source.enabled;
      await _feedRepository.saveFeedSource(source);

      if (!source.enabled) {
        _feedPresenter.setFeed(source, []);
      } else {
        final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
          source.rssUrl,
          source.type,
        );
        _feedPresenter.setFeed(feedSource, feedItems);
      }
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw FeedToggleException();
    }
  }

  @override
  Future<void> deleteFeedSource(FeedSource source) async {
    if (_authUseCases.getUser() == null) {
      log("User must be logged in to delete feed sources");
      return;
    }

    try {
      await _feedRepository.deleteFeedSource(source);
      _feedPresenter.setFeed(source, []);
      _feedPresenter.removeFeedSource(source);
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw FeedToggleException();
    }
  }

  @override
  Future<void> bookmarkToggleFeedItem(FeedItem item) async {
    if (_authUseCases.getUser() == null) {
      log("User must be logged in to bookmark items");
      return;
    }

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
    if (_authUseCases.getUser() == null) {
      log("User must be logged in to like items");
      return;
    }

    log("likeFeedItem stub !");
  }

  @override
  Future<void> viewFeedItem(FeedItem item) async {
    if (_authUseCases.getUser() == null) return;

    log("viewFeedItem stub !");
  }
}
