import 'dart:async';
import 'dart:developer';

import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/bloc/feed_items_bloc.dart';

class BookmarksBloc {
  final _itemsBloc = FeedItemsBloc();

  Stream<FeedItemsEvent> get itemsStream => _itemsBloc.itemsStream;

  void toggleBookmarked(FeedItem item) {
    item.bookmarked = !item.bookmarked;
    Timer(Duration(seconds: 5), () {
      log('Test 1');
    });
    if (item.bookmarked) {
      _itemsBloc.add(item);
    } else {
      _itemsBloc.delete(item);
    }
  }

  // TODO: where do we call this ?
  dispose() {
    _itemsBloc.dispose();
  }
}
