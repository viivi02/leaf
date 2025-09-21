import 'package:flutter/material.dart';
import '../models/book.dart';

Future<Book?> showBookDialog({
  required BuildContext context,
  Book? book,
}) async {
  final titleController = TextEditingController(text: book?.title ?? "");
  final authorController = TextEditingController(text: book?.author ?? "");

  return showDialog<Book>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(book == null ? "Adicionar Livro" : "Editar Livro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: "Autor"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newBook = Book(
                title: titleController.text,
                author: authorController.text,
              );
              Navigator.pop(context, newBook);
            },
            child: const Text("Salvar"),
          ),
        ],
      );
    },
  );
}
