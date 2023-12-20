import 'dart:developer';

import 'package:flutter_readrss/use_case/const/main_rss_feeds.dart';
import 'package:flutter_readrss/data/rss_fetcher.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:flutter_readrss/use_case/model/feed_source.dart';
import 'package:flutter_readrss/use_case/model/feed_source_type.dart';

// void initMainFeed() async {
//   for (final url in mainFeedRssUrls) {
//     try {
//       final feedSource = await RssFetcher.fetch(url, FeedSourceType.predefined);
//       // mainFeedBloc.add(feedSource);
//     } on RssFetchException catch (e) {
//       log(
//         "error while populating default main feed with rss from url: $url",
//         error: e,
//       );
//     } catch (e) {
//       log(
//         "unknown error while populating main feed with rss from url: $url",
//         error: e,
//       );
//     }
//   }
// }

// void initMainFeedWithMocks() async {
//   // TODO: see why feed is not loading if there is no delay when sending into the sink
//   await Future.delayed(const Duration(milliseconds: 500));

//   final items = List<FeedItem>.generate(
//     100,
//     (i) => FeedItem(
//       feedSourceTitle: "BBC News",
//       title:
//           "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar there is a big pandemic going on here manan",
//       // articleUrl: "https://sfsdf.com",
//       // articleUrl: "::uri.parse fails::",
//       articleUrl: "uri.parse doesn not fail but url is invalid",
//       // articleUrl: "file://sdfs.com",
//       feedSourceRssUrl: "http://sdfs.com",
//       views: 123,
//       likes: 0,
//       description: "some random description here, lorem ipsum dolor sit amet",
//       pubDate: DateTime.now(),
//     ),
//   );

//   final source = FeedSource(
//     title: "mock",
//     rssUrl: "rssurl",
//     type: FeedSourceType.predefined,
//     feedItems: items,
//   );
//   // mainFeedBloc.add(source);
// }
