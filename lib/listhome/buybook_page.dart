import 'package:flutter/material.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/search/bookdetail.dart';
import 'package:study_app/services/adminservices/bookservice.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyBookPage extends StatelessWidget {
  final BookService bookService = BookService();
  final UserModel? currentUser;

  BuyBookPage({
    super.key,
    required this.currentUser,
  });

  Future<Map<String, dynamic>> _fetchData() async {
    final books = await bookService.getLockedBooks().first;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'books': books, 'unlockedBookIds': <String>{}};
    }

    final unlockedSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('unlockedBooks')
        .get();

    //map biến đổi list dữ liệu thành list id
    final unlockedBookIds = unlockedSnap.docs.map((doc) => doc.id).toSet();
    return {'books': books, 'unlockedBookIds': unlockedBookIds};
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Books"),
        backgroundColor: isDarkMode ? Colors.black : null,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load books.'));
            }

            final books = snapshot.data!['books'] as List<Book>;
            final unlockedBookIds =
                snapshot.data!['unlockedBookIds'] as Set<String>;

            if (books.isEmpty) {
              return const Center(child: Text('No books found.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.63,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final book = books[index];
                final isUnlocked = unlockedBookIds.contains(book.id);

                return GestureDetector(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final userId = user.uid;
                    final userDoc = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId);
                    final unlockedRef =
                        userDoc.collection('unlockedBooks').doc(book.id);

                    if (isUnlocked) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(
                            book: book,
                            currentUser: currentUser!,
                          ),
                        ),
                      );
                    } else {
                      if (book.price == 0) {
                        await unlockedRef.set({
                          'unlockedAt': FieldValue.serverTimestamp(),
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(
                              book: book,
                              currentUser: currentUser!,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                isDarkMode ? Colors.grey[900] : Colors.white,
                            title: Text(
                              "Mở khóa sách",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Text(
                              "Bạn cần ${book.price} xu để mở khóa sách này.",
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Hủy"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final userSnap = await userDoc.get();
                                  final currentCoins =
                                      userSnap.data()?['coins'] ?? 0;

                                  if (currentCoins >= book.price) {
                                    await userDoc.update({
                                      'coins':
                                          FieldValue.increment(-book.price),
                                    });
                                    await unlockedRef.set({
                                      'unlockedAt':
                                          FieldValue.serverTimestamp(),
                                    });

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Mở khóa thành công!"),
                                      ),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailPage(
                                          book: book,
                                          currentUser: currentUser!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Bạn không đủ xu để mở khóa."),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Mở khóa"),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[900]
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            book.image,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.categories.join(', '),
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white70 : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (book.lock)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      isUnlocked ? Icons.lock_open : Icons.lock,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                      size: 20,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white10
                                            : Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${book.price} xu',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
