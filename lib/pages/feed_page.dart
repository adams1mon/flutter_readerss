import 'package:flutter/material.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/styles/styles.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Feed"),
        centerTitle: true,
        actions: [
          UserAvatar(image: Image.asset("assets/avatar.jpg")),
        ],
      ),
      backgroundColor: colors(context).background,
      body: const MainContainer(),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required image, width = 40.0})
      : _image = image,
        _width = width;

  final Image _image;
  final double _width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: _width / 2,
        foregroundImage: _image.image,
      ),
    );
  }
}

class UserAvatar extends Avatar {
  const UserAvatar({super.key, required image})
      : super(image: image, width: userAvatarWidth);
}

class FeedAvatar extends Avatar {
  const FeedAvatar({super.key, required image})
      : super(image: image, width: feedAvatarWidth);
}

class MainContainer extends StatelessWidget {
  const MainContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FeedList(),
    );
  }
}

// final list = List<String>.generate(10000, (i) => 'Item $i');
final list = List<String>.generate(1, (i) => 'Item $i');

final item = FeedItem(
  feedSourceTitle: "BBC News",
  title:
      "Paris bedbugs: BBC corresopndent goes on the hunt as infestations soar",
  link: "http://google.com",
  views: 123,
  likes: 0,
);

class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return FeedCard(
          feedItem: item,
        );
      },
      padding: const EdgeInsets.all(8.0),
    );
  }
}

class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required feedItem}) : _item = feedItem;

  final FeedItem _item;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  var _expanded = false;
  var _bookmarked = false;

  void toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void toggleBookmarked() {
    setState(() {
      // does this work ???
      // TODO: call bookmarking service
      widget._item.bookmarked = !widget._item.bookmarked;

      _bookmarked = !_bookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    FeedAvatar(image: widget._item.sourceIcon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget._item.feedSourceTitle,
                        style: textTheme(context)
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: toggleBookmarked,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(_bookmarked
                            ? Icons.bookmark_outline
                            : Icons.bookmark),
                      ),
                    ),
                    GestureDetector(
                      onTap: toggleExpanded,
                      child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Icon(_expanded
                              ? Icons.expand_less
                              : Icons.expand_more)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// class MainContent extends StatelessWidget {
//   const MainContent({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return const Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [Text("hello")],
//     );
//   }
// }
