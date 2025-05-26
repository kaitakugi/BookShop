import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/forum/postdetail.dart';
import 'package:study_app/forum/writestory.dart';
import 'package:timeago/timeago.dart' as timeago;

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
        'name': user!.username,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'profilePic':
            'https://i.pravatar.cc/150?u=${user!.email}', // dùng ảnh random
        'status': _postController.text,
        'comments': [],
        'likes': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('forum').add(newPost);
      _postController.clear();
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp)
      return '...'; // Hoặc 'Chưa xác định'
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;
    final postButtonColor = isDark ? Colors.grey[900] : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Cộng đồng'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WriteStoryPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Material(
                    elevation: 3,
                    color: isDark ? Colors.grey[900] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Colors.white70, width: 2), // Thêm viền ở đây
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _postController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Chia sẻ điều gì đó...',
                              hintStyle: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.grey),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _addPost,
                              icon: Icon(Icons.send, color: Colors.white),
                              label: const Text('Đăng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: postButtonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('forum')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final posts = docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Post(
                            id: doc.id,
                            userId: data['userId'] ?? '',
                            name: data['name'] ?? '',
                            profilePic: data['profilePic'] ?? '',
                            status: data['status'] ?? '',
                            timestamp: data['timestamp'],
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
  final String userId; // 👈 dùng gọi lại userID để đối chiếu với người tạo post
  final String name;
  final String profilePic;
  final String status;
  final List<String> comments;
  final List<String> likedUsers;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.userId, // 👈 Thêm dòng này
    required this.name,
    required this.profilePic,
    required this.status,
    required this.comments,
    required this.likedUsers,
    required this.timestamp,
  });

  int get likes => likedUsers.length;
  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      name: data['name'] ?? '',
      profilePic: data['profilePic'] ?? '',
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
      likedUsers: List<String>.from(data['likes'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      comments: [], // 🟢 BẮT BUỘC CÓ
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late List<String> likedUsers;
  final currentUser = FirebaseAuth.instance.currentUser;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 4,
      color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.profilePic),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      timeago.format(post.timestamp.toDate()),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.status,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        likedUsers.contains(currentUser?.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      onPressed: _likePost,
                    ),
                    Text(
                      '${likedUsers.length}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      color: isDark ? Colors.white : Colors.black,
                      onPressed: _goToDetail,
                    ),
                    if (currentUser?.uid == post.userId)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Xác nhận'),
                              content: const Text(
                                  'Bạn có chắc muốn xóa bài viết này không?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('forum')
                                .doc(post.id)
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa bài viết.')),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
