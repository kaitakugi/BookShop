import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_app/forum.dart';
import 'package:study_app/models/usermodel.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

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

  Future<void> _likePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef =
        FirebaseFirestore.instance.collection('forum').doc(widget.post.id);
    final snapshot = await postRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> likedUsers = data['likes'] ?? [];

    if (!likedUsers.contains(currentUser.uid)) {
      likedUsers.add(currentUser.uid);
      await postRef.update({'likes': likedUsers});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã thả tim bài viết này')),
      );
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (text.isNotEmpty && currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final username = doc['username'];

      final newComment = '$username: $text';

      await FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'username': username,
            'content': text,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });

      setState(() {
        widget.post.comments.add(newComment);
      });

      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.profilePic),
                ),
                const SizedBox(width: 10),
                Text(post.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.status),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('forum')
                  .doc(post.id)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> likedUsers = data['likes'] ?? [];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.red,
                      onPressed: _likePost,
                    ),
                    Text('${likedUsers.length} Likes'),
                  ],
                );
              },
            ),
            const Divider(height: 30),
            const Text("Comments:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('forum')
                    .doc(post.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final List<dynamic> comments = data['comments'] ?? [];

                  comments.sort((a, b) {
                    final aTime = a['timestamp']?.toDate() ?? DateTime.now();
                    final bTime = b['timestamp']?.toDate() ?? DateTime.now();
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      if (comment is Map<String, dynamic>) {
                        return ListTile(
                          leading: const Icon(Icons.comment),
                          title: Text(comment['username'] ?? 'Ẩn danh'),
                          subtitle: Text(comment['content'] ?? ''),
                        );
                      } else {
                        return ListTile(
                          leading: const Icon(Icons.warning),
                          title: Text('Comment lỗi định dạng'),
                          subtitle: Text(comment.toString()),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
