import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/model/feed_item.dart';

class FeedItemsNotifier extends ChangeNotifier {
  final _items = <FeedItem>{};

  // TODO: sort items by pubdate
  List<FeedItem> getItems() {
    return List.unmodifiable(_items);
  }

  void addItem(FeedItem item) {
    _items.add(item);
    notifyListeners();
  }
  
  void addItems(List<FeedItem> items) {
    _items.addAll(items);
    log("items: $_items");
    notifyListeners();
  }

}