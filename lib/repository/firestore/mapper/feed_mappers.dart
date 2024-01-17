
import 'package:flutter_readrss/repository/firestore/model/feed_item_repo_model.dart';
import 'package:flutter_readrss/repository/firestore/model/feed_source_repo_model.dart';
import 'package:flutter_readrss/repository/network/feed_item_network_model.dart';
import 'package:flutter_readrss/repository/network/model/feed_source_network_model.dart';

class RepoFeedSourceMapper {
  static FeedSourceRepoModel fromNetworkModel(
      FeedSourceNetworkModel networkModel) {
    return FeedSourceRepoModel(
        title: networkModel.title,
        rssUrl: networkModel.rssUrl,
        siteUrl: networkModel.siteUrl,
        iconUrl: networkModel.iconUrl,
        ttl: networkModel.ttl);
  }
}

class RepoFeedItemMapper {
  static FeedItemRepoModel fromNetworkModel(
    FeedItemNetworkModel itemNetworkModel,
    FeedSourceNetworkModel sourceNetworkModel,
    int views,
    int likes,
  ) {
    return FeedItemRepoModel(
      feedSourceTitle: sourceNetworkModel.title,
      feedSourceRssUrl: sourceNetworkModel.rssUrl,
      title: itemNetworkModel.title,
      description: itemNetworkModel.description,
      articleUrl: itemNetworkModel.articleUrl,
      sourceIconUrl: sourceNetworkModel.iconUrl,
      pubDate: itemNetworkModel.pubDate,
      views: views,
      likes: likes,
    );
  }
}