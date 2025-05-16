import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteMyBookPage extends StatefulWidget {
  const WriteMyBookPage({super.key});

  @override
  State<WriteMyBookPage> createState() => _UserWriteBookPageState();
}

class _UserWriteBookPageState extends State<WriteMyBookPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitBook() async {
    final user = FirebaseAuth.instance.currentUser;

    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để gửi sách')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final booksRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books');

      await booksRef.add({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'image': imageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi sách thành công!')),
      );

      // Xóa dữ liệu form
      titleController.clear();
      authorController.clear();
      categoryController.clear();
      descriptionController.clear();
      imageController.clear();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi sách: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gửi sách của bạn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tên sách *'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Tác giả *'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Thể loại'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả *'),
              maxLines: 3,
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'URL ảnh bìa'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBook,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Gửi sách'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
