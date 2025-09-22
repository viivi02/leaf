import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApiService {
  static const String baseUrl = "https://www.googleapis.com/books/v1/volumes";

  static Future<List<Map<String, String>>> searchBooks(String query) async {
    final url = Uri.parse("$baseUrl?q=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data["items"] ?? [];

      return items.map<Map<String, String>>((item) {
        final volumeInfo = item["volumeInfo"];
        return {
          "title": (volumeInfo["title"] ?? "Sem título").toString(),
          "author": (volumeInfo["authors"] != null &&
                  volumeInfo["authors"].isNotEmpty)
              ? volumeInfo["authors"][0].toString()
              : "Autor desconhecido",
        };
      }).toList();
    } else {
      throw Exception("Erro ao buscar livros");
    }
  }
}
