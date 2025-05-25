import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/adminpostmodel.dart';

class NewsPostService {
  final CollectionReference postsRef =
  FirebaseFirestore.instance.collection('news_posts');

  Future<void> addPost(NewsPost post) {
    return postsRef.add(post.toMap());
  }

  Stream<List<NewsPost>> getPosts() {
    return postsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          return NewsPost.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      },
    );
  }
}
