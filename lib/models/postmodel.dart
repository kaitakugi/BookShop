import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String name;
  final String profilePic;
  final String status;
  final List<String> comments;
  final String docId;
  int likes;

  Post({
    required this.name,
    required this.profilePic,
    required this.status,
    required this.comments,
    required this.docId,
    this.likes = 0,
  });
}
