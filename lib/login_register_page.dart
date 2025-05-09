import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/admin/adminpage.dart';
import 'package:study_app/main.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;

  // Controllers để lấy giá trị từ TextField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Đăng ký người dùng
  Future<void> registerUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Lưu thông tin vào Firestore
      print("Đang ghi user vào Firestore...");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now(),
        'role': 'user', // ← thêm dòng này để tránh lỗi thiếu role
      });

      print("Ghi thành công!");

      // Sau khi đăng ký, chuyển sang form đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
      );
      await FirebaseAuth.instance.signOut();
      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email đã được sử dụng.';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ.';
          break;
        case 'weak-password':
          errorMessage = 'Mật khẩu quá yếu.';
          break;
        default:
          errorMessage = 'Lỗi không xác định: ${e.message}';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khác: $e')));
    }
  }

  // Đăng nhập người dùng
  Future<void> loginUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('Không tìm thấy thông tin người dùng trong Firestore');
      }

      String role =
          userDoc['role'] ?? 'user'; // nếu không có role thì mặc định là user

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy người dùng.';
          break;
        case 'wrong-password':
          errorMessage = 'Sai mật khẩu.';
          break;
        default:
          errorMessage = 'Lỗi đăng nhập: ${e.message}';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khác: $e')));
    }
  }

  // Widget đăng nhập
  Widget buildLoginForm() {
    return Column(
      children: [
        const Text("Đăng Nhập",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Mật khẩu'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: loginUser,
          child: const Text('Đăng nhập'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = false;
            });
          },
          child: const Text("Bạn chưa có tài khoản? Đăng ký"),
        )
      ],
    );
  }

  // Widget đăng ký
  Widget buildRegisterForm() {
    return Column(
      children: [
        const Text("Đăng Ký",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Tên người dùng'),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Mật khẩu'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: registerUser, // Gọi phương thức đăng ký
          child: const Text('Đăng ký'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = true;
            });
          },
          child: const Text("Bạn đã có tài khoản? Đăng nhập"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: isLogin ? buildLoginForm() : buildRegisterForm(),
        ),
      ),
    );
  }
}
