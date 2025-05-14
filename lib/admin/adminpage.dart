import 'package:flutter/material.dart';
import 'package:study_app/services/bookservice.dart';
import 'package:study_app/login_register_page.dart';
import 'package:study_app/models/bookmodel.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final BookService bookService = BookService(); // Tạo instance của BookService

  bool isLocked = false;

  void addOrUpdateBook({String? docId}) async {
    if (titleController.text.isNotEmpty &&
        authorController.text.isNotEmpty &&
        imageController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      final newBook = Book(
        id: docId ?? '',
        title: titleController.text,
        author: authorController.text,
        description: descriptionController.text,
        image: imageController.text,
        category: categoryController.text,
        lock: isLocked,
      );

      if (docId != null && docId.isNotEmpty) {
        // Cập nhật sách
        await bookService.updateBook(newBook);
      } else {
        // Thêm sách mới
        await bookService.addBook(newBook);
      }

      // Xóa dữ liệu trong các TextField sau khi thêm/sửa
      titleController.clear();
      authorController.clear();
      imageController.clear();
      descriptionController.clear();
      categoryController.clear();
      isLocked = false;
      setState(() {});
    }
  }

  void showEditDialog(Book book) {
    titleController.text = book.title;
    authorController.text = book.author;
    categoryController.text = book.category;
    imageController.text = book.image;
    descriptionController.text = book.description;
    isLocked = book.lock; // 👈 load trạng thái khoá của sách cần sửa

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Book Title')),
              TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author')),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL')),
              SwitchListTile(
                title: const Text('Khóa sách (yêu cầu xu)'),
                value: isLocked,
                onChanged: (value) {
                  setState(() {
                    isLocked = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              addOrUpdateBook(docId: book.id); // Cập nhật hoặc thêm sách
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Manage Books')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Book Title')),
            TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author')),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL')),
            SwitchListTile(
              title: const Text('Khóa sách (yêu cầu xu)'),
              value: isLocked,
              onChanged: (value) {
                setState(() {
                  isLocked = value;
                });
              },
            ),
            ElevatedButton(
                onPressed: () => addOrUpdateBook(), // Thêm sách mới
                child: const Text('Add Book')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginRegisterPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng Xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Book>>(
                stream:
                    bookService.getBooks(), // Lấy danh sách sách từ Firestore
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final books = snapshot.data!;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return ListTile(
                        leading: Image.network(
                          book.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => showEditDialog(book)),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await bookService
                                    .deleteBook(book.id); // Xoá sách
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
