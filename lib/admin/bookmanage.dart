import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:study_app/services/adminservices/bookservice.dart';
import 'package:study_app/models/bookmodel.dart';

class BookManagePage extends StatefulWidget {
  const BookManagePage({super.key});

  @override
  _BookManagePageState createState() => _BookManagePageState();
}

class _BookManagePageState extends State<BookManagePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  String? _imageUrl;
  List<String> _selectedCategories = [];
  final List<MultiSelectItem<String>> _categoryItems = [
    'Adventure',
    'Comedy',
    'Fiction',
    'Fantasy',
    'Horror',
    'Drama',
    'Literature',
    'Manga',
  ].map((e) => MultiSelectItem<String>(e, e)).toList();
  bool isLocked = false;
  bool _isLoading = false;
  final BookService bookService = BookService();

// Hàm chọn ảnh
  Future<void> pickImage() async {
    // Kiểm tra quyền trên Android
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập ảnh bị từ chối')),
        );
        return;
      }
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền bị từ chối vĩnh viễn, vui lòng cấp quyền trong cài đặt')),
        );
        await openAppSettings(); // Mở cài đặt ứng dụng
        return;
      }
    }

    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        debugPrint('No image selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh được chọn')),
        );
        return;
      }
      setState(() {
        _selectedImage = File(image.path);
        _imageUrl = null;
      });
      debugPrint('Image selected: ${image.path}');
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

// Hàm upload ảnh lên Cloudinary
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final cloudName = 'drsawzehp';
      final uploadPreset = 'bookshop';
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final filename = imageFile.path.split('/').last;

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = '${DateTime.now().millisecondsSinceEpoch}_$filename'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('Image uploaded: ${data['secure_url']}');
        return data['secure_url'];
      } else {
        debugPrint('Upload failed: ${res.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload ảnh thất bại')),
        );
        return null;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi upload ảnh: $e')),
      );
      return null;
    }
  }

  // Hàm thêm/cập nhật sách
  Future<void> addOrUpdateBook({String? docId}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh cho sách')),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một danh mục')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imageUrl = _imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
        if (imageUrl == null) return;
      }

      final int price = isLocked ? int.parse(priceController.text.trim()) : 0;
      final newBook = Book(
        id: docId ?? '',
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        description: descriptionController.text.trim(),
        image: imageUrl!,
        categories: _selectedCategories,
        lock: isLocked,
        price: price,
      );

      if (docId != null && docId.isNotEmpty) {
        await bookService.updateBook(newBook);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sách thành công')),
        );
      } else {
        await bookService.addBook(newBook);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sách thành công')),
        );
      }

      // Reset form
      titleController.clear();
      authorController.clear();
      descriptionController.clear();
      priceController.clear();
      setState(() {
        _selectedCategories = [];
        _selectedImage = null;
        _imageUrl = null;
        isLocked = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm hiển thị dialog chỉnh sửa
  void showEditDialog(Book book) {
    titleController.text = book.title;
    authorController.text = book.author;
    descriptionController.text = book.description;
    priceController.text = book.price.toString();
    setState(() {
      _selectedCategories = List<String>.from(book.categories);
      _imageUrl = book.image;
      _selectedImage = null;
      isLocked = book.lock;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa sách'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Tác giả',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tác giả' : null,
                ),
                const SizedBox(height: 12),
                MultiSelectDialogField(
                  items: _categoryItems,
                  initialValue: _selectedCategories,
                  title: const Text('Danh mục'),
                  buttonText: const Text('Chọn danh mục'),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onConfirm: (values) {
                    setDialogState(() {
                      _selectedCategories = List<String>.from(values);
                    });
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                const Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : _imageUrl != null && _imageUrl!.isNotEmpty
                      ? Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('Không thể tải ảnh')),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                      : const Center(child: Text('Chưa có ảnh')),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await pickImage();
                          setDialogState(() {});
                        },
                        child: const Text('Chọn ảnh mới'),
                      ),
                    ),
                    if (_selectedImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            _selectedImage = null;
                            _imageUrl = null;
                          });
                          setState(() {});
                        },
                        child: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Khóa sách (yêu cầu xu)'),
                  value: isLocked,
                  activeColor: Colors.redAccent,
                  onChanged: (value) {
                    setDialogState(() {
                      isLocked = value;
                    });
                    setState(() {});
                  },
                ),
                if (isLocked)
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Giá (số xu)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập giá' : null,
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              addOrUpdateBook(docId: book.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Cho phép cuộn khi bàn phím xuất hiện
      appBar: AppBar(
        title: const Text('Admin - Quản lý sách'),
        backgroundColor: Colors.redAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thêm/Cập nhật sách',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: authorController,
                        decoration: InputDecoration(
                          labelText: 'Tác giả',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) => value!.isEmpty ? 'Vui lòng nhập tác giả' : null,
                      ),
                      const SizedBox(height: 12),
                      MultiSelectDialogField(
                        items: _categoryItems,
                        initialValue: _selectedCategories,
                        title: const Text('Danh mục'),
                        buttonText: const Text('Chọn danh mục'),
                        searchable: true,
                        listType: MultiSelectListType.CHIP,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        onConfirm: (values) {
                          setState(() {
                            _selectedCategories = List<String>.from(values);
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      const Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.contain)
                            : _imageUrl != null && _imageUrl!.isNotEmpty
                            ? Image.network(
                          _imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Không thể tải ảnh')),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        )
                            : const Center(child: Text('Chưa có ảnh')),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Chọn ảnh'),
                            ),
                          ),
                          if (_selectedImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _imageUrl = null;
                                });
                              },
                              child: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Khóa sách (yêu cầu xu)'),
                        value: isLocked,
                        activeColor: Colors.redAccent,
                        onChanged: (value) {
                          setState(() {
                            isLocked = value;
                          });
                        },
                      ),
                      if (isLocked)
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Giá (số xu)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) => value!.isEmpty ? 'Vui lòng nhập giá' : null,
                        ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: () => addOrUpdateBook(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Thêm sách', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Danh sách sách',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: StreamBuilder<List<Book>>(
                stream: bookService.getBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    debugPrint('Stream error: ${snapshot.error}');
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Chưa có sách nào'));
                  }

                  final books = snapshot.data!;
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Image.network(
                            book.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 50,
                                height: 50,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                          ),
                          title: Text(
                            book.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            book.author,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showEditDialog(book),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text('Bạn có chắc muốn xóa sách này?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await bookService.deleteBook(book.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Xóa sách thành công')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi xóa sách: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
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