import 'package:cloud_firestore/cloud_firestore.dart';

class NewsPost {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;

  NewsPost({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory NewsPost.fromMap(Map<String, dynamic> map, String docId) {
    return NewsPost(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
