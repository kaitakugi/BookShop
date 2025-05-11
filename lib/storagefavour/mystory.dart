import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyStoriesPage extends StatelessWidget {
  const MyStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Có lỗi xảy ra'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có truyện nào.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final content = data['content'] ?? '';
            final createdAt = (data['createdAt'] as Timestamp).toDate();

            return ListTile(
              leading: const Icon(Icons.note_alt),
              title:
                  Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}
