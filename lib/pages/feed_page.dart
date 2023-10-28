import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/components/feed_card.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/styles/styles.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReadrssAppBar(
        title: "Main Feed",
        userAvatar: UserAvatar(
          image: Image.asset("assets/avatar.jpg"),
        ),
      ),
      backgroundColor: colors(context).background,
      body: const MainContainer(),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FeedList(),
    );
  }
}

// final list = List<String>.generate(10000, (i) => 'Item $i');
final items = List<FeedItem>.generate(
    1000,
    (i) => FeedItem(
          feedSourceTitle: "BBC News",
          title:
              // "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar",
              "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar there is a big pandemic going on here manan",
          link: "http://google.com",
          views: 123,
          likes: 0,
          description:
              "some random description here, lorem ipsum dolor sit amet",
        ));

class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: FeedCard(
            feedItem: items[index],
          ),
        );
      },
      padding: const EdgeInsets.all(8.0),
    );
  }
}
