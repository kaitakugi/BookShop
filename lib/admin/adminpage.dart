import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/admin/bookmanage.dart';
import 'package:study_app/admin/usermanage.dart';
import 'package:study_app/admin/forumanage.dart';
import 'package:study_app/admin/approvedmoney.dart';
import 'package:study_app/admin/pendingbook.dart';
import 'package:study_app/login_register_page.dart';
import 'package:study_app/admin/admincreatepostpage.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Quản lý sách',
      'color': Colors.redAccent,
      'page': const BookManagePage(),
      'icon': Icons.library_books,
    },
    {
      'title': 'Quản lý diễn đàn',
      'color': Colors.greenAccent,
      'page': const AdminForumPage(),
      'icon': Icons.forum,
    },
    {
      'title': 'Phê duyệt nạp tiền',
      'color': Colors.blueAccent,
      'page': const AdminTopUpApprovalScreen(),
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Sách chờ duyệt',
      'color': Colors.orangeAccent,
      'page': const AdminPendingBooksPage(),
      'icon': Icons.pending_actions,
    },
    {
      'title': 'Quản lý người dùng',
      'color': Colors.purpleAccent,
      'page': const UserManage(),
      'icon': Icons.people,
    },
    {
      'title': 'Đăng tin tức',
      'color': Colors.yellowAccent.shade700,
      'page': const AdminCreatePostPage(),
      'icon': Icons.post_add,
    },
  ];

  int? hoveredIndex;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  // Kiểm tra quyền admin
  Future<void> _checkAdminRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _isAdmin = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _isAdmin = userDoc.data()?['role'] == 'admin';
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kiểm tra quyền: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  // Xác nhận đăng xuất
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng xuất: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Bạn không có quyền truy cập trang này')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Kệ sách'),
        backgroundColor: Colors.redAccent,
        elevation: 4,
        actions: [
          TextButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, size: 20, color: Colors.white),
            label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final item = _menuItems[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                try {
                  debugPrint('Navigating to: ${item['title']}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page']),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi điều hướng đến ${item['title']}: $e')),
                  );
                }
              },
              onTapDown: (_) => setState(() => hoveredIndex = index),
              onTapUp: (_) => setState(() => hoveredIndex = null),
              onTapCancel: () => setState(() => hoveredIndex = null),
              child: Card(
                elevation: hoveredIndex == index ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: item['color'],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}