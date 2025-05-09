import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:study_app/models/bookmodel.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Image
            Image.network(
              book.image, // 🔁 sửa từ book.imageUrl => book.image
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Author
            Text(
              'Author: ${book.author}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              book.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Rating
            RatingBar.builder(
              initialRating: 4,
              minRating: 1,
              itemSize: 30,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print("Rating: $rating");
              },
            ),
            const SizedBox(height: 16),

            // Chapters
            const Text(
              'Chapters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10, // giả sử có 10 chương
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Chapter ${index + 1}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterPage(chapterIndex: index),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Comments Section
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // giả sử có 3 bình luận
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('User ${index + 1}'),
                  subtitle: const Text('This is a comment about the book.'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChapterPage extends StatelessWidget {
  final int chapterIndex;

  const ChapterPage({super.key, required this.chapterIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${chapterIndex + 1}'),
      ),
      body: Center(
        child: Text('Content of Chapter ${chapterIndex + 1}'),
      ),
    );
  }
}
