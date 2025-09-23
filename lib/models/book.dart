class Book {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final bool isRead;
  final String comment;

  Book({
    this.id = "",
    required this.title,
    required this.author,
    this.thumbnailUrl = "",
    this.isRead = false,
    this.comment = "",
  });

  factory Book.fromMap(Map<String, dynamic> map, {String id = ""}) {
    return Book(
      id: id,
      title: map["title"] ?? "Sem título",
      author: map["author"] ?? "Autor desconhecido",
      thumbnailUrl: map["thumbnailUrl"] ?? "",
      isRead: map["isRead"] ?? false,
      comment: map["comment"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "author": author,
      "thumbnailUrl": thumbnailUrl,
      "isRead": isRead,
      "comment": comment,
    };
  }

  /// 🔥 Método que estava faltando
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? thumbnailUrl,
    bool? isRead,
    String? comment,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isRead: isRead ?? this.isRead,
      comment: comment ?? this.comment,
    );
  }
}
