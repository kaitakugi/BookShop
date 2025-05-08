import 'package:flutter/material.dart';
import 'package:study_app/postdetail.dart'; // Import File for image handling

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  _ForumState createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final List<Post> posts = []; // List to store forum posts
  final TextEditingController _postController = TextEditingController();

  void _addPost() {
    if (_postController.text.isNotEmpty) {
      setState(() {
        posts.add(Post(
          name: 'User ${posts.length + 1}', // Simulating a user name
          profilePic:
              'https://www.example.com/profile-pic.jpg', // Placeholder image
          status: _postController.text,
          comments: [], // Empty list of comments
        ));
      });
      _postController.clear(); // Clear input after posting
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
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: posts[index]);
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
  final String name;
  final String profilePic;
  final String status;
  final List<String> comments;
  int likes;

  Post({
    required this.name,
    required this.profilePic,
    required this.status,
    required this.comments,
    this.likes = 0,
  });
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  void _likePost() {
    setState(() {
      widget.post.likes += 1;
    });
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
                Text(post.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.status),
            const SizedBox(height: 10),
            // NEW: Row chứa like + comment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: _likePost,
                      color: Colors.red,
                    ),
                    Text('${post.likes} Likes'),
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

class WriteStoryPage extends StatelessWidget {
  const WriteStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write Your Story')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Write your story below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Your Story',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Here you can implement story saving or submission logic
                Navigator.pop(context); // Navigate back to the Forum
              },
              child: const Text('Submit Story'),
            ),
          ],
        ),
      ),
    );
  }
}
