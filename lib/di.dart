import 'package:flutter_readrss/data/feed_repository.dart';
import 'package:flutter_readrss/presentation/presenter/impl/bookmark_feed_provider.dart';
import 'package:flutter_readrss/presentation/presenter/impl/feed_connector.dart';
import 'package:flutter_readrss/presentation/presenter/impl/feed_presenter_impl.dart';
import 'package:flutter_readrss/use_case/impl/feed_use_cases_impl.dart';

// manual dependency injection here :)

final repository = FeedRepositoryImpl();

final mainFeedProvider = FeedConnector();
final personalFeedProvider = FeedConnector();
final bookmarksFeedProvider = BookmarkFeedProviderImpl(
  feedProviders: [mainFeedProvider, personalFeedProvider],
);

final presenter = FeedPresenterImpl(
  mainFeedProvider: mainFeedProvider,
  personalFeedProvider: personalFeedProvider,
);

final useCases = FeedUseCasesImpl(
  feedPresenter: presenter,
  feedRepository: repository,
);