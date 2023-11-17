
import 'dart:async';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/model/feed_source.dart';


class FeedItemListEvent {
  const FeedItemListEvent({required this.feedItems});
  final List<FeedItem> feedItems;
}

class FeedItemsBloc {

  // internal state which gets published on every change
  final _feedItems = <FeedItem>[];

  // we could also listen to the stream and update the internal state 
  // after the changes have been published
  // we need the internal state to perform operations on it (e.g. filtering, sorting)
  // and then publish it 

  final _feedItemsStreamController = StreamController<FeedItemListEvent>(
    onListen: () {},
    onCancel: () {},
    onPause: () {},
    onResume: () {},
  );

  Stream<FeedItemListEvent> get stream => _feedItemsStreamController.stream;

  void add(List<FeedItem> feedItems) {
    _feedItems.addAll(feedItems);
    
    // sort by publish date by default
    _publish(_sortByPublishDate(_feedItems));
  }

  void replaceWith(List<FeedItem> feedItems) {
    _feedItems.clear();
    _feedItems.addAll(feedItems);
    _publish(_sortByPublishDate(_feedItems));
  }
  
  // TODO: take into consideration every source when filtering, not just the last one :))
  // currently only one source is filtered out
  // for this to work properly, we should have access to a state of sources 
  // (make that also a bloc? have a single bloc?)
  void filterSource(FeedSource source) {
    final filtered = List.of(_feedItems)
      ..removeWhere((item) => item.feedSourceLink == source.link && !source.enabled);

    _publish(_sortByPublishDate(filtered));
  }

  void removeSource(FeedSource source) {
    _feedItems.removeWhere((item) => item.feedSourceLink == source.link);
    _publish(_sortByPublishDate(_feedItems));
  }

  List<FeedItem> _sortByPublishDate(List<FeedItem> feedItems) {
    return List.of(feedItems)
      ..sort((a, b) {
        if (a.pubDate == null) {
          // put 'a' to the end of the list
          return 1;
        } else if (b.pubDate == null) {
          // put 'b' to the end of the list
          return -1;
        } else {
          // descending order
          return -a.pubDate!.compareTo(b.pubDate!);
        }
      }
    );
  }

  void _publish(List<FeedItem> feedItems) {
    _feedItemsStreamController.sink.add(FeedItemListEvent(feedItems: feedItems));
  }

  // TODO: where do we call this ?
  dispose() {
    _feedItemsStreamController.close();
  }
}

final mainFeedBloc = FeedItemsBloc();
final personalFeedBloc = FeedItemsBloc();
final bookmarkFeedBloc = FeedItemsBloc();