import 'package:flutter/material.dart';
import '../models/book.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Título: ${book.title}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Autor: ${book.author}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
