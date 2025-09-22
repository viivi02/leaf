class Book {
  final String title;
  final String author;
  bool isRead;
  String comment;

  Book({
    required this.title,
    required this.author,
    this.isRead = false,
    this.comment = "",
  });
}
