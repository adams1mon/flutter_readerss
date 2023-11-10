import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/model/feed_source.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

import '../components/bottom_navbar.dart';
import 'container_page.dart';

class FeedSourceListNotifier extends ChangeNotifier {
  final _sources = <FeedSource>[];

  get sources => List.unmodifiable(_sources);

  void addSource(FeedSource source) {
    _sources.add(source);
    notifyListeners();
  }

  void removeSource(int index) {
    if (index < 0 && index >= _sources.length) {
      return;
    }
    _sources.removeAt(index);
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final navbarNotifier = Provider.of<ReadrssBottomNavbarNotifier>(context);

    return ChangeNotifierProvider(
      create: (_) => FeedSourceListNotifier(),
      child: Consumer<FeedSourceListNotifier>(
        builder: (consumerContext, feedSourceList, child) => Scaffold(
          appBar: ReadrssAppBar(
            title: ScreenPage.settings.title,
            context: consumerContext,
          ),
          bottomNavigationBar: ReadrssBottomNavbar(
            currentIndex: navbarNotifier.pageIndex,
            onTap: navbarNotifier.changePage,
            context: consumerContext,
          ),
          body: const Column(
            children: <Widget>[
              FeedSourceListTitle(),
              Expanded(
                child: FeedSourceList(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: consumerContext,
                builder: (BuildContext context) {
                  return Center(
                    child: SingleChildScrollView(
                      child: AddFeedSourceDialog(
                          feedSourceNotifier:
                              Provider.of<FeedSourceListNotifier>(
                                  consumerContext)),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class AddFeedSourceDialog extends StatefulWidget {
  const AddFeedSourceDialog({
    super.key,
    required this.feedSourceNotifier,
  });

  final FeedSourceListNotifier feedSourceNotifier;

  @override
  State<AddFeedSourceDialog> createState() => _AddFeedSourceDialogState();
}

class _AddFeedSourceDialogState extends State<AddFeedSourceDialog> {
  final TextEditingController _textController = TextEditingController();

  // var loading = false;
  String? feedSourceError;

  void clearFeedSourceError() {
    setState(() => feedSourceError = null);
  }

  void setFeedSourceError(String error) {
    setState(() {
      feedSourceError = error;
      // loading = true;
    });
  }

  // void setLoading() {
  //   setState(() => loading = true);
  // }

  // void clearLoading() {
  //   setState(() => loading = false);
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Feed Source'),
      content:
          // loading
          // ?
          // const Column(
          //     children: [
          //       Text("Loading..."),
          //       CircularProgressIndicator.adaptive(),
          //     ],
          //   )
          // :
          TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'Paste the URL of the feed: ',
          errorText: feedSourceError,
        ),
      ),
      // content: FutureBuilder(
      //   future: Future<void>(() {}),
      //   builder: (context, snapshot) => {
      //     if (snapshot.)
      // },),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            // setLoading();

            // TODO: check if feed url is valid
            var url = _textController.text;
            // var feedSource = FeedSource(title: "blah", link: url);
            // widget.feedSourceNotifier.addSource(feedSource);

            log('trying to parse $url');

            var uri = Uri.tryParse(url);
            if (uri == null) {
              log('invalid url $url, uri: $uri');
              setFeedSourceError("Invalid URI");
              return;
            }

            http.get(uri).then(
              (res) {
                log('trying to parse rss feed');
                final feed = RssFeed.parse(res.body);

                if (feed.title == null) {
                  log('to title field found in the feed');
                  setFeedSourceError("No 'title' field found in the feed");
                  return;
                }
                final feedSource = FeedSource(link: url, title: feed.title!);
                widget.feedSourceNotifier.addSource(feedSource);

                // TODO: add the feed items too

                // clearLoading();
                Navigator.of(context).pop();
              },
              onError: (err) {
                log('an error occurred: $err');
                setFeedSourceError("An unknown error occurred");
              },
            );
          },
        ),
      ],
    );
  }
}

class FeedSourceListTitle extends StatelessWidget {
  const FeedSourceListTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Feed List',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FeedSourceList extends StatelessWidget {
  const FeedSourceList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var feedSourceNotifier = Provider.of<FeedSourceListNotifier>(context);

    if (feedSourceNotifier.sources.length == 0) {
      return Center(
        child: Text(
          "It seems like there are no feeds. Try to add some!",
          style: textTheme(context).bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: feedSourceNotifier.sources.length,
      itemBuilder: (context, index) {
        var item = feedSourceNotifier.sources[index];
        return FeedSourceListTile(
          feedSource: item,
          removeItem: () => feedSourceNotifier.removeSource(index),
        );
      },
    );
  }
}

class FeedSourceListTile extends StatelessWidget {
  const FeedSourceListTile({
    super.key,
    required this.feedSource,
    required this.removeItem,
  });

  final FeedSource feedSource;
  final void Function() removeItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: FeedAvatar(image: feedSource.image),
        title: Text(feedSource.title),
        trailing: Row(
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: removeItem,
            ),
            Switch(
                value: feedSource.enabled,
                onChanged: (_) => feedSource.toggleEnabled()),
          ],
        ));
  }
}
