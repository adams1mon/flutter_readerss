import 'package:flutter/material.dart';
import 'package:flutter_readrss/data/feed_repository.dart';
import 'package:flutter_readrss/presentation/state/bloc/init_main_feed.dart';
import 'package:flutter_readrss/presentation/ui/pages/feed_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/settings_page.dart';
import 'package:flutter_readrss/presentation/ui/presenter/feed_presenter.dart';
import 'package:flutter_readrss/use_case/const/main_rss_feeds.dart';
import 'package:flutter_readrss/use_case/feeds.dart';
import 'package:provider/provider.dart';

import '../const/screen_page.dart';

class ReadrssBottomNavbarNotifier extends ChangeNotifier {
  // private state
  var _pageIndex = 0;

  // callback which notifies consumers about changing the page
  void changePage(index) {
    _pageIndex = index;
    notifyListeners();
  }

  // read-only state
  int get pageIndex => _pageIndex;
}

// TODO: include the type of feed in the domain model (default feed, personal feed)
// based on this we can filter them only in the ui layer
final repository = FeedRepositoryImpl();
final mainFeedPresenter = FeedPresenterImpl();
final personalFeedPresenter = FeedPresenterImpl();

// TODO: do this elsewhere
final baseFeedUseCases = BaseFeedUseCasesImpl(
  feedPresenter: mainFeedPresenter, 
  feedRepository: repository,
);

final personalFeedUseCases = PersonalFeedUseCasesImpl(
  feedPresenter: personalFeedPresenter,
  feedRepository: repository,
);

final mainFeedProvider = FeedProviderImpl(feedPresenter: mainFeedPresenter);
final personalFeedProvider = FeedProviderImpl(feedPresenter: personalFeedPresenter);
final bookmarksFeedProvider = BookmarkFeedProviderImpl(feedProviders: [mainFeedProvider, personalFeedProvider]);

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {

  @override
  void initState() {
    super.initState();
    // initMainFeed();
    // TODO: finish testing this
    // initMainFeedWithMocks();
    baseFeedUseCases.loadFeedSourcesByUrls(mainFeedRssUrls);
  }

  @override
  void dispose() {
    super.dispose();
    mainFeedProvider.dispose();
    personalFeedProvider.dispose();
    bookmarksFeedProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReadrssBottomNavbarNotifier(),
      child: Consumer<ReadrssBottomNavbarNotifier>(
        builder: (context, navbarNotifier, child) => IndexedStack(
          index: navbarNotifier.pageIndex,
          children: [
            FeedPage(
              title: ScreenPage.mainFeed.title,
              feedItemsStream: mainFeedProvider.getFeedItemsStream(),
              // bookmarksBloc: bookmarksBloc,
              toggleBookmark: baseFeedUseCases.bookmarkToggleFeedItem,
            ),
            FeedPage(
              title: ScreenPage.personalFeed.title,
              feedItemsStream: personalFeedProvider.getFeedItemsStream(),
              // bookmarksBloc: bookmarksFeedProvider,
              toggleBookmark: personalFeedUseCases.bookmarkToggleFeedItem,
            ),
            FeedPage(
              title: ScreenPage.bookmarks.title,
              feedItemsStream: bookmarksFeedProvider.getFeedItemsStream(),
              // bookmarksBloc: bookmarksFeedProvider,
              toggleBookmark: baseFeedUseCases.bookmarkToggleFeedItem,
              noItemsText: "Your bookmarked feed items will appear here.",
            ),
            SettingsPage(
              // mainFeedBloc: mainFeedProvider,
              // personalFeedBloc: personalFeedProvider,
              feedSourcesStream: personalFeedProvider.getFeedSourcesStream(),
              loadFeedSourceByUrl: personalFeedUseCases.loadFeedSourceByUrl,
              deleteFeedSource: personalFeedUseCases.deleteFeedSource,
              toggleFeedSource: personalFeedUseCases.toggleFeedSource,
            ),
          ],
        ),
      ),
    );
  }
}
