import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/bloc/feed_bloc.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/bottom_navbar.dart';
import 'package:flutter_readrss/components/feed_card.dart';
import 'package:flutter_readrss/pages/container_page.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.title,
    required this.feedItemsStream,
    required this.bookmarksBloc,
  });

  final String title;
  // final FeedItemsBloc feedItemsBloc;
  final Stream<FeedItemsEvent> feedItemsStream;

  final BookmarksBloc bookmarksBloc;

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
          bookmarksBloc: bookmarksBloc,
        ),
      ),
    );
  }
}

// final items = List<FeedItem>.generate(
//     1000,
//     (i) => FeedItem(
//           feedSourceTitle: "BBC News",
//           title:
//               // "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar",
//               "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar there is a big pandemic going on here manan",
//           link: "http://google.com",
//           views: 123,
//           likes: 0,
//           description:
//               "some random description here, lorem ipsum dolor sit amet",
//           pubDate: DateTime.now(),
//         ));

class FeedList extends StatelessWidget {
  const FeedList({
    super.key,
    required this.feedItemStream,
    required this.bookmarksBloc,
  });

  final Stream<FeedItemsEvent> feedItemStream;
  final BookmarksBloc bookmarksBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FeedItemsEvent>(
      stream: feedItemStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log("error when consuming from stream, ${snapshot.error}");
          return const Text("An unknown error occurred.");
        } else if (!snapshot.hasData) {
          return Text(
            "It seems like there are no feeds.\nTry to add some on the settings page!",
            style: textTheme(context).bodyLarge,
            textAlign: TextAlign.center,
          );
        } else {
          final items = snapshot.data!.feedItems;
          if (items.isEmpty) {
            return Text(
              "There are no feed items to show at the moment.",
              style: textTheme(context).bodyLarge,
              textAlign: TextAlign.center,
            );
          }
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: FeedCard(
                  feedItem: items[index],
                  toggleBookmarked: () =>
                      bookmarksBloc.toggleBookmarked(items[index]),
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
