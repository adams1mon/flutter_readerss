import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_item_repo_model.dart';
import 'package:flutter_readrss/use_case/auth/auth_use_cases.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exception.dart';
import 'package:flutter_readrss/use_case/feeds/feed_presenter.dart';
import 'package:flutter_readrss/use_case/feeds/feed_repository.dart';
import 'package:flutter_readrss/use_case/feeds/feed_use_cases.dart';
import 'package:flutter_readrss/use_case/feeds/main_rss_feeds.dart';
import 'package:flutter_readrss/use_case/feeds/mapper/feed_mappers.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item_details.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source_details.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_type.dart';

// TODO: resolve 'scope leakage' between use case and repository layers (proper separation would help)

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

  // loading predefined feeds flow
  // 1. fetch feed model + items from the network
  // 2. fetch views + likes for all items from firebase (public collection, no auth required here)
  // 3. if user is logged in, check if any items are saved for the user
  // 4. present items of the feed

  @override
  Future<void> loadPredefinedFeeds() async {
    log("loading predefined urls: $mainFeedRssUrls");

    final user = _authUseCases.getUser();
    for (final url in mainFeedRssUrls) {
      // 1. fetch feed and its items + their views and likes
      try {
        final (feedSourceRepoModel, feedItemRepoModels) =
            await _feedRepository.fetchFeedByUrl(url);

        final feedSource = FeedSourceMapper.fromRepoModel(
          feedSourceRepoModel,
          true,
          FeedType.predefined,
        );

        // 2. if the user is logged in, fetch personal item details (liked, bookmarked)
        final feedItems = await _getFeedItemDetails(
            feedItemRepoModels, user, FeedType.predefined);

        _feedPresenter.setFeedSource(feedSource);
        _feedPresenter.setFeedItems(feedItems);
      } catch (e) {
        log("error while fetching predefined feed from url $url", error: e);
        throw UseCaseException("Error while loading main feeds");
      }
    }
  }

  // loading personal feeds flow
  // 1. fetch user's feeds
  // 2. for every feed, if a feed is enabled, fetch its feed items from the network
  // 3. fetch views + likes for all items from firebase (public collection, no auth required)
  // 4. fetch liked + bookmarked status
  // 5. present personal feed and its items

  @override
  Future<void> loadPersonalFeeds() async {
    log("loading personal feeds");

    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to load their personal feeds");
      return;
    }

    try {
      // 1. fetch personal feeds and details (feed enabled), their items + their views and likes
      final personalFeeds = await _feedRepository.getPersonalFeeds(user.uid);

      for (final feedSourceDetails in personalFeeds) {
        // TODO: only fetch feed and its items if it's enabled - currently only the FeedSourceDetails are stored, and a FeedSource can't be constructed so it must be fetched
        final (feedSourceRepoModel, feedItemRepoModels) = await _feedRepository
            .fetchFeedByUrl(feedSourceDetails.feedSourceUrl);

        final feedSource = FeedSourceMapper.fromRepoModel(
          feedSourceRepoModel,
          feedSourceDetails.enabled,
          FeedType.personal,
        );
        log("setting personal feed source ${feedSource.rssUrl}");

        _feedPresenter.setFeedSource(feedSource);

        // 2. fetch personal item details (liked, bookmarked)
        if (feedSource.enabled) {
          final feedItems = await _getFeedItemDetails(
              feedItemRepoModels, user, FeedType.personal);
          _feedPresenter.setFeedItems(feedItems);
        }
      }
    } catch (e) {
      log("error while fetching personal feeds");
      throw UseCaseException("Error while loading personal feeds");
    }
  }

  @override
  Future<void> loadBookmarkedFeedItems() async {
    log("loading bookmarked feed items");

    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to load their personal feeds");
      return;
    }

    final bookmarkedFeedItems =
        await _feedRepository.fetchBookmarkedFeedItems(user.uid);

    // create business objects
    final feedItems = bookmarkedFeedItems.map((itemTuple) {
      final (details, repoModel) = itemTuple;
      return FeedItemMapper.fromRepoModel(
          repoModel, details.bookmarked, details.liked, FeedType.personal);
    }).toList();

    _feedPresenter.setBookmarkedFeedItems(feedItems);
  }

  @override
  Future<void> addPersonalFeedSourceByUrl(String url) async {
    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to add personal feeds");
      return;
    }
    log("adding personal feed by url $url");

    // 1. fetch feed and its items + their views and likes
    try {
      final (feedSourceRepoModel, feedItemRepoModels) =
          await _feedRepository.fetchFeedByUrl(url);

      // a new personal feed is enabled by default
      final feedSource = FeedSourceMapper.fromRepoModel(
        feedSourceRepoModel,
        true,
        FeedType.personal,
      );

      // save the feed
      final feedSourceDetails = FeedSourceDetails(
          feedSourceUrl: feedSource.rssUrl, enabled: feedSource.enabled);
      await _feedRepository.saveFeedSourceDetails(user.uid, feedSourceDetails);

      // 2. fetch personal item details (liked, bookmarked)
      final feedItems = await _getFeedItemDetails(
          feedItemRepoModels, user, FeedType.personal);

      _feedPresenter.setFeedSource(feedSource);
      _feedPresenter.setFeedItems(feedItems);
    } catch (e) {
      log("error while adding personal feed from url $url");
      throw UseCaseException("Error while adding personal feed");
    }
  }

  @override
  Future<void> toggleFeedSource(FeedSource source) async {
    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to toggle feed sources");
      return;
    }

    try {
      source.enabled = !source.enabled;

      final feedSourceDetails = FeedSourceDetails(
        feedSourceUrl: source.rssUrl,
        enabled: source.enabled,
      );
      await _feedRepository.saveFeedSourceDetails(user.uid, feedSourceDetails);
      _feedPresenter.setFeedSource(source);

      if (!source.enabled) {
        _feedPresenter.deleteFeedItemsForSource(source);
      } else {
        final (feedSourceRepoModel, feedItemRepoModels) =
            await _feedRepository.fetchFeedByUrl(source.rssUrl);

        final feedSource = FeedSourceMapper.fromRepoModel(
          feedSourceRepoModel,
          source.enabled,
          source.type,
        );

        // 2. fetch personal item details (liked, bookmarked)
        final feedItems =
            await _getFeedItemDetails(feedItemRepoModels, user, source.type);

        _feedPresenter.setFeedSource(feedSource);
        _feedPresenter.setFeedItems(feedItems);
      }
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw UseCaseException("Error while toggleing feed source");
    }
  }

  // add user's details (liked, bookmarked) to a list of feed items
  Future<List<FeedItem>> _getFeedItemDetails(
      List<FeedItemRepoModel> itemRepoModels,
      User? user,
      FeedType feedItemType) async {
    final itemList = <FeedItem>[];

    for (final repoModel in itemRepoModels) {
      var liked = false;
      var bookmarked = false;

      try {
        if (user != null) {
          final feedItemDetails =
              await _feedRepository.getFeedItemDetails(user.uid, repoModel);
          if (feedItemDetails != null) {
            liked = feedItemDetails.liked;
            bookmarked = feedItemDetails.bookmarked;
          }
        }

        itemList.add(FeedItemMapper.fromRepoModel(
            repoModel, bookmarked, liked, feedItemType));
      } catch (e) {
        log("error while fetching user's feed item details for ${repoModel.articleUrl}");
      }
    }
    return itemList;
  }

  @override
  Future<void> deleteFeedSource(FeedSource source) async {
    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to delete feed sources");
      return;
    }

    try {
      final feedSourceDetails = FeedSourceDetails(
        feedSourceUrl: source.rssUrl,
        enabled: source.enabled,
      );
      await _feedRepository.deleteFeedSourceDetails(
          user.uid, feedSourceDetails);
      _feedPresenter.deleteFeedItemsForSource(source);
      _feedPresenter.deleteFeedSource(source);
    } catch (e) {
      log("an error occurred while deleting feed source $source", error: e);
      throw UseCaseException("Error while deleting feed source");
    }
  }

  @override
  Future<void> toggleBookmarkFeedItem(FeedItem item) async {
    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to bookmark items");
      return;
    }

    log("bookmarking feed item ${item.articleUrl}");

    try {
      item.bookmarked = !item.bookmarked;
      final itemDetails = FeedItemDetails(
        feedItemId: item.id,
        liked: item.liked,
        bookmarked: item.bookmarked,
      );
      // only save the item if there is a reason to
      if (item.liked || item.bookmarked) {
        await _feedRepository.saveFeedItemDetails(user.uid, itemDetails);
      } else {
        await _feedRepository.deleteFeedItemDetails(user.uid, itemDetails);
      }
      _feedPresenter.updateFeedItem(item);
    } catch (e) {
      log("error while bookmarking feed item $item", error: e);
      throw UseCaseException("Error while bookmarking feed item");
    }
  }

  @override
  Future<void> toggleLikeFeedItem(FeedItem item) async {
    final user = _authUseCases.getUser();
    if (user == null) {
      log("User must be logged in to like items");
      return;
    }

    item.liked = !item.liked;
    if (item.liked) {
      item.likes++;
    } else {
      item.likes--;
    }

    try {
      // TODO: why does the use case layer know about how items are stored? (common and personal part separate)
      // save common part
      final feedItemModel = FeedItemRepoModel(
        feedSourceTitle: item.feedSourceTitle,
        feedSourceRssUrl: item.feedSourceRssUrl,
        title: item.title,
        description: item.description,
        articleUrl: item.articleUrl,
        sourceIconUrl: item.sourceIconUrl,
        pubDate: item.pubDate,
        views: item.views,
        likes: item.likes,
      );
      _feedRepository.saveFeedItem(feedItemModel);

      // update user-specific part
      final itemDetails = FeedItemDetails(
        feedItemId: item.id,
        liked: item.liked,
        bookmarked: item.bookmarked,
      );
      // only save the item if there is a reason to
      if (item.liked || item.bookmarked) {
        await _feedRepository.saveFeedItemDetails(user.uid, itemDetails);
      } else {
        await _feedRepository.deleteFeedItemDetails(user.uid, itemDetails);
      }
      log("like feed item ${item.articleUrl}");

      _feedRepository.saveFeedItemDetails(user.uid, itemDetails);
      _feedPresenter.updateFeedItem(item);
    } catch (e) {
      log("error while toggleing feed item like", error: e);
      throw UseCaseException("Error while liking feed item");
    }
  }

  @override
  Future<void> viewFeedItem(FeedItem item) async {
    item.views += 1;
    log("view feed item ${item.articleUrl}");

    final feedItemRepoModel = FeedItemRepoModel(
      feedSourceTitle: item.feedSourceTitle,
      feedSourceRssUrl: item.feedSourceRssUrl,
      title: item.title,
      description: item.description,
      articleUrl: item.articleUrl,
      sourceIconUrl: item.sourceIconUrl,
      pubDate: item.pubDate,
      views: item.views,
      likes: item.likes,
    );

    try {
      // user not required to save items
      _feedRepository.saveFeedItem(feedItemRepoModel);
      _feedPresenter.updateFeedItem(item);
    } catch (e) {
      log("error while updating feed item views", error: e);
      throw UseCaseException("Error while updating feed item views");
    }
  }
}
