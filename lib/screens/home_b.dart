import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';
import 'book_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../component/event_logger.dart';

class HomePageB extends StatefulWidget {
  const HomePageB({super.key, required this.group});
  final String group;

  @override
  State<HomePageB> createState() => _HomePageBState();
}

class _HomePageBState extends State<HomePageB> {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference booksRef = FirebaseFirestore.instance.collection(
    'books',
  );
  DateTime? _entryTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca Visual"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
              final imageUrl = book.thumbnailUrl;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: book),
                    ),
                  );

                  EventLogger.logEvent(
                    userId: user.uid,
                    group: widget.group,
                    action: "book_opened_b",
                    extra: {"book_title": book.title},
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
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // 🔸 fallback se a URL for inválida
                                    EventLogger.logEvent(
                                      userId: user.uid,
                                      group: widget.group,
                                      action: "image_load_error_b",
                                      extra: {"book_title": book.title},
                                    );
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  await booksRef
                                      .doc(book.id)
                                      .update(editedBook.toMap());

                                  EventLogger.logEvent(
                                    userId: user.uid,
                                    group: widget.group,
                                    action: "book_edited_b",
                                    extra: {"book_title": book.title},
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await booksRef.doc(book.id).delete();

                                EventLogger.logEvent(
                                  userId: user.uid,
                                  group: widget.group,
                                  action: "book_deleted_b",
                                  extra: {"book_title": book.title},
                                );
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

      // 🔹 Botão de adicionar de volta (com log)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/search');
          if (newBook != null && newBook is Book) {
            await booksRef.add({"uid": user.uid, ...newBook.toMap()});

            if (_entryTime != null) {
              final duration = DateTime.now().difference(_entryTime!);
              EventLogger.logEvent(
                userId: user.uid,
                group: widget.group,
                action: "time_to_add_b",
                durationMs: duration.inMilliseconds,
              );
            }
          }

          EventLogger.logEvent(
            userId: user.uid,
            group: widget.group,
            action: "add_button_pressed_b",
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Adicionar Livro"),
        backgroundColor: const Color.fromARGB(255, 188, 170, 220),
      ),
    );
  }
}
