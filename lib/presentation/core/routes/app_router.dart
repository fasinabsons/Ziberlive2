import 'package:flutter/material.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String bills = '/bills';
  static const String tasks = '/tasks';
  static const String voting = '/voting';
  static const String investments = '/investments';
  static const String community = '/community';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}