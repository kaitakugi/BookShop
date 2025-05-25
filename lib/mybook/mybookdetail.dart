import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/mybook/writemybook.dart';
import 'package:study_app/search/chapter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookDetailPage extends StatefulWidget {
  final Book book;

  const MyBookDetailPage({
    super.key,
    required this.book,
  });

  @override
  State<MyBookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<MyBookDetailPage> {
  UserModel? user;
  List<Book> books = [];
  List<bool> isExpanded = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchUserBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .orderBy('createdAt', descending: true)
        .get();

    final loadedBooks = snapshot.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id,
        title: data['title'] ?? '',
        author: data['author'] ?? 'Không rõ',
        description: data['description'] ?? '',
        image: data['imageUrl'] ?? '',
        category: data['category'] ?? 'Không rõ',
        lock: data['lock'] ?? false,
        price: data['price'] ?? 0,
      );
    }).toList();

    setState(() {
      books = loadedBooks;
      isExpanded = List.filled(books.length, false);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!;
        final currentUser = UserModel.fromFirestore(userData);
        final now = DateTime.now();

        // Sau khi xem xong hoặc user là premium thì hiển thị nội dung trang
        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Image.network(
                book.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    book.title,
                    style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WriteMyBookPage(
                            bookId: book.id,
                            initialData: {
                              'title': book.title,
                              'author': book.author,
                              'category': book.category,
                              'description': book.description,
                              'image': book.image,
                            },
                          ),
                        ),
                      );

                      if (result == true) {
                        fetchUserBooks(); // Làm mới danh sách sau khi chỉnh sửa
                      }
                    },
                    child: const Icon(Icons.edit),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Author: ${book.author}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 4,
                minRating: 1,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  debugPrint("Rating: $rating");
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Chapters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Chapter ${index + 1}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChapterPage(chapterIndex: index),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
