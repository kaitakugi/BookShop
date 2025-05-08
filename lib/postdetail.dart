import 'package:flutter/material.dart';
import 'package:study_app/forum.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  void _addComment() {
    final text = _commentController.text;
    if (text.isNotEmpty) {
      setState(() {
        widget.post.comments.add(text);
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    Future<void> _likePost() async {
      // Giả lập tăng like, bạn cần thay bằng gọi API thật
      setState(() {
        widget.post.likes += 1;
      });

      // TODO: Gửi request HTTP đến server để cập nhật database
      // Ví dụ dùng `http` package:
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/posts/${widget.post.id}/like'),
      );

      if (response.statusCode == 200) {
        // Có thể cập nhật số like từ response nếu cần
      }
      */
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị bài viết
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () async {
                    await _likePost(); // Gửi request lên server
                  },
                ),
                Text('${post.likes} Likes'),
              ],
            ),

            const Divider(height: 30),
            const Text("Comments:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Hiển thị các comment
            Expanded(
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.comment),
                    title: Text(post.comments[index]),
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
