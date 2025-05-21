import 'package:flutter/material.dart';

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
