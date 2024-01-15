import 'dart:developer';
import 'package:flutter_readrss/data/feed_repository_impl.dart';
import "package:http/http.dart" as http;
import 'package:webfeed/domain/rss_feed.dart';

class BaseException implements Exception {
  final String msg;
  final Object? cause;

  const BaseException(this.msg, [this.cause]);

  @override
  String toString() => "BaseException: $msg";
}

// user-facing exceptions
class RssFetchException extends BaseException {
  RssFetchException(String msg, [Object? cause]) : super(msg, cause);

  @override
  String toString() => "RssFetchException: $msg";
}

// internal exception
class _RssParseException extends BaseException {
  _RssParseException(String msg, [Object? cause]) : super(msg, cause);

  @override
  String toString() => "_RssParseException: $msg";
}

class RssFetcher {
  static Future<(FeedSourceModel, List<FeedItemModel>)> fetch(
    String url,
  ) async {
    log('trying to parse $url');
    var uri = Uri.tryParse(url);
    if (uri == null) {
      log('invalid url $url, uri: $uri');
      throw RssFetchException("Invalid URI");
    }

    try {
      var response = await http.get(uri);
      return _parseRssText(
        url: url,
        rssText: response.body,
      );
    } on _RssParseException catch (e) {
      log("failed to parse rss text", error: e);
      throw RssFetchException("Failed to parse RSS. Check the XML.");
    } catch (e) {
      log("failed to fetch and parse rss feed", error: e);
      throw RssFetchException("An error occurred. Check the URL.");
    }
  }

  static (FeedSourceModel, List<FeedItemModel>) _parseRssText({
    required String url,
    required String rssText,
  }) {
    log('trying to parse rss feed');

    RssFeed feed;
    try {
      feed = RssFeed.parse(rssText);
    } catch (e) {
      throw _RssParseException("Failed to parse RssFeed", e);
    }

    if (feed.title == null) {
      throw _RssParseException("No 'title' field found in the feed");
    }

    // TODO: maybe check the image url so unexpected errors are caught here
    // not on upper layers when trying to display the image
    // final feedImage = feed.image?.url?.isNotEmpty == true
    //     ? Image.network(feed.image!.url!)
    //     : null;

    // final feedItems = _createFeedItems(feed, url, feedImage);
    final feedItems = _createFeedItems(feed, url, feed.image?.url);

    return (
      FeedSourceModel(
        title: feed.title!,
        siteUrl: feed.link,
        rssUrl: url,
        iconUrl: feed.image?.url,
        ttl: feed.ttl ?? 10,
      ),
      feedItems
    );
  }

  static List<FeedItemModel> _createFeedItems(
    RssFeed feed,
    String rssUrl,
    // Image? feedSourceImage,
    String? feedSourceImageUrl,
  ) {
    final feedItems = <FeedItemModel>[];

    if (feed.items == null) {
      return feedItems;
    }

    feedItems.addAll(feed.items!
        .where((rssItem) => rssItem.title != null && rssItem.link != null)
        .map(
      (rssItem) {
        // TODO: fetch views, likes and if the user liked the feed item from the backend

        return FeedItemModel(
          feedSourceTitle: feed.title!,
          feedSourceRssUrl: rssUrl,
          title: rssItem.title!,
          views: 0, // TODO: fetch this - use another model which doesn't have these values
          likes: 0, // TODO: fetch this
          description: rssItem.description,
          articleUrl: rssItem.link!,
          sourceIconUrl: feedSourceImageUrl,
          pubDate: rssItem.pubDate,
        );
      },
    ));

    return feedItems;
  }
}
