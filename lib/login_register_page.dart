import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/admin/adminpage.dart';
import 'package:study_app/main.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> registerUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        showSnackbar('Vui lòng nhập đầy đủ thông tin');
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now(),
        'role': 'user',
      });

      showSnackbar('Đăng ký thành công! Vui lòng đăng nhập.');
      await FirebaseAuth.instance.signOut();
      setState(() => isLogin = true);
    } on FirebaseAuthException catch (e) {
      showSnackbar(switchErrorMessage(e));
    } catch (e) {
      showSnackbar('Lỗi khác: $e');
    }
  }

  Future<void> loginUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) throw Exception('Không tìm thấy người dùng');

      String role = userDoc['role'] ?? 'user';

      if (role == 'admin') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AdminPage()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      showSnackbar(switchErrorMessage(e));
    } catch (e) {
      showSnackbar('Lỗi khác: $e');
    }
  }

  String switchErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      default:
        return 'Lỗi: ${e.message}';
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget buildForm() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Card nền
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.2),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80), // chừa chỗ cho nút
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (!isLogin)
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: inputDecoration('Tên người dùng', Icons.person),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: inputDecoration('Email', Icons.email),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: inputDecoration('Mật khẩu', Icons.lock),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() => isLogin = !isLogin);
                  },
                  child: Text(
                    isLogin
                        ? 'Bạn chưa có tài khoản? Đăng ký'
                        : 'Bạn đã có tài khoản? Đăng nhập',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10)
              ],
            ),
          ),
        ),

        // Nút nổi bên dưới card
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            onPressed: isLogin ? loginUser : registerUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.5),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            child: Text(
              isLogin ? 'Đăng Nhập' : 'Đăng Ký',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      border: const OutlineInputBorder(),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ảnh nền
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vuon.jpeg', // 👉 thay tên file theo ảnh bạn có
              fit: BoxFit.cover,
            ),
          ),

          // Lớp phủ mờ mờ (blur + tối nhẹ)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.black.withOpacity(0)),
              ),
            ),
          ),

          // Form nằm giữa
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: buildForm(), // Giữ nguyên form bạn đã viết
            ),
          )
        ],
      ),
    );
  }
}
