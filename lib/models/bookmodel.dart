import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String id;
  String title;
  String author;
  String description;
  String image;
  List<String> categories;
  bool lock;
  int price;
  List<String> tags; // ➕ Thêm trường tags

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.categories,
    this.lock = false,
    required this.price,
    this.tags = const [], // Mặc định rỗng
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'Không rõ',
      description: data['description'] ?? '',
      image: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      lock: data['lock'] ?? false,
      price: data['price'] ?? 0,
      tags:
          List<String>.from(data['tags'] ?? []), // ➕ đọc mảng tags từ Firestore
    );
  }

  get isFavorite => null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': image,
      'categories': categories,
      'lock': lock,
      'price': price,
      'tags': tags, // ➕ lưu tags
    };
  }
}
