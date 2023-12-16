import 'package:flutter/material.dart';
import 'package:flutter_readrss/data/feed_repository.dart';
import 'package:flutter_readrss/presentation/ui/pages/feed_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/settings_page.dart';
import 'package:flutter_readrss/presentation/presenter/feed_presenter.dart';
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

// TODO: do this wiring elsewhere
final repository = FeedRepositoryImpl();

final mainFeedProvider = FeedProviderImpl();
final personalFeedProvider = FeedProviderImpl();
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

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  @override
  void initState() {
    super.initState();
    // TODO: finish testing this -> should be 
    // initMainFeedWithMocks();
    useCases.loadPredefinedFeedsByUrls(mainFeedRssUrls);
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
              toggleBookmark: useCases.bookmarkToggleFeedItem,
            ),
            FeedPage(
              title: ScreenPage.personalFeed.title,
              feedItemsStream: personalFeedProvider.getFeedItemsStream(),
              toggleBookmark: useCases.bookmarkToggleFeedItem,
            ),
            FeedPage(
              title: ScreenPage.bookmarks.title,
              feedItemsStream: bookmarksFeedProvider.getFeedItemsStream(),
              toggleBookmark: useCases.bookmarkToggleFeedItem,
              noItemsText: "Your bookmarked feed items will appear here.",
            ),
            SettingsPage(
              feedSourcesStream: personalFeedProvider.getFeedSourcesStream(),
              loadFeedByUrl: useCases.loadPersonalFeedSourceByUrl,
              deleteFeedSource: useCases.deleteFeedSource,
              toggleFeedSource: useCases.toggleFeedSource,
            ),
          ],
        ),
      ),
    );
  }
}
