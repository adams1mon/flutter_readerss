import 'package:flutter/material.dart';
import 'package:flutter_readrss/di.dart';
import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/ui/pages/feed_page.dart';
import 'package:flutter_readrss/presentation/ui/pages/settings_page.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:provider/provider.dart';

import '../const/screen_page.dart';

class ReadrssBottomNavbarNotifier extends ChangeNotifier {
  // private state
  var _pageIndex = 0;

  void changePage(index) {
    _pageIndex = index;
    notifyListeners();
  }

  // read-only state
  int get pageIndex => _pageIndex;
}


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
    feedUseCases.loadPredefinedFeeds();
    feedUseCases.loadPersonalFeeds();
    feedUseCases.loadBookmarkedFeedItems();
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
              feedItemsStream: mainFeedConnector.getFeedItemsStream(),
              toggleBookmark: feedUseCases.toggleBookmarkFeedItem,
              toggleLike: feedUseCases.toggleLikeFeedItem,
              increaseViewCount: feedUseCases.viewFeedItem,
              isLoggedIn: () => authUseCases.getUser() != null,
            ),
            FeedPage(
              title: ScreenPage.personalFeed.title,
              feedItemsStream: personalFeedConnector.getFeedItemsStream(),
              toggleBookmark: feedUseCases.toggleBookmarkFeedItem,
              toggleLike: feedUseCases.toggleLikeFeedItem,
              increaseViewCount: feedUseCases.viewFeedItem,
              isLoggedIn: () => authUseCases.getUser() != null,
            ),
            FeedPage(
              title: ScreenPage.bookmarks.title,
              feedItemsStream: bookmarksFeedItemsConnector.getFeedItemsStream(),
              toggleBookmark: feedUseCases.toggleBookmarkFeedItem,
              toggleLike: feedUseCases.toggleLikeFeedItem,
              increaseViewCount: feedUseCases.viewFeedItem,
              isLoggedIn: () => authUseCases.getUser() != null,
              initialData: const FeedItemsEvent(feedItems: []),
              noItemsText: "Your bookmarked feed items will appear here.",
            ),
            SettingsPage(
              feedSourcesStream: personalFeedConnector.getFeedSourcesStream(),
              loadFeedByUrl: feedUseCases.addPersonalFeedSourceByUrl,
              deleteFeedSource: feedUseCases.deleteFeedSource,
              toggleFeedSource: feedUseCases.toggleFeedSource,
            ),
          ],
        ),
      ),
    );
  }
}
