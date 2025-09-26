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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minha Biblioteca"),
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

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final book = Book.fromMap(data, id: doc.id);

              return Card(
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
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
                            await booksRef
                                .doc(doc.id)
                                .update(editedBook.toMap());
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await booksRef.doc(doc.id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 116, 229, 197),
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/search');
          if (newBook != null && newBook is Book) {
            await booksRef.add({"uid": user.uid, ...newBook.toMap()});

            if (_entryTime != null) {
              final duration = DateTime.now().difference(_entryTime!);
              EventLogger.logEvent(
                userId: user.uid,
                group: widget.group,
                action: "time_to_add",
                durationMs: duration.inMilliseconds,
              );
            }
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
