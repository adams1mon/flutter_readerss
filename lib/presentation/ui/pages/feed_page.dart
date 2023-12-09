import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/components/app_bar.dart';
import 'package:flutter_readrss/presentation/ui/components/bottom_navbar.dart';
import 'package:flutter_readrss/presentation/ui/components/feed_card.dart';
import 'package:flutter_readrss/presentation/ui/components/help_text.dart';
import 'package:flutter_readrss/presentation/ui/pages/container_page.dart';
import 'package:flutter_readrss/presentation/ui/presenter/feed_presenter.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:flutter_readrss/use_case/model/feed_item.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.title,
    required this.feedItemsStream,
    // required this.personalFeedUseCases,
    required this.toggleBookmark,
    
    // required this.bookmarksBloc,
    this.noItemsText = "It seems like there are no feeds.\nTry to add some or enable them on the settings page!",
  });

  final String title;
  final Stream<FeedItemsEvent> feedItemsStream;
  // final FeedProvider bookmarksBloc;
  // final PersonalFeedUseCases personalFeedUseCases;
  final String noItemsText;

  final void Function(FeedItem) toggleBookmark;

  @override
  Widget build(BuildContext context) {
    final navbarNotifier = Provider.of<ReadrssBottomNavbarNotifier>(context);

    return Scaffold(
      appBar: ReadrssAppBar(
        title: title,
        context: context,
      ),
      bottomNavigationBar: ReadrssBottomNavbar(
        currentIndex: navbarNotifier.pageIndex,
        onTap: navbarNotifier.changePage,
        context: context,
      ),
      backgroundColor: colors(context).background,
      body: Center(
        child: FeedList(
          feedItemStream: feedItemsStream,
          // bookmarksBloc: bookmarksBloc,
          // personalFeedUseCases: personalFeedUseCases,
          noItemsText: noItemsText,
          toggleBookmark: toggleBookmark,
        ),
      ),
    );
  }
}

class FeedList extends StatelessWidget {
  const FeedList({
    super.key,
    required this.feedItemStream,
    // required this.bookmarksBloc,

    // required this.personalFeedUseCases,

    required this.noItemsText,
    required this.toggleBookmark,
  });

  final Stream<FeedItemsEvent> feedItemStream;
  // final FeedProvider bookmarksBloc;

  // final PersonalFeedUseCases personalFeedUseCases;

  final String noItemsText;

  final void Function(FeedItem) toggleBookmark;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FeedItemsEvent>(
      stream: feedItemStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log("error when consuming from stream, ${snapshot.error}");
          return const Text("An unknown error occurred.");
        } else if (!snapshot.hasData || snapshot.data!.feedItems.isEmpty) {
          return HelpText(text: noItemsText);
        } else {
          final items = snapshot.data!.feedItems;
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: FeedCard(
                  feedItem: items[index],
                  toggleBookmarked: () =>
                      // bookmarksBloc.toggleBookmarked(items[index]),
                      // personalFeedUseCases.bookmarkToggleFeedItem(items[index])
                      toggleBookmark(items[index])
                ),
              );
            },
            padding: const EdgeInsets.all(8.0),
          );
        }
      },
    );
  }
}
