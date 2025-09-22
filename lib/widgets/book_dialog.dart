import 'package:flutter/material.dart';
import '../models/book.dart';

Future<Book?> showBookDialog({
  required BuildContext context,
  Book? book,
}) async {
  final titleController = TextEditingController(text: book?.title ?? "");
  final authorController = TextEditingController(text: book?.author ?? "");
  final commentController = TextEditingController(text: book?.comment ?? "");
  bool isRead = book?.isRead ?? false;

  return showDialog<Book>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(book == null ? "Adicionar Livro" : "Editar Comentario"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
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
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final newBook = Book(
                        title: titleController.text,
                        author: authorController.text,
                        isRead: isRead,
                        comment: commentController.text,
                      );
                      Navigator.pop(context, newBook);
                    },
                    child: const Text("Salvar"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
