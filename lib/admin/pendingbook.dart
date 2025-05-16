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
      'image': data['image'],
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

  void _confirmApprove(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: const Text('Bạn có chắc muốn duyệt truyện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              approveBook(doc);
            },
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu duyệt truyện')),
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
                  leading: Image.network(data['image'],
                      width: 50, height: 70, fit: BoxFit.cover),
                  title: Text(data['title']),
                  subtitle: Text(data['author']),
                  trailing: ElevatedButton(
                    onPressed: () => approveBook(doc),
                    child: const Text('Duyệt'),
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
