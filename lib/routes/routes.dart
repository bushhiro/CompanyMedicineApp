import 'package:flutter/material.dart';
import '../presentation/screens/downloaded_lists_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String downloadedLists = '/downloaded_lists';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // Экран логина
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

    // Главная страница (принимает имя врача)
      case home:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final doctorName = args['doctorName'] as String? ?? 'Неизвестно';
        final doctorId = args['doctorId'] as int? ?? 0;


        return MaterialPageRoute(
          builder: (_) => HomeScreen(doctorName: doctorName, doctorId: doctorId,),
        );

    // Экран со списками
      case downloadedLists:
        return MaterialPageRoute(builder: (_) => const DownloadedListsScreen());

    // Если маршрут не найден
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Страница не найдена")),
          ),
        );
    }
  }
}