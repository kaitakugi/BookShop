import 'package:flutter/material.dart';
import 'package:study_app/listhome/attendance_page.dart';
import 'package:study_app/listhome/buybook_page.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/search/search.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/vip/vippage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  //cập nhật 2 thông số để xác định sách đã mở và tổng số sách trong book vipvip
  int unlockedCount = 0;
  int totalCount = 0;

  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Gọi hàm tải dữ liệu khi widget khởi tạo
  }

  //hàm fetch data để lấy dữ liệu từ firestore
  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            user = null;
            isLoading = false;
          });
        }
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Lấy danh sách ID sách đã mở khóa
      final unlockedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('unlockedBooks')
          .get();

      // Lấy tất cả sách cần xu để mở
      final lockedBooksSnap = await FirebaseFirestore.instance
          .collection('books')
          .where('lock', isEqualTo: true)
          .where('price', isGreaterThan: 0)
          .get();

      // Lọc sách đã mở khóa trong danh sách cần xu
      final unlockedBookIds = unlockedSnap.docs.map((doc) => doc.id).toSet();
      final unlockedLockedBooks = lockedBooksSnap.docs
          .where((doc) => unlockedBookIds.contains(doc.id))
          .toList();

      if (mounted) {
        setState(() {
          user = userDoc.exists
              ? UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
              : null;
          unlockedCount = unlockedLockedBooks.length;
          totalCount = lockedBooksSnap.size;
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

  void handleSearch() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Search()));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background image
        SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            "assets/images/parrot.avif",
            fit: BoxFit.cover,
          ),
        ),
        // App bar (top)
        Positioned(
          top: 25,
          left: 0,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left part
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble,
                          color: Colors.green[700], size: 30),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Level 2",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            width: 60,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE45B00),
                                  Color(0xFFD98B56),
                                  Color(0xFFDDDDDD),
                                  Color(0xFFDDDDDD),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Right part
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AttendancePage()),
                        ).then((_) =>
                            fetchUserData()); // reload lại coin sau khi điểm danh
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.amber),
                      label: Text('${user?.coins ?? 0}'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VipPage()),
                        );
                      },
                      icon: const Icon(Icons.diamond, color: Colors.green),
                      label: const Text("VIP"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),

        // Welcome Text
        Positioned(
          top: 160,
          width: width,
          child: Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 24, color: Colors.black),
                children: [
                  const TextSpan(text: 'Welcome back '),
                  TextSpan(
                    text: user?.username ?? 'Tên người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Stats Card
        Positioned(
          top: 260,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/images/lich.avif',
                            width: 42,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$unlockedCount of $totalCount',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Bookshop Coins'),
                          ],
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyBookPage(
                              currentUser: user,
                            ),
                          ),
                        ).then((_) =>
                            fetchUserData()); // để cập nhật xu nếu người dùng mua sách
                      },
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 2, color: Colors.black),

                // Bottom section
                const Text('So for today',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/nha.avif',
                              width: 42,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('14',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Books read'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/clock.avif',
                              width: 42,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('40 min',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Learning time'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Book Category Title
        // Thay thế phần Book Category Title và thêm ScrollView
        Positioned(
          top: 500,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              height: 300, // hoặc dùng MediaQuery nếu muốn responsive
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin ứng dụng',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(
                            icon: Icons.info,
                            title: 'Về chúng tôi',
                            content:
                                'Ứng dụng đọc sách giúp bạn đọc hàng ngàn đầu sách mọi lúc, mọi nơi.',
                          ),
                          _buildInfoItem(
                            icon: Icons.contact_mail,
                            title: 'Liên hệ',
                            content:
                                'Email: contact@appdocsach.com\nHotline: 0123 456 789',
                          ),
                          _buildInfoItem(
                            icon: Icons.feedback,
                            title: 'Phản hồi',
                            content:
                                'Gửi phản hồi để chúng tôi cải thiện chất lượng dịch vụ.',
                          ),
                          _buildInfoItem(
                            icon: Icons.star,
                            title: 'Đánh giá',
                            content:
                                'Đánh giá 5 sao để ủng hộ đội ngũ phát triển ứng dụng.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
