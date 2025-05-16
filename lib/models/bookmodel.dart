import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String id;
  String title;
  String author;
  String description;
  String image;
  String category;
  bool lock;
  int price; // 🔒 true nếu sách cần xu, false nếu miễn phí

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.category,
    this.lock = false,
    required this.price, // Mặc định là sách miễn phí
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'Không rõ',
      description: data['description'] ?? '',
      image: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Không rõ',
      lock: data['lock'] ?? false,
      price: data['price'] ?? 0, // Đọc field lock, mặc định là false
    );
  }

  get isFavorite => null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': image,
      'category': category,
      'lock': lock,
      'price': price // Lưu vào Firestore
    };
  }
}
