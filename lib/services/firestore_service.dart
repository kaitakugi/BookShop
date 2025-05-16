// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookmodel.dart';

class FirestoreService {
  final _booksCollection = FirebaseFirestore.instance.collection('books');

  // Thêm sách mới vào Firestore
  Future<void> addBook(Book book) async {
    await _booksCollection.add({
      'title': book.title,
      'author': book.author,
      'description': book.description,
      'image': book.image, // Chỉnh sửa từ 'cover_url' thành 'image'
      'isFavorite': book.isFavorite, // Chỉnh sửa từ 'isFavorite'
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Lấy danh sách sách từ Firestore
  Stream<List<Book>> getBooks() {
    return _booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Sử dụng phương thức 'fromFirestore' và cung cấp cả 'doc.id' để khởi tạo Book
        return Book.fromFirestore(doc);
      }).toList();
    });
  }
}
