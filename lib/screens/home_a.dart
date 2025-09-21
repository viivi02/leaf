import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';

class HomePageA extends StatefulWidget {
  const HomePageA({super.key});

  @override
  State<HomePageA> createState() => _HomePageAState();
}

class _HomePageAState extends State<HomePageA> {
  List<Book> books = [
    Book(title: "O Senhor dos Anéis", author: "J.R.R. Tolkien"),
    Book(title: "Dom Casmurro", author: "Machado de Assis"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minha Biblioteca")),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            child: ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                Navigator.pushNamed(context, '/book', arguments: book);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final editedBook = await showBookDialog(
                        context: context,
                        book: book,
                      );
                      if (editedBook != null) {
                        setState(() {
                          books[index] = editedBook;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        books.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await showBookDialog(context: context);
          if (newBook != null) {
            setState(() {
              books.add(newBook);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
