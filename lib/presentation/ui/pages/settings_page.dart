import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/presenter/feed_events.dart';
import 'package:flutter_readrss/presentation/ui/components/app_bar.dart';
import 'package:flutter_readrss/presentation/ui/components/avatars.dart';
import 'package:flutter_readrss/presentation/ui/components/help_text.dart';
import 'package:flutter_readrss/presentation/ui/components/loading_indicator.dart';
import 'package:flutter_readrss/presentation/ui/components/utils.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exception.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_source.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:provider/provider.dart';

import '../components/bottom_navbar.dart';
import '../const/screen_page.dart';
import 'container_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.feedSourcesStream,
    required this.loadFeedByUrl,
    required this.deleteFeedSource,
    required this.toggleFeedSource,
    required this.isLoggedIn,
  });

  final Stream<FeedSourcesEvent> feedSourcesStream;

  final Future<void> Function(String) loadFeedByUrl;
  final Future<void> Function(FeedSource) deleteFeedSource;
  final Future<void> Function(FeedSource) toggleFeedSource;
  final bool Function() isLoggedIn;

  void launchAddFeedDialog(BuildContext context) {
    if (!isLoggedIn()) {
      showAuthDialog(context, "You must be logged in to add a personal feed.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AddFeedSourceDialog(
              loadFeedByUrl: loadFeedByUrl,
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
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: FeedSourcesContainer(
                listTitle: "Personal Feed List",
                feedSourcesStream: feedSourcesStream,
                deleteFeedSource: deleteFeedSource,
                toggleFeedSource: toggleFeedSource,
                launchAddFeedDialog: () => launchAddFeedDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedSourcesContainer extends StatelessWidget {
  const FeedSourcesContainer({
    super.key,
    required this.listTitle,

    required this.feedSourcesStream,
    required this.deleteFeedSource,
    required this.toggleFeedSource,
    required this.launchAddFeedDialog,
  });

  final Stream<FeedSourcesEvent> feedSourcesStream;

  final Future<void> Function(FeedSource) deleteFeedSource;
  final Future<void> Function(FeedSource) toggleFeedSource;

  final String listTitle;
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
              feedSourcesStream: feedSourcesStream,
              removeFeedSource: deleteFeedSource,
              toggleFeedSource: toggleFeedSource,
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
    required this.loadFeedByUrl,
  });

  final Future<void> Function(String) loadFeedByUrl;

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

    widget.loadFeedByUrl(url).then((_) {
      clearLoading();
      Navigator.of(context).pop();
    }, onError: (err) {
      setFeedSourceError((err as UseCaseException).message);
    });
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
          ? const LoadingIndicator() 
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
    required this.feedSourcesStream,
    required this.removeFeedSource,
    required this.toggleFeedSource,
    this.noItemsText =
        "It seems like there are no feed sources.\nTry to add some below!",
  });


  final Stream<FeedSourcesEvent> feedSourcesStream;

  final Future<void> Function(FeedSource) removeFeedSource;
  final Future<void> Function(FeedSource) toggleFeedSource;

  final String noItemsText;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FeedSourcesEvent>(
      stream: feedSourcesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log("error when consuming from stream, ${snapshot.error}");
          return const Text("An unknown error occurred.");
        } else if (!snapshot.hasData || snapshot.data!.feedSources.isEmpty) {
          return HelpText(text: noItemsText);
        } else {
          final sources = snapshot.data!.feedSources;
          log("UI got sources: $sources");

          return ListView.builder(
            itemCount: sources.length,
            itemBuilder: (context, index) {
              var source = sources[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FeedSourceListTile(
                  feedSource: source,
                  removeSource: () async => await removeFeedSource(sources[index]),
                  toggleSource: () async => await toggleFeedSource(sources[index]),
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
    required this.toggleSource,
  });

  final FeedSource feedSource;

  final Future<void> Function() removeSource;
  final Future<void> Function() toggleSource;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FeedAvatar(imageUrl: feedSource.iconUrl),
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
