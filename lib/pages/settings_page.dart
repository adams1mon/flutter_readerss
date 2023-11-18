import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/bloc/feed_bloc.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/components/help_text.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/model/feed_source.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

import '../components/bottom_navbar.dart';
import 'container_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.mainFeedBloc,
    required this.personalFeedBloc,
  });

  final FeedSourcesBloc mainFeedBloc;
  final FeedSourcesBloc personalFeedBloc;

  void launchAddFeedDialog(BuildContext context, FeedSourcesBloc feedBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AddFeedSourceDialog(
              feedBloc: feedBloc,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navbarNotifier = Provider.of<ReadrssBottomNavbarNotifier>(context);

    return Scaffold(
      appBar: ReadrssAppBar(
        title: ScreenPage.settings.title,
        context: context,
      ),
      bottomNavigationBar: ReadrssBottomNavbar(
        currentIndex: navbarNotifier.pageIndex,
        onTap: navbarNotifier.changePage,
        context: context,
      ),
      // TODO: implement managing the personal feed as well
      body: Center(
        child: Column(
          children: [
            // Expanded(
            //   flex: 1,
            //   child: FeedSourcesContainer(
            //     listTitle: "Main Feed List",
            //     feedBloc: mainFeedBloc,
            //     launchAddFeedDialog: () =>
            //         launchAddFeedDialog(context, mainFeedBloc),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: FeedSourcesContainer(
                listTitle: "Personal Feed List",
                feedBloc: personalFeedBloc,
                launchAddFeedDialog: () =>
                    launchAddFeedDialog(context, personalFeedBloc),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class FeedSourcesContainer extends StatelessWidget {
  const FeedSourcesContainer({
    super.key,
    required this.listTitle,
    required this.feedBloc,
    required this.launchAddFeedDialog,
  });

  final String listTitle;
  final FeedSourcesBloc feedBloc;
  final void Function() launchAddFeedDialog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FeedSourceListTitle(
            title: listTitle,
          ),
          Expanded(
            flex: 1,
            child: FeedSourceList(
              feedBloc: feedBloc,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: launchAddFeedDialog,
                style: TextButton.styleFrom(
                  backgroundColor: colors(context).primary,
                  foregroundColor: colors(context).onPrimary,
                ),
                child: const Text("Add Feed"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddFeedSourceDialog extends StatefulWidget {
  const AddFeedSourceDialog({
    super.key,
    required this.feedBloc,
  });

  final FeedSourcesBloc feedBloc;

  @override
  State<AddFeedSourceDialog> createState() => _AddFeedSourceDialogState();
}

class _AddFeedSourceDialogState extends State<AddFeedSourceDialog> {
  final TextEditingController _textController = TextEditingController();

  var loading = false;
  String? feedSourceError;

  void setFeedSourceError(String error) {
    setState(() {
      feedSourceError = error;
      loading = false;
    });
  }

  void setLoading() {
    setState(() => loading = true);
  }

  void clearLoading() {
    setState(() => loading = false);
  }

  void addFeedSource() {
    setLoading();

    var url = _textController.text;

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

        try {
          final feed = RssFeed.parse(res.body);

          if (feed.title == null) {
            log('no title field found in the feed');
            setFeedSourceError("No 'title' field found in the feed");
            return;
          }

          var feedLink = feed.link;
          if (feed.link == null) {
            log('no link field found in the feed, using the user-given url');
            feedLink = url;
          }

          Image? feedImage;
          if (feed.image?.url?.isNotEmpty == true) {
            feedImage = Image.network(feed.image!.url!);
          }

          final feedItems = <FeedItem>[];

          if (feed.items != null) {
            feedItems.addAll(feed.items!
                .where(
                    (rssItem) => rssItem.title != null && rssItem.link != null)
                .map((rssItem) {
              // TODO: fetch views, likes and if the user liked the feed item from the backend
              return FeedItem(
                feedSourceTitle: feed.title!,
                feedSourceLink: feedLink!,
                title: rssItem.title!,
                views: 42, // TODO: fetch this
                likes: 42, // TODO: fetch this
                liked: false, // TODO: fetch this
                description: rssItem.description,
                link: rssItem.link!,
                sourceIcon: feedImage,
                pubDate: rssItem.pubDate,
              );
            }).toList());
          }

          final feedSource = FeedSource(
              title: feed.title!,
              link: feedLink!,
              image: feedImage,
              enabled: true,
              ttl: feed.ttl,
              feedItems: feedItems);

          log('adding feed source');

          widget.feedBloc.add(feedSource);

          clearLoading();
          Navigator.of(context).pop();
        } catch (e) {
          log("an error occurred while parsing the rss feed: $e");
          setFeedSourceError("Error while parsing the rss feed.");
        }
      },
      onError: (err) {
        log('an error occurred: $err');
        setFeedSourceError("An error occurred. Check the URL.");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Feed Source'),
      content: loading
          ? const Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Loading..."),
                ),
                CircularProgressIndicator.adaptive(),
              ],
            )
          : TextField(
              controller: _textController,
              decoration: InputDecoration(
                helperText: 'Paste the URL of the RSS feed',
                hintText: 'https://feeds.bbci.co.uk/news/world/rss.xml',
                errorText: feedSourceError,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: addFeedSource,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class FeedSourceListTitle extends StatelessWidget {
  const FeedSourceListTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
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
    required this.feedBloc,
    this.noItemsText =
        "It seems like there are no feed sources.\nTry to add some below!",
  });

  final FeedSourcesBloc feedBloc;
  final String noItemsText;

  void removeSource(FeedSource source) {
    feedBloc.delete(source);
  }

  void toggleSource(FeedSource source) {
    feedBloc.toggleEnabled(source);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FeedSourcesEvent>(
      stream: feedBloc.sourcesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log("error when consuming from stream, ${snapshot.error}");
          return const Text("An unknown error occurred.");
        } else if (!snapshot.hasData || snapshot.data!.feedSources.isEmpty) {
          return HelpText(text: noItemsText);
        } else {
          final sources = snapshot.data!.feedSources;

          return ListView.builder(
            itemCount: sources.length,
            itemBuilder: (context, index) {
              var source = sources[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FeedSourceListTile(
                  feedSource: source,
                  removeSource: () => removeSource(sources[index]),
                  toggleSource: () => toggleSource(sources[index]),
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

class FeedSourceListTile extends StatelessWidget {
  const FeedSourceListTile({
    super.key,
    required this.feedSource,
    required this.removeSource,
    required this.toggleSource(),
  });

  final FeedSource feedSource;

  final void Function() removeSource;
  final void Function() toggleSource;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FeedAvatar(image: feedSource.image),
      title: Text(
        feedSource.title,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete feed source"),
                      content:
                          Text("Are you sure to delete ${feedSource.title}?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          onPressed: () {
                            removeSource();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: colors(context).error),
                          ),
                        ),
                      ],
                    ),
                  )),
          Switch(
            value: feedSource.enabled,
            onChanged: (_) => toggleSource(),
          ),
        ],
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      tileColor: colors(context).primaryContainer.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
    );
  }
}
