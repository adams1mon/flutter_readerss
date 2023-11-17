import 'package:flutter/material.dart';
import 'package:flutter_readrss/bloc/feed_items_bloc.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/pages/feed_page.dart';
import 'package:flutter_readrss/pages/settings_page.dart';
import 'package:provider/provider.dart';

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

class ContainerPage extends StatelessWidget {
  const ContainerPage({super.key});

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
              feedItemsBloc: mainFeedBloc,
            ),
            FeedPage(
              title: ScreenPage.personalFeed.title,
              feedItemsBloc: personalFeedBloc,
            ),
            FeedPage(
              title: ScreenPage.bookmarks.title,
              feedItemsBloc: bookmarkFeedBloc,
            ),
            SettingsPage(
              mainFeedBloc: mainFeedBloc,
              personalFeedBloc: personalFeedBloc,
            ),
          ],
        ),
      ),
    );
  }
}
