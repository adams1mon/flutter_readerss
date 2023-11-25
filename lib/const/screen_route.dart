// Routes used by the Navigator

enum ScreenRoute{

  login(route: "/login"),
  main(route: "/main"),
  user(route: "/user"),
  webview(route: "/webview");

  const ScreenRoute({required this.route});
  final String route;
}