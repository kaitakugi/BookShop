import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String id;
  String title;
  String author;
  String description;
  String image;
  String category; // Thêm trường category vào đây

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.category, // Khởi tạo category trong constructor
  });

  // Phương thức chuyển đổi từ Firestore document
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'],
      author: data['author'],
      description: data['description'],
      image: data['imageUrl'],
      category: data['category'], // Lấy category từ Firestore
    );
  }

  get isFavorite => null;

  // Phương thức chuyển đổi Book thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': image,
      'category': category, // Lưu category vào Firestore
    };
  }
}
