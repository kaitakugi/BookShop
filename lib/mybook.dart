import 'package:flutter/material.dart';

class MyBook extends StatefulWidget {
  const MyBook({super.key});

  @override
  State<MyBook> createState() => _MyBookState();
}

class _MyBookState extends State<MyBook> {
  List<String> readBooks = ["Đắc Nhân Tâm", "Sherlock Holmes"]; // test data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Viết truyện',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WriteStoryPage()),
              );
            },
          )
        ],
      ),
      body: readBooks.isEmpty
          ? const Center(child: Text('Bạn chưa đọc cuốn sách nào.'))
          : ListView.builder(
              itemCount: readBooks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(readBooks[index]),
                );
              },
            ),
    );
  }
}

// Trang viết truyện (đơn giản trước)
class WriteStoryPage extends StatelessWidget {
  const WriteStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viết truyện')),
      body: const Center(
        child: Text('Nơi bạn có thể viết truyện của riêng mình.'),
      ),
    );
  }
}
