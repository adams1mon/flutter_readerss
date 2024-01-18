import 'package:flutter_readrss/repository/firestore/model/feed_item_repo_model.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_source_repo_model.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_type.dart';

class FeedItemMapper {
  static FeedItem fromRepoModel(
    FeedItemRepoModel repoModel,
    final bookmarked,
    final liked,
    final FeedType type,
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
      type: type,
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