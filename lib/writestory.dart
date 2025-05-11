import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteStoryPage extends StatefulWidget {
  const WriteStoryPage({super.key});

  @override
  State<WriteStoryPage> createState() => _WriteStoryPageState();
}

class _WriteStoryPageState extends State<WriteStoryPage> {
  final TextEditingController _storyController = TextEditingController();

  Future<void> _submitStory() async {
    final storyText = _storyController.text.trim();
    if (storyText.isEmpty) return;

    await FirebaseFirestore.instance.collection('stories').add({
      'content': storyText,
      'createdAt': Timestamp.now(),
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

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
            TextField(
              controller: _storyController,
              decoration: const InputDecoration(
                labelText: 'Your Story',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitStory,
              child: const Text('Submit Story'),
            ),
          ],
        ),
      ),
    );
  }
}
