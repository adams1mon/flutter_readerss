import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/app_bar.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/const/screen_page.dart';
import 'package:flutter_readrss/const/screen_route.dart';
import 'package:provider/provider.dart';

import '../components/bottom_navbar.dart';
import 'container_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> itemList = ['Feed 1', 'Feed 2', 'Feed 3'];
  Map<String, bool> itemStates = {
    'Feed 1': false,
    'Feed 2': false,
    'Feed 3': false
  };
  final TextEditingController _newItemController = TextEditingController();

  void _toggleItemState(String item) {
    setState(() {
      itemStates[item] = !itemStates[item]!;
    });
  }

  void _addItemToList() {
    String newItem = _newItemController.text;
    setState(() {
      itemList.add(newItem);
      itemStates[newItem] = false;
      _newItemController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      itemList.removeAt(index);
    });
  }

  void _navigateToGuestFeed(BuildContext context) {
    Navigator.pushReplacementNamed(context, ScreenRoute.main.route);
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
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Feed List',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                String item = itemList[index];
                return ListTile(
                    leading:
                        FeedAvatar(image: Image.asset("assets/avatar.jpg")),
                    title: Text(item),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeItem(index);
                          },
                        ),
                        Switch(
                          value: itemStates[item]!,
                          onChanged: (value) {
                            _toggleItemState(item);
                          },
                        ),
                      ],
                    ));
              },
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              _navigateToGuestFeed(context);
            },
            child: const Text('Go to Feed'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add New Item'),
                content: TextField(
                  controller: _newItemController,
                  decoration:
                      const InputDecoration(hintText: 'Enter item name'),
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
                      _addItemToList();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
