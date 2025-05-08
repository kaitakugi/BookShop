class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String pdfUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.pdfUrl,
  });

  factory Book.fromFirestore(Map<String, dynamic> data, String docId) {
    return Book(
      id: docId,
      title: data['title'],
      author: data['author'],
      description: data['description'],
      coverUrl: data['cover_url'],
      pdfUrl: data['pdf_url'],
    );
  }
}
