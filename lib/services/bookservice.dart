import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/bookmodel.dart';

class BookService {
  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('books');

  // Thêm sách mới
  Future<void> addBook(Book book) async {
    await booksCollection.add(book.toMap());
  }

  // Cập nhật sách
  Future<void> updateBook(Book newBook) async {
    await booksCollection.doc(newBook.id).update(newBook.toMap());
  }

  // Xoá sách
  Future<void> deleteBook(String id) async {
    await booksCollection.doc(id).delete();
  }

  // Lấy danh sách sách (Stream)
  Stream<List<Book>> getBooks() {
    return booksCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  // Lấy sách 1 lần (dùng khi cần)
  Future<List<Book>> fetchBooksOnce() async {
    final snapshot = await booksCollection.get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  // Lấy sách miễn phí (lock = false hoặc không có field lock)
  Stream<List<Book>> getFreeBooks() {
    return booksCollection.where('lock', isEqualTo: false).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  // Lấy sách mất xu (lock = true)
  Stream<List<Book>> getLockedBooks() {
    return booksCollection.where('lock', isEqualTo: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }
}
