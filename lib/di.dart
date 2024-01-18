import 'package:flutter_readrss/repository/firestore/impl/feed_repository_impl.dart';
import 'package:flutter_readrss/repository/firestore/impl/user_repository_impl.dart';
import 'package:flutter_readrss/presentation/presenter/impl/bookmark_feed_connector.dart';
import 'package:flutter_readrss/presentation/presenter/impl/feed_connector.dart';
import 'package:flutter_readrss/presentation/presenter/impl/feed_presenter_impl.dart';
import 'package:flutter_readrss/use_case/auth/impl/auth_use_cases_impl.dart';
import 'package:flutter_readrss/use_case/feeds/impl/feed_use_cases_impl.dart';

// manual dependency injection here :)

final feedRepository = FeedRepositoryImpl();
final userReopsitory = UserRepositoryImpl();

final mainFeedConnector = FeedConnector();
final personalFeedConnector = FeedConnector();
final bookmarksFeedItemsConnector = BookmarkFeedItemsConnector();

final presenter = FeedPresenterImpl(
  mainFeedItemsSink: mainFeedConnector,
  personalFeedSourceSink: personalFeedConnector,
  personalFeedItemsSink: personalFeedConnector,
  bookmarkFeedItemsSink: bookmarksFeedItemsConnector,
);

final authUseCases = AuthUseCasesImpl(
  userRepository: userReopsitory,
  feedPresenter: presenter,
);

final feedUseCases = FeedUseCasesImpl(
  feedPresenter: presenter,
  feedRepository: feedRepository,
  authUseCases: authUseCases,
);

void globalCleanup() {
  mainFeedConnector.dispose();
  personalFeedConnector.dispose();
  bookmarksFeedItemsConnector.dispose();
}
