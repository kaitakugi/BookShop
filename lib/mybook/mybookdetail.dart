import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/mybook/writemybook.dart';
import 'package:study_app/search/chapter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookDetailPage extends StatefulWidget {
  final String bookId; // Chỉ truyền bookId thay vì toàn bộ Book object

  const MyBookDetailPage({
    super.key,
    required this.bookId,
  });

  @override
  State<MyBookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<MyBookDetailPage> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data!;
        final currentUser = UserModel.fromFirestore(userData);

        // StreamBuilder để theo dõi thông tin sách cụ thể
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('books')
              .doc(widget.bookId)
              .snapshots(),
          builder: (context, bookSnapshot) {
            if (!bookSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (bookSnapshot.hasError || !bookSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('Không tìm thấy sách.')),
              );
            }

            final bookData = bookSnapshot.data!.data() as Map<String, dynamic>;
            final book = Book(
              id: bookSnapshot.data!.id,
              title: bookData['title'] ?? '',
              author: bookData['author'] ?? 'Không rõ',
              description: bookData['description'] ?? '',
              image: bookData['imageUrl'] ?? '',
              categories: List<String>.from(bookData['categories'] ?? []),
              lock: bookData['lock'] ?? false,
              price: bookData['price'] ?? 0,
            );

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  book.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Image.network(
                    book.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          book.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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
                                  'image': book.image,
                                },
                              ),
                            ),
                          );

                          if (result == true) {
                            // Không cần gọi fetchUserBooks vì StreamBuilder sẽ tự động cập nhật
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3, // Giới hạn mô tả để tránh overflow
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
                              builder: (context) => ChapterPage(chapterIndex: index),
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
      },
    );
  }
}