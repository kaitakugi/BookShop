import 'package:flutter/material.dart';
// import 'models/usermodel.dart'; // Đừng quên import UserModel
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool isEditing = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String originalName = '';
  String originalEmail = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        setState(() {
          nameController.text = doc['username'];
          emailController.text = doc['email'];
          passwordController.text = '********';

          originalName = doc['username'];
          originalEmail = doc['email'];
        });
      }
    }
  }

  Future<void> updateUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'username': nameController.text,
          'email': emailController.text,
        });

        if (emailController.text != originalEmail) {
          await currentUser.updateEmail(emailController.text);
        }

        if (passwordController.text != '********' &&
            passwordController.text.isNotEmpty) {
          await currentUser.updatePassword(passwordController.text);
        }
      } catch (e) {
        print('Lỗi khi cập nhật: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi cập nhật thông tin')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Tên người dùng", nameController, isEditing),
            _buildTextField("Email", emailController, isEditing),
            _buildPasswordField("Mật khẩu", passwordController, isEditing),
            if (isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await updateUserData();

                      if (!mounted) return;

                      setState(() {
                        isEditing = false;
                      });

                      await fetchUserData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Thông tin đã được cập nhật thành công.')),
                      );
                    },
                    child: const Text("Lưu"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                      fetchUserData();
                    },
                    child: const Text("Hủy"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isEnabled,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: isPassword ? const Icon(Icons.lock) : null,
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool isEnabled) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Mật khẩu',
        suffixIcon: Icon(Icons.lock),
      ),
    );
  }
}
