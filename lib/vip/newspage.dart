import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usermodel.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPage();
}

class _NewsPage extends State<NewsPage> {
  final TextEditingController _commentnewspostController =
      TextEditingController();
  UserModel? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentnewspostController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  Future<void> _fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        setState(() {
          user = UserModel(
            username: doc['username'],
            email: doc['email'],
            password: '',
          );
        });
      }
    }
  }

  // ignore: unused_element
  Future<void> _addComment(String postId) async {
    final text = _commentnewspostController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (text.isNotEmpty && currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final username = doc['username'];

      await FirebaseFirestore.instance
          .collection('news')
          .doc(postId)
          .collection('comments')
          .add({
        'username': username,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentnewspostController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newsCollection = FirebaseFirestore.instance.collection('news');
    final isDark = theme.brightness == Brightness.dark; // Luôn trắng do nền là grey[900]

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kênh tin tức VIP'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.amberAccent
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            newsCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final title = doc['title'];
              final image = doc['imageUrl'];
              final content = doc['content'];

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: ExpansionTile(
                  leading: const Icon(Icons.article),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    if (image.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            image,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(content),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Bình luận:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // 👇 Bạn có thể chèn code comment của bạn tại đây
                    SizedBox(
                      height:
                          250, // hoặc MediaQuery.of(context).size.height * 0.4
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('news')
                            .doc(doc.id)
                            .collection('comments')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('Chưa có bình luận nào'));
                          }

                          final comments = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index].data()
                                  as Map<String, dynamic>;
                              return ListTile(
                                leading: const Icon(Icons.comment),
                                title: Text(comment['username'] ?? 'Ẩn danh'),
                                subtitle: Text(comment['content'] ?? ''),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _commentnewspostController,
                        decoration: InputDecoration(
                          hintText: 'Nhập bình luận...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _addComment(doc.id),
                            // Gọi hàm comment(doc.id, nội dung) tại đây
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
