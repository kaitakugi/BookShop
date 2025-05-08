import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:study_app/search.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  BookDetailPage({required this.book});

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
              book.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),

            // Title
            Text(
              book.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Rating
            RatingBar.builder(
              initialRating: 4,
              minRating: 1,
              itemSize: 30,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
            SizedBox(height: 16),

            // Chapters
            Text(
              'Chapters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // giả sử có 10 chương
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Chapter ${index + 1}'),
                  onTap: () {
                    // Navigate to chapter page
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
            SizedBox(height: 16),

            // Comments Section
            Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 3, // giả sử có 3 bình luận
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('User ${index + 1}'),
                  subtitle: Text('This is a comment about the book.'),
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

  ChapterPage({required this.chapterIndex});

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
