import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';
import 'book_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageB extends StatefulWidget {
  const HomePageB({super.key});

  @override
  State<HomePageB> createState() => _HomePageBState();
}

class _HomePageBState extends State<HomePageB> {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca Visual"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksRef.where("uid", isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum livro adicionado ainda",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final books = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Book.fromMap(data, id: doc.id);
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: book),
                    ),
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
                          child: Image.network(book.thumbnailUrl),
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
                                  booksRef.doc(book.id).update(editedBook.toMap());
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                booksRef.doc(book.id).delete();
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/search');
          if (newBook != null && newBook is Book) {
            booksRef.add({
              "uid": user.uid,
              ...newBook.toMap(),
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
