import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../darkmode.dart';

class WriteMyBookPage extends StatefulWidget {
  final String? bookId;
  final Map<String, dynamic>? initialData;

  const WriteMyBookPage({super.key, this.bookId, this.initialData});

  @override
  State<WriteMyBookPage> createState() => _UserWriteBookPageState();
}

class _UserWriteBookPageState extends State<WriteMyBookPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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
  ].map((e) => MultiSelectItem(e, e)).toList();

  bool _isLoading = false;
  File? _selectedImage;
  String? _imageUrl;

  Future<void> pickImage() async {
    if (Platform.isAndroid) {
      int sdkInt = int.tryParse(Platform.version.split(' ').first) ?? 0;

      if (sdkInt >= 33) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          print('Permission denied');
          return;
        }
      } else {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Permission denied');
          return;
        }
      }
    }

    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Chọn ảnh: ${image.path}');
      setState(() {
        _selectedImage = File(image.path); // 👉 Gán ảnh đã chọn vào biến
        _imageUrl = null; // Nếu bạn muốn thay thế ảnh cũ (nếu đang sửa sách)
      });
    } else {
      print('Không chọn ảnh');
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final cloudName = 'drsawzehp';
      final uploadPreset = 'bookshop';

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final filename = imageFile.path.split('/').last;

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = filename // 🟢 Đảm bảo Cloudinary dùng tên file
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['secure_url']; // ✅ Link ảnh sau khi upload thành công
      } else {
        print('Upload lỗi: ${res.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi upload Cloudinary: $e');
      return null;
    }
  }

  Future<void> _submitBook() async {
    final user = FirebaseAuth.instance.currentUser;

    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để gửi sách')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Nếu có ảnh mới => upload lên Firebase Storage
      String? imageUrl = _imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final booksRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books');

      final bookData = {
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'categories': _selectedCategories,
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl ?? '',
      };

      if (widget.bookId != null) {
        await booksRef.doc(widget.bookId).update(bookData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sách thành công!')),
        );
      } else {
        await booksRef.add({
          ...bookData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi sách thành công!')),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi sách: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      titleController.text = widget.initialData!['title'] ?? '';
      authorController.text = widget.initialData!['author'] ?? '';
      _selectedCategories =
          List<String>.from(widget.initialData!['categories'] ?? []);
      descriptionController.text = widget.initialData!['description'] ?? '';
      _imageUrl = widget.initialData!['imageUrl'] ?? '';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookId != null;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sách' : 'Gửi sách của bạn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildTextField(
                        'Tên sách *', titleController, Icons.book, textColor),
                    buildTextField(
                        'Tác giả *', authorController, Icons.person, textColor),
                    buildCategorySelector(textColor, isDarkMode),
                    buildTextField('Mô tả *', descriptionController,
                        Icons.description, textColor,
                        maxLines: 3),
                    const SizedBox(height: 10),
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, height: 150),
                      )
                    else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_imageUrl!, height: 150),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Chọn ảnh bìa'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitBook,
                icon: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(isEditing ? 'Cập nhật sách' : 'Gửi sách'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySelector(Color textColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, color: textColor),
                  const SizedBox(width: 8),
                  Text("Thể loại *",
                      style: TextStyle(color: textColor, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Theme(
                data: isDarkMode
                    ? ThemeData.dark().copyWith(
                        textTheme: const TextTheme(
                          titleLarge: TextStyle(color: Colors.white),
                          bodyMedium: TextStyle(
                              color: Colors.white), // label của các thể loại
                        ),
                        checkboxTheme: CheckboxThemeData(
                          fillColor: WidgetStatePropertyAll(Colors.blue),
                          checkColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        unselectedWidgetColor: Colors.white, // viền checkbox
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.white,
                          onPrimary: Colors.white,
                          surface: Colors.black,
                          onSurface: Colors.white,
                        ),
                        dialogTheme:
                            DialogThemeData(backgroundColor: Colors.grey[900]),
                      )
                    : ThemeData.light(),
                child: MultiSelectDialogField(
                  items: _categoryItems,
                  initialValue: _selectedCategories,
                  title: const Text("Chọn thể loại"),
                  onConfirm: (values) {
                    _selectedCategories = List<String>.from(values);
                  },
                  buttonText: Text(
                    "Chọn thể loại",
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  itemsTextStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  selectedItemsTextStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black, // 👈 fix quan trọng
                  ),
                  selectedColor: Colors.blue,
                  checkColor: Colors.white,
                  dialogWidth: MediaQuery.of(context).size.width * 0.8,
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: Colors.blue.withOpacity(0.2),
                    textStyle: TextStyle(color: textColor),
                    onTap: (value) {
                      setState(() {
                        _selectedCategories.remove(value);
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      IconData icon, Color textColor,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
