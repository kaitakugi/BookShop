import 'package:flutter/material.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/mybook/writemybook.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/bookmodel.dart';

import 'mybookdetail.dart';

class MyBook extends StatefulWidget {
  const MyBook({super.key});

  @override
  State<MyBook> createState() => _MyBookState();
}

class _MyBookState extends State<MyBook> {
  late final UserModel currentUser;
  List<Book> books = [];
  List<bool> isExpanded = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
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
        categories: List<String>.from(data['categories'] ?? []),
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

  Future<void> requestToPublish(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final adminRequests =
        FirebaseFirestore.instance.collection('pending_books');
    await adminRequests.add({
      'userId': user.uid,
      'bookId': book.id,
      'title': book.title,
      'author': book.author,
      'categories': book.categories,
      'description': book.description,
      'image': book.image,
      'requestedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi yêu cầu đến quản trị viên.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Viết truyện',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WriteMyBookPage()),
              ).then((_) => fetchUserBooks());
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('Bạn chưa viết truyện nào.'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Image.network(book.image,
                                width: 50, height: 70, fit: BoxFit.cover),
                            title: Text(book.title),
                            subtitle: Text(book.author),
                            trailing: IconButton(
                              icon: Icon(isExpanded[index]
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down),
                              onPressed: () {
                                setState(() {
                                  isExpanded[index] = !isExpanded[index];
                                });
                              },
                            ),
                          ),
                          if (isExpanded[index])
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => requestToPublish(book),
                                    child:
                                        const Text('Xin đưa lên trang truyện'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MyBookDetailPage(
                                            bookId: book.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Xem chi tiết'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final shouldDelete =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Xác nhận xóa'),
                                          content: const Text(
                                              'Bạn có chắc chắn muốn xóa sách này không?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Xóa'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldDelete != true) return;

                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user == null) return;

                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('books')
                                            .doc(book.id)
                                            .delete();

                                        await fetchUserBooks();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Xóa sách thành công')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Lỗi khi xóa sách: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Xóa sách'),
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
                                              'categories': book.categories,
                                              'description': book.description,
                                              'imageUrl': book.image,
                                            },
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        fetchUserBooks(); // Làm mới danh sách sau khi chỉnh sửa
                                      }
                                    },
                                    child: const Text('Sửa sách'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
