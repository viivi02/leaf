import 'package:flutter/material.dart';
import '../models/book.dart';

Future<Book?> showBookDialog({
  required BuildContext context,
  required Book book,
}) async {
  final commentController = TextEditingController(text: book.comment);
  bool isRead = book.isRead;

  return showDialog<Book>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Editar Comentário"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: "Comentário"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: isRead,
                    onChanged: (value) {
                      setState(() {
                        isRead = value ?? false;
                      });
                    },
                    title: const Text("Já li este livro"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedBook = Book(
                    id: book.id,
                    title: book.title,
                    author: book.author,
                    thumbnailUrl: book.thumbnailUrl,
                    isRead: isRead,
                    comment: commentController.text,
                  );
                  Navigator.pop(context, updatedBook);
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        },
      );
    },
  );
}
