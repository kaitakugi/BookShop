import 'package:flutter/material.dart';
import 'package:study_app/admin/bookmanage.dart';
import 'package:study_app/admin/usermanage.dart';
import 'package:study_app/admin/forumanage.dart';
import 'package:study_app/admin/approvedmoney.dart';
import 'package:study_app/admin/pendingbook.dart';
import 'package:study_app/login_register_page.dart';

import 'admincreatepostpage.dart';
// bạn cần import trang login/register

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<String> titles = [
    "Manage Books",
    "Manage Forum",
    "approve money transfer",
    "Pending Books",
    "Manage Users",
    "Post News",
  ];

  final List<Color> colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
  ];

  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Book Shelf"),
        actions: [
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(titles.length, (index) {
              return GestureDetector(
                onTap: () {
                  Widget targetPage;

                  switch (index) {
                    case 0:
                      targetPage =
                          const BookManagePage(bookIndex: 0, title: "Unknown");
                      break;
                    case 1:
                      targetPage = const AdminForumPage();
                      break;
                    case 2:
                      targetPage = const AdminTopUpApprovalScreen();
                      break;
                    case 3:
                      targetPage = const AdminPendingBooksPage();
                      break;
                    case 4:
                      targetPage = const UserManage();
                      break;
                    case 5:
                      targetPage = const AdminCreatePostPage();
                      break;
                    default:
                      targetPage =
                          const BookManagePage(bookIndex: 0, title: "Unknown");
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => targetPage),
                  );
                },
                onTapDown: (_) {
                  setState(() => hoveredIndex = index);
                },
                onTapUp: (_) {
                  setState(() => hoveredIndex = null);
                },
                onTapCancel: () {
                  setState(() => hoveredIndex = null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(8),
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, hoveredIndex == index ? -4 : 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.menu_book,
                          color: Colors.white, size: 32),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
