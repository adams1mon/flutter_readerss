import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/model/feed_source.dart';
import 'package:provider/provider.dart';

import '../components/bottom_navbar.dart';
import 'container_page.dart';

class FeedSourceListNotifier extends ChangeNotifier {
  final _items = <FeedSource>[];

  get items => List.unmodifiable(_items);

  void addItem(FeedSource source) {
    _items.add(source);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 && index >= _items.length) {
      return;
    }
    _items.removeAt(index);
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
              Expanded(child: FeedSourceList(),),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: consumerContext,
                builder: (BuildContext context) {
                  return Center(
                    child: SingleChildScrollView(
                      child: AddFeedSourceDialog(feedSourceNotifier: Provider.of<FeedSourceListNotifier>(consumerContext)),
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
  final TextEditingController _newItemController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text('Add New Feed Source'),
      content: TextField(
        controller: _newItemController,
        decoration:
            const InputDecoration(hintText: 'Paste the URL of the feed: '),
      ),
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

            // TODO: check if feed url is valid
            var url = _newItemController.value.text;
            var feedSource = FeedSource(title: "blah", link: url);
            widget.feedSourceNotifier.addItem(feedSource);

            Navigator.of(context).pop();
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

    return ListView.builder(
      itemCount: feedSourceNotifier.items.length,
      itemBuilder: (context, index) {
        var item = feedSourceNotifier.items[index];
        return FeedSourceListTile(
          feedSource: item,
          removeItem: () => feedSourceNotifier.removeItem(index),
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
