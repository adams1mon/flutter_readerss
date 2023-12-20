import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

import '../const/screen_page.dart';


class ReadrssBottomNavbar extends BottomNavigationBar {
  ReadrssBottomNavbar({
    super.key,
    required super.currentIndex,
    required super.onTap,
    required BuildContext context,
  }) : super(
    selectedItemColor: colors(context).primary,
    elevation: 24,
    useLegacyColorScheme: false,
    items: [
      BottomNavigationBarItem(
        icon: const Icon(Icons.newspaper),
        label: ScreenPage.mainFeed.title,
        backgroundColor: colors(context).primaryContainer,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.rss_feed),
        label: ScreenPage.personalFeed.title,
        backgroundColor: colors(context).primaryContainer,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bookmark_added),
        label: ScreenPage.bookmarks.title,
        backgroundColor: colors(context).primaryContainer,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: ScreenPage.settings.title,
        backgroundColor: colors(context).primaryContainer,
      ),
    ],
  );
}
