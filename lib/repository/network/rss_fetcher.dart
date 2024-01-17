import 'dart:developer';
import 'package:flutter_readrss/repository/network/feed_item_network_model.dart';
import 'package:flutter_readrss/repository/network/model/feed_source_network_model.dart';
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
  static Future<(FeedSourceNetworkModel, List<FeedItemNetworkModel>)> fetch(
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

  static (FeedSourceNetworkModel, List<FeedItemNetworkModel>) _parseRssText({
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

    final feedItems = _createFeedItems(feed);

    return (
      FeedSourceNetworkModel(
        title: feed.title!,
        rssUrl: url,
        siteUrl: feed.link,
        iconUrl: feed.image?.url,
        ttl: feed.ttl ?? 10,
      ),
      feedItems,
    );
  }

  static List<FeedItemNetworkModel> _createFeedItems(RssFeed feed) {
    final feedItems = <FeedItemNetworkModel>[];

    if (feed.items == null) {
      return feedItems;
    }

    feedItems.addAll(feed.items!
        .where((rssItem) => rssItem.title != null && rssItem.link != null)
        .map(
      (rssItem) {
        return FeedItemNetworkModel(
          title: rssItem.title!,
          description: rssItem.description,
          articleUrl: rssItem.link!,
          pubDate: rssItem.pubDate,
        );
      },
    ));
    return feedItems;
  }
}
