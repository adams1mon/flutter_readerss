import 'package:flutter/material.dart';
import 'package:flutter_readrss/model/feed_source.dart';

class FeedSourceNotifier extends ChangeNotifier {
  final _sources = <FeedSource>{};

  List<FeedSource> getSources() {
    return List.unmodifiable(_sources);
  }

  void addSource(FeedSource source) {
    // check that there are no sources
    // (the set doesn't work properly because of the 'image' property is always new?)
    if (!_sources.any((element) => element.equals(source))) {
      _sources.add(source);
      notifyListeners();
    }
  }

  void removeSource(FeedSource source) {
    _sources.remove(source);
    notifyListeners();
  }
}