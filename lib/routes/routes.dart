import 'package:flutter/material.dart';
import '/presentation/home_screen.dart';
import '/presentation/downloaded_lists_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String downloadedLists = '/downloaded_lists';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case downloadedLists:
        return MaterialPageRoute(builder: (_) => const DownloadedListsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Страница не найдена")),
          ),
        );
    }
  }
}