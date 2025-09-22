import 'package:flutter/material.dart';
import 'package:leaf/screens/login.dart';
import 'package:leaf/screens/register.dart';
import 'screens/home_a.dart' as home_a;
import 'screens/home_b.dart' as home_b; // <- importar também
import 'screens/book_detail_page.dart';
import 'screens/search_page.dart';
import 'models/book.dart';

void main() {
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
        '/home_a': (context) => const home_a.HomePageA(), // <- rota adicionada
        '/home_b': (context) => const home_b.HomePageB(), // <- rota adicionada
        '/search': (context) => const SearchPage(),
        '/book': (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return BookDetailPage(book: book);
        },
      },
    );
  }
}
