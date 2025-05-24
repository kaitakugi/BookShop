import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreatePostPage extends StatefulWidget {
  const AdminCreatePostPage({super.key});

  @override
  State<AdminCreatePostPage> createState() => _AdminCreatePostPageState();
}

class _AdminCreatePostPageState extends State<AdminCreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  void _createPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty && imageUrl.isNotEmpty) {
      await FirebaseFirestore.instance.collection('news').add({
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đăng bài viết thành công')),
      );

      _titleController.clear();
      _contentController.clear();
      _imageUrlController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Vui lòng nhập đầy đủ các trường')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Tạo bài viết'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Nội dung bài viết',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.publish),
              label: const Text('Đăng bài'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _createPost,
            )
          ],
        ),
      ),
    );
  }
}
