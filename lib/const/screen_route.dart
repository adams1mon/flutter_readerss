// Routes used by the Navigator

enum ScreenRoute{

  login(route: "/login"),
  main(route: "/main"),
  user(route: "/user");

  const ScreenRoute({required this.route});
  final String route;
}