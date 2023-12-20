import 'package:flutter_readrss/presentation/presenter/feed_events.dart';

// called by the ui
abstract class FeedProvider {
  Stream<FeedSourcesEvent> getFeedSourcesStream();
  Stream<FeedItemsEvent> getFeedItemsStream();
  void dispose();
}