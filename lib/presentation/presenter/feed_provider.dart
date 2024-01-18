import 'package:flutter_readrss/presentation/presenter/feed_events.dart';

// called by the ui
abstract class FeedSourceProvider {
  Stream<FeedSourcesEvent> getFeedSourcesStream();
  void dispose();
}

abstract class FeedItemsProvider {
  Stream<FeedItemsEvent> getFeedItemsStream();
  void dispose();
}