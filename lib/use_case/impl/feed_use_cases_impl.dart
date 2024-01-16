import 'dart:developer';

import 'package:flutter_readrss/data/feed_repository_impl.dart';
import 'package:flutter_readrss/use_case/auth_use_cases.dart';
import 'package:flutter_readrss/use_case/const/main_rss_feeds.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exceptions.dart';
import 'package:flutter_readrss/use_case/feed_presenter.dart';
import 'package:flutter_readrss/use_case/feed_repository.dart';
import 'package:flutter_readrss/use_case/feed_use_cases.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';

// TODO: resolve 'scope leakage' between use case and repository layers (proper separation would help lol)
// TODO: load bookmarked items when user is logged in

class FeedItemMapper {
  static FeedItem fromRepoModel(
    FeedItemRepoModel repoModel,
    final bookmarked,
    final liked,
  ) {
    return FeedItem(
      id: repoModel.id,
      feedSourceTitle: repoModel.feedSourceTitle,
      feedSourceRssUrl: repoModel.feedSourceRssUrl,
      title: repoModel.title,
      description: repoModel.description,
      articleUrl: repoModel.articleUrl,
      sourceIconUrl: repoModel.sourceIconUrl,
      pubDate: repoModel.pubDate,
      views: repoModel.views,
      likes: repoModel.likes,
      bookmarked: bookmarked,
      liked: liked,
    );
  }
}

class FeedSourceMapper {
  static FeedSource fromRepoModel(
    FeedSourceRepoModel repoModel,
    bool enabled,
    FeedType type,
  ) {
    return FeedSource(
      id: repoModel.id,
      title: repoModel.title,
      rssUrl: repoModel.rssUrl,
      siteUrl: repoModel.siteUrl,
      iconUrl: repoModel.iconUrl,
      ttl: repoModel.ttl,
      enabled: enabled,
      type: type,
    );
  }
}

// user-specific feed item details
class FeedItemDetails {
  String feedItemId;
  bool liked;
  bool bookmarked;

  FeedItemDetails(
      {required this.feedItemId,
      required this.liked,
      required this.bookmarked});
}

// user-specific feed source details
class FeedSourceDetails {
  String feedSourceUrl;
  bool enabled;
  FeedSourceDetails({required this.feedSourceUrl, required this.enabled});
}

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

  // TODO:
  // I. loading predefined feeds flow

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
        final feedItems = await Future.wait(
          feedItemRepoModels.map((feedItemRepoModel) async {
            var liked = false;
            var bookmarked = false;

            if (user != null) {
              final feedItemDetails = await _feedRepository.getFeedItemDetails(
                  user.uid, feedItemRepoModel);
              if (feedItemDetails != null) {
                liked = feedItemDetails.liked;
                bookmarked = feedItemDetails.bookmarked;
              }
            }

            // create a business object
            return FeedItemMapper.fromRepoModel(
              feedItemRepoModel,
              bookmarked,
              liked,
            );
          }),
        );

        _feedPresenter.setFeed(feedSource, feedItems);
      } catch (e) {
        log("error while fetching predefined feed from url $url", error: e);
        throw UseCaseException("Error while loading main feeds");
      }
    }
  }

  // II. loading personal feeds flow

  // 1. fetch feed model + items from the network
  // 2. fetch views + likes for all items from firebase (public collection, no auth required)
  // 3. [user should be logged in] fetch liked + bookmarked status for all items from firebase
  // 4. [user should be logged in] fetch enabled status for feed sources from firebase
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
      final personalFeeds = await _feedRepository.fetchPersonalFeeds(user.uid);

      for (final (feedSourceDetails, feedSourceRepoModel, feedItemRepoModels)
          in personalFeeds) {
        final feedSource = FeedSourceMapper.fromRepoModel(
          feedSourceRepoModel,
          feedSourceDetails.enabled,
          FeedType.personal,
        );

        // 2. fetch personal feed item details
        final feedItems = await Future.wait(
          feedItemRepoModels.map((feedItemRepoModel) async {
            final feedItemDetails = await _feedRepository.getFeedItemDetails(
                user.uid, feedItemRepoModel);

            // create a business object
            return FeedItemMapper.fromRepoModel(
              feedItemRepoModel,
              feedItemDetails?.bookmarked ?? false,
              feedItemDetails?.liked ?? false,
            );
          }),
        );

        _feedPresenter.setFeed(feedSource, feedItems);
      }
    } catch (e) {
      log("error while fetching personal feeds");
      throw UseCaseException("Error while loading personal feeds");
    }
  }

  // III. loading bookmarked feed items flow
  // 1. if the user is logged in, fetch every feed item

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
          repoModel, details.bookmarked, details.liked);
    }).toList();

    // TODO: set bookmarked feed items in presenter
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

      // 2. fetch personal item details (liked, bookmarked)
      final feedItems = await Future.wait(
        feedItemRepoModels.map((feedItemRepoModel) async {
          final feedItemDetails = await _feedRepository.getFeedItemDetails(
              user.uid, feedItemRepoModel);

          // create a business object
          return FeedItemMapper.fromRepoModel(
            feedItemRepoModel,
            feedItemDetails?.bookmarked ?? false,
            feedItemDetails?.liked ?? false,
          );
        }),
      );

      _feedPresenter.setFeed(feedSource, feedItems);
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

      if (!source.enabled) {
        _feedPresenter.setFeed(source, []);
      } else {
        final (feedSourceRepoModel, feedItemRepoModels) =
            await _feedRepository.fetchFeedByUrl(source.rssUrl);

        final feedSource = FeedSourceMapper.fromRepoModel(
          feedSourceRepoModel,
          source.enabled,
          source.type,
        );

        // 2. fetch personal item details (liked, bookmarked)
        final feedItems = await Future.wait(
          feedItemRepoModels.map((feedItemRepoModel) async {
            final feedItemDetails = await _feedRepository.getFeedItemDetails(
                user.uid, feedItemRepoModel);

            // create a business object
            return FeedItemMapper.fromRepoModel(
              feedItemRepoModel,
              feedItemDetails?.bookmarked ?? false,
              feedItemDetails?.liked ?? false,
            );
          }),
        );

        _feedPresenter.setFeed(feedSource, feedItems);
      }
    } catch (e) {
      log("an error occurred while toggleing feed source $source", error: e);
      throw UseCaseException("Error while toggleing feed source");
    }
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
      _feedPresenter.setFeed(source, []);
      _feedPresenter.removeFeedSource(source);
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
    } catch (e) {
      log("error while toggleing feed item like", error: e);
      throw UseCaseException("Error while liking feed item");
    }
  }

  @override
  Future<void> viewFeedItem(FeedItem item) async {
    // TODO: fix this ever-increasing mess

    item.views += 1;
    log("view feed item ${item.articleUrl}");

    final feedItemRepoModel = FeedItemRepoModel.fromFeedItem(item);

    try {
      // user not required to save items
      _feedRepository.saveFeedItem(feedItemRepoModel);
    } catch (e) {
      log("error while updating feed item views", error: e);
      throw UseCaseException("Error while updating feed item views");
    }
  }

  // @override
  // Future<void> loadPredefinedFeedsByUrls(List<String> feedUrls) async {
  //   log("loading predefined feeds");
  //   for (final url in feedUrls) {
  //     try {
  //       final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
  //         url,
  //         FeedType.predefined,
  //         _authUseCases.getUser()?.uid,
  //       );
  //       // TODO: this could be done more efficiently
  //       _feedPresenter.setFeed(feedSource, feedItems);
  //     } catch (e) {
  //       log("an error occurred while loading the feed from url $url", error: e);
  //     }
  //   }
  // /

  // @override
  // Future<void> loadPersonalFeeds() async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to load their personal feeds");
  //     return;
  //   }

  //   log("loading personal feeds");

  //   try {
  //     final feedList = await _feedRepository.getPersonalFeeds(user.uid);
  //     for (final (source, items) in feedList) {
  //       _feedPresenter.setFeed(source, items);
  //     }
  //   } catch (e) {
  //     log("an error occurred while loading personal feeds", error: e);
  //   }
  // }

  // @override
  // Future<void> addPersonalFeedSourceByUrl(String feedUrl) async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to add personal feeds");
  //     return;
  //   }
  //   log("adding personal feed by url $feedUrl");

  //   try {
  //     final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
  //       feedUrl,
  //       FeedType.personal,
  //       user.uid,
  //     );
  //     _feedPresenter.setFeed(feedSource, feedItems);
  //   } catch (e) {
  //     final msg = "an error occurred while loading the feed from url $feedUrl";
  //     log(msg, error: e);
  //     throw FeedLoadException(msg);
  //   }
  // }

  // @override
  // Future<void> toggleFeedSource(FeedSource source) async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to toggle feed sources");
  //     return;
  //   }

  //   try {
  //     source.enabled = !source.enabled;
  //     await _feedRepository.saveFeedSource(source, user.uid);

  //     if (!source.enabled) {
  //       _feedPresenter.setFeed(source, []);
  //     } else {
  //       final (feedSource, feedItems) = await _feedRepository.getFeedByUrl(
  //         source.rssUrl,
  //         source.type,
  //         user.uid,
  //       );
  //       _feedPresenter.setFeed(feedSource, feedItems);
  //     }
  //   } catch (e) {
  //     log("an error occurred while toggleing feed source $source", error: e);
  //     throw FeedToggleException();
  //   }
  // }

  // @override
  // Future<void> deleteFeedSource(FeedSource source) async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to delete feed sources");
  //     return;
  //   }

  //   try {
  //     await _feedRepository.deleteFeedSource(source, user.uid);
  //     _feedPresenter.setFeed(source, []);
  //     _feedPresenter.removeFeedSource(source);
  //   } catch (e) {
  //     log("an error occurred while toggleing feed source $source", error: e);
  //     throw FeedToggleException();
  //   }
  // }

  // @override
  // Future<void> toggleBookmarkFeedItem(FeedItem item) async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to bookmark items");
  //     return;
  //   }

  //   try {
  //     item.bookmarked = !item.bookmarked;
  //     if (item.bookmarked) {
  //       await _feedRepository.saveFeedItem(item, user.uid);
  //     } else {
  //       await _feedRepository.deleteFeedItem(item, user.uid);
  //     }
  //     _feedPresenter.updateFeedItem(item);
  //   } catch (e) {
  //     log("error while bookmarking feed item $item", error: e);
  //     throw FeedBookmarkException();
  //   }
  // }

  // @override
  // Future<void> toggleLikeFeedItem(FeedItem item) async {
  //   final user = _authUseCases.getUser();
  //   if (user == null) {
  //     log("User must be logged in to like items");
  //     return;
  //   }

  //   item.liked = !item.liked;
  //   if (item.liked) {
  //     item.likes++;
  //   } else {
  //     item.likes--;
  //   }

  //   log("like feed item ${item.articleUrl}");
  //   _feedRepository.saveFeedItem(item, user.uid);
  // }

  // @override
  // Future<void> viewFeedItem(FeedItem item) async {
  //   // TODO: fix this ever-increasing mess

  //   item.views += 1;
  //   log("view feed item ${item.articleUrl}");

  //   // user not required to save items
  //   _feedRepository.saveFeedItem(item, null);
  // }
}
