import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/book_detail_page.dart';
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
      title: 'Biblioteca App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
      // exemplo de rota com argumento
      onGenerateRoute: (settings) {
        if (settings.name == '/book') {
          final book = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) => BookDetailPage(book: book),
          );
        }
        return null;
      },
    );
  }
}
