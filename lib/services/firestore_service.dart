import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookmodel.dart';

class FirestoreService {
  final _booksCollection = FirebaseFirestore.instance.collection('books');

  Future<void> addBook(Book book) async {
    await _booksCollection.add({
      'title': book.title,
      'author': book.author,
      'description': book.description,
      'cover_url': book.coverUrl,
      'pdf_url': book.pdfUrl,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Book>> getBooks() {
    return _booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
