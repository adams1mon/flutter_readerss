
import 'package:flutter_readrss/model/feed_source.dart';

Future<FeedSource> parseRss(String rssSource) {
  return Future.value(FeedSource(title: "a", link: "b", image: "image"));
}