import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/bloc/feed_items_bloc.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/model/feed_source.dart';
import 'package:flutter_readrss/styles/styles.dart';
import 'package:flutter_readrss/viewmodels/feed_source_notifier.dart';
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

  final FeedItemsBloc mainFeedBloc;
  final FeedItemsBloc personalFeedBloc;

  @override
  Widget build(BuildContext context) {
    final navbarNotifier = Provider.of<ReadrssBottomNavbarNotifier>(context);

    return ChangeNotifierProvider(
      create: (_) => FeedSourceNotifier(),
      child: Consumer<FeedSourceNotifier>(
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
          // TODO: implement managing the personal feed as well
          body: Column(
            children: <Widget>[
              const FeedSourceListTitle(
                title: 'Main Feed List'
              ),
              Expanded(
                child: FeedSourceList(
                  feedItemsBloc: mainFeedBloc,
                ),
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
                            Provider.of<FeedSourceNotifier>(consumerContext),
                        feedItemsBloc: mainFeedBloc,
                      ),
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
    required this.feedItemsBloc,
  });

  final FeedSourceNotifier feedSourceNotifier;
  final FeedItemsBloc feedItemsBloc;

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

          Image? feedImage;
          if (feed.image?.url?.isNotEmpty == true) {
            feedImage = Image.network(feed.image!.url!);
          }

          final feedSource =
              FeedSource(link: url, title: feed.title!, image: feedImage);

          log('adding feed source');
          widget.feedSourceNotifier.addSource(feedSource);

          if (feed.items != null) {
            final feedItems = feed.items!
                .where(
                    (rssItem) => rssItem.title != null && rssItem.link != null)
                .map((rssItem) {
              // TODO: fetch views, likes and if the user liked the feed item from the backend
              return FeedItem(
                feedSourceTitle: feedSource.title,
                feedSourceLink: feedSource.link,
                title: rssItem.title!,
                views: 42, // TODO: fetch this
                likes: 42, // TODO: fetch this
                liked: false, // TODO: fetch this
                description: rssItem.description,
                link: rssItem.link!,
                sourceIcon: feedSource.image,
                pubDate: rssItem.pubDate,
              );
            }).toList();

            widget.feedItemsBloc.add(feedItems);
          }

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
          onPressed: () {
            Navigator.of(context).pop();
          },
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
  const FeedSourceList({super.key, required this.feedItemsBloc});

  final FeedItemsBloc feedItemsBloc;

  @override
  Widget build(BuildContext context) {
    var feedSourceNotifier = Provider.of<FeedSourceNotifier>(context);
    var feedSources = feedSourceNotifier.getSources();

    if (feedSources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "It seems like there are no feeds.\nTry to add some below!",
            style: textTheme(context).bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: feedSources.length,
      itemBuilder: (context, index) {
        var source = feedSources[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FeedSourceListTile(
              feedSource: source,
              feedSourceNotifier: feedSourceNotifier,
              feedItemsBloc: feedItemsBloc,
          ),
        );
      },
      padding: const EdgeInsets.all(8.0),
    );
  }
}

class FeedSourceListTile extends StatefulWidget {
  const FeedSourceListTile({
    super.key,
    required this.feedSource,
    required this.feedSourceNotifier,
    required this.feedItemsBloc,
  });

  final FeedSource feedSource;
  final FeedSourceNotifier feedSourceNotifier;
  final FeedItemsBloc feedItemsBloc;

  void removeSource() {
    feedSourceNotifier.removeSource(feedSource);
    feedItemsBloc.removeSource(feedSource);
  }

  void filterItemsFromSource() {
    feedSource.toggleEnabled();
    feedItemsBloc.filterSource(feedSource);
  }

  @override
  State<FeedSourceListTile> createState() => _FeedSourceListTileState();
}

class _FeedSourceListTileState extends State<FeedSourceListTile> {
  var enabled = false;

  void toggleEnabled() {
    setState(() {
      widget.filterItemsFromSource();
      enabled = !enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() => enabled = widget.feedSource.enabled);

    return ListTile(
      leading: FeedAvatar(image: widget.feedSource.image),
      title: Text(
        widget.feedSource.title,
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
                      content: Text(
                          "Are you sure to delete ${widget.feedSource.title}?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.removeSource();
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
            value: enabled,
            onChanged: (_) => toggleEnabled(),
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
