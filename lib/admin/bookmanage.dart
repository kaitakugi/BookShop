import 'package:flutter/material.dart';
import 'package:study_app/services/adminservices/bookservice.dart';
import 'package:study_app/models/bookmodel.dart';

class BookManagePage extends StatefulWidget {
  const BookManagePage(
      {super.key, required int bookIndex, required String title});

  @override
  _BookManagePage createState() => _BookManagePage();
}

class _BookManagePage extends State<BookManagePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final BookService bookService = BookService(); // Tạo instance của BookService

  bool isLocked = false;

  void addOrUpdateBook({String? docId}) async {
    if (titleController.text.isNotEmpty &&
        authorController.text.isNotEmpty &&
        imageController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      final int price =
          isLocked ? int.tryParse(priceController.text.trim()) ?? 0 : 0;

      final newBook = Book(
        id: docId ?? '',
        title: titleController.text,
        author: authorController.text,
        description: descriptionController.text,
        image: imageController.text,
        category: categoryController.text,
        lock: isLocked,
        price: price,
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
      priceController.clear();
    }
  }

  void showEditDialog(Book book) {
    titleController.text = book.title;
    authorController.text = book.author;
    categoryController.text = book.category;
    imageController.text = book.image;
    descriptionController.text = book.description;
    isLocked = book.lock;
    priceController.text = book.price.toString(); // 👈 Thêm dòng này
    // 👈 load trạng thái khoá của sách cần sửa

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
              Visibility(
                visible: isLocked,
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá (số xu)'),
                ),
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
      appBar: AppBar(
        title: const Text('Admin - Manage Books'),
        backgroundColor: Colors.redAccent,
      ),
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
            Visibility(
              visible: isLocked,
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá (số xu)'),
              ),
            ),
            ElevatedButton(
                onPressed: () => addOrUpdateBook(), // Thêm sách mới
                child: const Text('Add Book')),
            const SizedBox(height: 20),
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
