import 'package:flutter/material.dart';
import 'package:study_app/profile/infopage.dart';
import 'package:study_app/storagefavour/storagefavour.dart';
import 'package:study_app/wallet/mywallet.dart';
import '../login_register_page.dart';
import '../models/usermodel.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfilePage createState() => ProfilePage();
}

class ProfilePage extends State<Profile> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          setState(() {
            user = UserModel(
              username: doc['username'],
              email: doc['email'],
              password: '',
            );
            isLoading = false;
          });
        } else {
          setState(() {
            user = null;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          user = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu Firestore: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải dữ liệu người dùng')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Hiển thị khi loading
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/300'),
                    ),
                    const SizedBox(height: 10),
                    // Kiểm tra null trước khi truy cập vào user
                    Text(
                      user?.username ??
                          "Tên người dùng", // Thêm giá trị mặc định nếu user là null
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ??
                          "Email người dùng", // Thêm giá trị mặc định nếu user là null
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 30),
                    _buildProfileItem(Icons.person, "Thông tin cá nhân",
                        () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InfoPage()),
                      );

                      if (result != null && result is UserModel) {
                        setState(() {
                          user = result;
                        });
                      }
                    }),
                    _buildProfileItem(
                        Icons.account_balance_wallet, "Ví của tôi", () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    }),
                    _buildProfileItem(Icons.bookmark, "Mục đã lưu", () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StorageFavour()),
                      );
                    }),
                    _buildProfileItem(Icons.settings, "Cài đặt"),
                    _buildProfileItem(Icons.help_outline, "Trợ giúp & Hỗ trợ"),
                    const SizedBox(height: 30),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
