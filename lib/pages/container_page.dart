import 'package:flutter/material.dart';
import 'package:flutter_readrss/bloc/feed_bloc.dart';
import 'package:flutter_readrss/bloc/main_feed_init.dart';
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

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {

  @override
  void initState() {
    super.initState();
    initMainFeed();
  }

  @override
  void dispose() {
    super.dispose();
    mainFeedBloc.dispose();
    personalFeedBloc.dispose();
    bookmarksBloc.dispose();
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
              feedItemsStream: mainFeedBloc.itemsStream,
              bookmarksBloc: bookmarksBloc,
            ),
            FeedPage(
              title: ScreenPage.personalFeed.title,
              feedItemsStream: personalFeedBloc.itemsStream,
              bookmarksBloc: bookmarksBloc,
            ),
            FeedPage(
              title: ScreenPage.bookmarks.title,
              feedItemsStream: bookmarksBloc.itemsStream,
              bookmarksBloc: bookmarksBloc,
              noItemsText: "Your bookmarked feed items will appear here.",
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
