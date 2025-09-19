import 'package:flutter/material.dart';
import '../models/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> books = [
    Book(title: "O Senhor dos Anéis", author: "J.R.R. Tolkien"),
    Book(title: "Dom Casmurro", author: "Machado de Assis"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minha Biblioteca"), centerTitle: true),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            onTap: () {
              Navigator.pushNamed(context, '/book', arguments: book);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            books.add(Book(title: "Novo Livro", author: "Autor X"));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
