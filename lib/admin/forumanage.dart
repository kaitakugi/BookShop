import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/forum/forum.dart'; // class Post

class AdminForumPage extends StatelessWidget {
  const AdminForumPage({super.key});

  Future<void> _deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('forum').doc(postId).delete();
      // Xóa cả subcollection comments
      final comments = await FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('comments')
          .get();

      for (var doc in comments.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bài viết và bình luận liên quan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e')),
      );
    }
  }

  Future<int> _getCommentCount(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('forum')
        .doc(postId)
        .collection('comments')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài viết'),
        backgroundColor: Colors.greenAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('forum')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final post = Post(
                userId: data['userId'] ?? '',
                id: doc.id,
                name: data['name'] ?? '',
                profilePic: data['profilePic'] ?? '',
                status: data['status'] ?? '',
                timestamp: data['timestamp'],
                comments: [], // không dùng nữa
                likedUsers: data['likes'] is List
                    ? List<String>.from(data['likes'])
                    : [],
              );

              return FutureBuilder<int>(
                future: _getCommentCount(post.id),
                builder: (context, commentSnapshot) {
                  final commentCount = commentSnapshot.data ?? 0;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(post.profilePic),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                post.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _showConfirmDeleteDialog(context, post.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(post.status),
                          const SizedBox(height: 10),
                          Text(
                              '❤️ ${post.likedUsers.length}  | 💬 $commentCount'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
            onPressed: () {
              Navigator.pop(context);
              _deletePost(context, postId);
            },
          ),
        ],
      ),
    );
  }
}
