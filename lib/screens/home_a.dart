import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_dialog.dart';
import 'book_detail_page.dart';
import '../component/event_logger.dart';

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

    // Evento: entrou na tela A
    EventLogger.logEvent(
      userId: user.uid,
      group: widget.group,
      action: "list_view_opened",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("📚 Minha Biblioteca"),
        backgroundColor: Colors.teal,
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
            return const Center(child: Text("Nenhum livro encontrado"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final book = Book.fromMap(data, id: docs[index].id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                elevation: 2,
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  leading: const Icon(Icons.menu_book, color: Colors.teal),
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
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final editedBook = await showBookDialog(
                            context: context,
                            book: book,
                          );
                          if (editedBook != null) {
                            await booksRef.doc(docs[index].id).update(editedBook.toMap());
                            EventLogger.logEvent(
                              userId: user.uid,
                              group: widget.group,
                              action: "edit_book_a",
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
