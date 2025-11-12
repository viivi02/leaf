import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';
import 'book_detail_page.dart';
import '../component/event_logger.dart';
import '../theme/app_theme.dart';

class HomePageA extends StatefulWidget {
  const HomePageA({super.key, required this.group});
  final String group;

  @override
  State<HomePageA> createState() => _HomePageAState();
}

class _HomePageAState extends State<HomePageA> {
  final user = FirebaseAuth.instance.currentUser!;
  final booksRef = FirebaseFirestore.instance.collection("books");
  DateTime? _entryTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();

    // Log de entrada
    EventLogger.logEvent(
      userId: user.uid,
      group: widget.group,
      action: "list_view_opened",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "📚 Minha Biblioteca",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: booksRef.where("uid", isEqualTo: user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum livro encontrado",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final book = Book.fromMap(data, id: docs[index].id);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: AppTheme.cardDecoration,
                        child: ListTile(
                          leading: const Icon(Icons.menu_book,
                              color: Colors.white70),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            book.author,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailPage(book: book),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.lightBlueAccent),
                                onPressed: () async {
                                  final editedBook = await showBookDialog(
                                    context: context,
                                    book: book,
                                  );
                                  if (editedBook != null) {
                                    await booksRef
                                        .doc(docs[index].id)
                                        .update(editedBook.toMap());
                                    EventLogger.logEvent(
                                      userId: user.uid,
                                      group: widget.group,
                                      action: "edit_book_a",
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  await booksRef.doc(docs[index].id).delete();
                                  EventLogger.logEvent(
                                    userId: user.uid,
                                    group: widget.group,
                                    action: "delete_book_a",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Adicionar Livro"),
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/search');
          if (newBook != null && newBook is Book) {
            await booksRef.add({"uid": user.uid, ...newBook.toMap()});
            if (_entryTime != null) {
              final duration = DateTime.now().difference(_entryTime!);
              EventLogger.logEvent(
                userId: user.uid,
                group: widget.group,
                action: "time_to_add_a",
                durationMs: duration.inMilliseconds,
              );
            }
          }
        },
      ),
    );
  }
}
