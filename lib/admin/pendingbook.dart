import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPendingBooksPage extends StatefulWidget {
  const AdminPendingBooksPage({super.key});

  @override
  State<AdminPendingBooksPage> createState() => _AdminPendingBooksPageState();
}

class _AdminPendingBooksPageState extends State<AdminPendingBooksPage> {
  Future<void> approveBook(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final batch = FirebaseFirestore.instance.batch();
    // Lưu sách vào collection chính thức
    final booksRef =
        FirebaseFirestore.instance.collection('books').doc(); // Tạo docId mới
    batch.set(booksRef, {
      'userId': data['userId'],
      'title': data['title'],
      'author': data['author'],
      'category': data['category'],
      'description': data['description'],
      'imageUrl': data['image'],
      'approvedAt': FieldValue.serverTimestamp(),
      // Khai báo đây là sách miễn phí (không khóa)
      'lock': false,
    });

    // Xóa khỏi danh sách yêu cầu
    final pendingRef =
        FirebaseFirestore.instance.collection('pending_books').doc(doc.id);
    batch.delete(pendingRef);

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã duyệt truyện thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu duyệt truyện'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_books')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Không có yêu cầu nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.network(
                    data['image'],
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                  title: Text(
                    data['title'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    data['author'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => approveBook(doc),
                        child: const Text('Duyệt'),
                      ),
                      const SizedBox(width: 8), // Khoảng cách giữa các nút
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
                                .collection('pending_books')
                                .doc(doc.id)
                                .delete();

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
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
