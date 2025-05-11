import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/postdetail.dart';
import 'package:study_app/writestory.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  _ForumState createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final TextEditingController _postController = TextEditingController();

  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
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
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải user: $e');
    }
  }

  void _addPost() async {
    if (_postController.text.isNotEmpty && user != null) {
      final newPost = {
        'name': user!.username, // Lấy tên từ người dùng đăng nhập
        'profilePic': 'https://www.example.com/profile-pic.jpg',
        'status': _postController.text,
        'comments': [],
        'likes': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('forum').add(newPost);
      _postController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WriteStoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              decoration: const InputDecoration(
                labelText: 'Write a post...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPost,
              child: const Text('Post'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('forum')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  final posts = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Post(
                      id: doc.id,
                      name: data['name'] ?? '',
                      profilePic: data['profilePic'] ?? '',
                      status: data['status'] ?? '',
                      comments: data['comments'] is List
                          ? List<String>.from(data['comments'])
                          : [],
                      likedUsers: data['likes'] is List
                          ? List<String>.from(data['likes'])
                          : [],
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: posts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String id;
  final String name;
  final String profilePic;
  final String status;
  final List<String> comments;
  final List<String> likedUsers;

  Post({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.status,
    required this.comments,
    required this.likedUsers,
  });

  int get likes => likedUsers.length;
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late List<String> likedUsers;

  @override
  void initState() {
    super.initState();
    likedUsers = List.from(widget.post.likedUsers);
  }

  void _likePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef =
        FirebaseFirestore.instance.collection('forum').doc(widget.post.id);
    final postSnapshot = await postRef.get();

    final data = postSnapshot.data() as Map<String, dynamic>;
    final List<dynamic> firestoreLikes = data['likes'] ?? [];

    setState(() {
      if (firestoreLikes.contains(currentUser.uid)) {
        // Đã like → unlike
        firestoreLikes.remove(currentUser.uid);
        likedUsers.remove(currentUser.uid);
      } else {
        // Chưa like → like
        firestoreLikes.add(currentUser.uid);
        likedUsers.add(currentUser.uid);
      }
    });

    // Cập nhật lên Firestore
    await postRef.update({'likes': firestoreLikes});
  }

  void _goToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostDetailPage(post: widget.post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.status),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        likedUsers.contains(
                                FirebaseAuth.instance.currentUser?.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: _likePost,
                      color: Colors.red,
                    ),
                    Text('${likedUsers.length} Likes'),
                  ],
                ),
                TextButton.icon(
                  onPressed: _goToDetail,
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
