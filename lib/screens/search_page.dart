import 'package:flutter/material.dart';
import 'package:leaf/theme/app_theme.dart';
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
      extendBodyBehindAppBar: true,
      // AppBar transparente integrado ao gradiente
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pesquisar Livro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Campo de busca + botão
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: AppTheme.inputDecoration(
                          label: "Digite o título do livro",
                          icon: Icons.search,
                        ).copyWith(
                          // hint fica consistente com label; remove floating label overlap
                          hintText: "Digite o título do livro",
                          hintStyle: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: searchBooks,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text("Buscar"),
                      style: AppTheme.primaryButtonStyle,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Conteúdo: loader / sem resultados / lista
                if (isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else if (searchResults.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Nenhum resultado",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final bookData = searchResults[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: AppTheme.cardDecoration,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: bookData["thumbnail"] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      bookData["thumbnail"]!,
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.book, size: 40, color: Colors.white70),
                            title: Text(
                              bookData["title"] ?? "Sem título",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              bookData["author"] ?? "Autor desconhecido",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Colors.lightBlueAccent),
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
        ),
      ),
    );
  }
}
