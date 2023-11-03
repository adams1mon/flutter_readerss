// Different screen pages which can appear in the 'main' navigator route,
// switched via a bottom navbar

enum ScreenPage{

  mainFeed(title: "Main Feed"),
  personalFeed(title: "Personal Feed"),
  bookmarks(title: "Bookmarks"),
  settings(title: "Settings"),
  account(title: "Account");

  const ScreenPage({required this.title});
  final String title;
}