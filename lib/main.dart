import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:leaf/screens/auth/login.dart';
import 'package:leaf/screens/auth/register.dart';
import 'screens/home_a.dart' as home_a;
import 'screens/home_b.dart' as home_b;
import 'screens/book_detail_page.dart';
import 'screens/search_page.dart';
import 'models/book.dart';
import 'screens/dashboard_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 0),
    ),
  );
  await remoteConfig.fetchAndActivate();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home_a': (context) => const home_a.HomePageA(group: "A"),
        '/home_b': (context) => const home_b.HomePageB(group: "B"),
        '/search': (context) => const SearchPage(),
        '/book': (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return BookDetailPage(book: book);
        },
        '/stats': (context) => const DashboardPage(),
      },
    );
  }
}
