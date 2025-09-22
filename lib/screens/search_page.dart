import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/services/book_api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  bool isLoading = false;

  Future<void> searchBooks() async {
    setState(() => isLoading = true);
    try {
      final results = await BookApiService.searchBooks(searchController.text);
      setState(() => searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao buscar livros")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesquisar Livro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Digite o título do livro",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: searchBooks,
                  icon: const Icon(Icons.search),
                  label: const Text("Buscar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (searchResults.isEmpty)
              const Text("Nenhum resultado", style: TextStyle(fontSize: 16))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final bookData = searchResults[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: bookData["thumbnail"] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  bookData["thumbnail"]!,
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.book, size: 40),
                        title: Text(
                          bookData["title"] ?? "Sem título",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(bookData["author"] ?? "Autor desconhecido"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            Navigator.pop(
                              context,
                              Book(
                                title: bookData["title"] ?? "Sem título",
                                author: bookData["author"] ?? "Autor desconhecido",
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
