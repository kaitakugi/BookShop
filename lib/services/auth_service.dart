import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký người dùng mới
  Future<User?> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    try {
      // Đăng ký tài khoản Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'display_name': displayName,
        'created_at': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      print("Đăng ký thất bại: $e");
      return null;
    }
  }

  // Đăng nhập người dùng
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Đăng nhập thất bại: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
