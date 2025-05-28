import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminCreatePostPage extends StatefulWidget {
  const AdminCreatePostPage({super.key});

  @override
  State<AdminCreatePostPage> createState() => _AdminCreatePostPageState();
}

class _AdminCreatePostPageState extends State<AdminCreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  // Hàm chọn ảnh
  Future<void> pickImage() async {
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
        await openAppSettings();
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

  // Hàm tạo bài viết
  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Vui lòng nhập đầy đủ tiêu đề và nội dung')),
      );
      return;
    }

    if (_selectedImage == null && _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Vui lòng chọn ảnh cho bài viết')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
        if (imageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      await FirebaseFirestore.instance.collection('news').add({
        'title': title,
        'content': content,
        'imageUrl': imageUrl ?? '',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đăng bài viết thành công')),
      );

      // Reset form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedImage = null;
        _imageUrl = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❗ Lỗi đăng bài: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm lấy màu nền và chữ dựa trên theme
  Color getInputBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBackgroundColor = getInputBackgroundColor(context);
    final textColor = getTextColor(context);
    final borderColor = getBorderColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Tạo bài viết'),
        backgroundColor: Colors.yellowAccent.shade700,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: inputBackgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nội dung bài viết',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: inputBackgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hình ảnh:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: inputBackgroundColor,
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.contain)
                      : _imageUrl != null && _imageUrl!.isNotEmpty
                      ? Image.network(
                    _imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('Không thể tải ảnh'),
                    ),
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
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.publish),
                  label: const Text('Đăng bài'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _createPost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}