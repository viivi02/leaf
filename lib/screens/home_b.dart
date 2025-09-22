import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';

class HomePageB extends StatefulWidget {
  const HomePageB({super.key});

  @override
  State<HomePageB> createState() => _HomePageBState();
}

class _HomePageBState extends State<HomePageB> {
  List<Book> books = [
    Book(title: "O Senhor dos Anéis", author: "J.R.R. Tolkien"),
    Book(title: "Dom Casmurro", author: "Machado de Assis"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca Visual"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout -> volta para a tela de login
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                "Nenhum livro adicionado ainda",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // mostra em grade
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/book',
                      arguments: book,
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Icon(
                              Icons.book,
                              size: 60,
                              color: const Color.fromARGB(255, 180, 159, 216),
                            ),
                          ),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    books.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/search');
          if (newBook != null && newBook is Book) {
            setState(() {
              books.add(newBook);
            });
          }
        },
        icon: const Icon(Icons.search),
        label: const Text("Buscar Livro"),
        backgroundColor: const Color.fromARGB(255, 188, 170, 220),
      ),
    );
  }
}
