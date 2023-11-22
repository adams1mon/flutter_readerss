import 'package:flutter_readrss/bloc/feed_sources_bloc.dart';
import 'package:flutter_readrss/bloc/bookmarks_bloc.dart';

// TODO: initialize these where they are disposable (InheritedWidget maybe ?)
// (does the global scope get collected correctly, or do we leak memory here??)
final mainFeedBloc = FeedSourcesBloc();
final personalFeedBloc = FeedSourcesBloc();
final bookmarksBloc = BookmarksBloc();
