
import 'package:flutter_readrss/use_case/feeds/model/feed_type.dart';

class FeedSource {
  final String id;
  final String title;
  final String rssUrl;
  final String? siteUrl;
  bool enabled;
  FeedType type;

  final String? iconUrl;
  final int ttl;

  FeedSource({
    required this.id,
    required this.title,
    required this.rssUrl,
    required this.type,
    required this.siteUrl,
    required this.enabled,
    required this.iconUrl,
    
    required this.ttl,
  }); 
}