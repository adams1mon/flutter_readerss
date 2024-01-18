// Routes used by the Navigator

enum ScreenRoute{

  authHandler(route: "/auth-handler"),

  main(route: "/main"),
  login(route: "/login"),
  user(route: "/user"),
  webview(route: "/webview");

  const ScreenRoute({required this.route});
  final String route;
}