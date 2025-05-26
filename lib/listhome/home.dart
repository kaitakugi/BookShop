import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/listhome/attendance_page.dart';
import 'package:study_app/listhome/buybook_page.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/search/search.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/vip/vippage.dart';

import '../darkmode.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  bool isDarkMode = false; // trạng thái bật tắt

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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(

      //chế độ sáng tối
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Xin chào,",
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AttendancePage()),
                          ).then((_) => fetchUserData());
                        },
                        icon: Icon(Icons.add_circle, color: isDarkMode ? Colors.white70 : Colors.amber),
                        label: Text('${user?.coins ?? 0}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VipPage()),
                          );
                        },
                        icon: Icon(Icons.diamond, color: isDarkMode ? Colors.white70 : Colors.green[700]),
                        label: Text("VIP", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                user?.username ?? 'Người dùng',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Level Progress
              _buildCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.color_lens, color: isDarkMode ? Colors.white70 : Colors.green[700], size: 30),
                        const SizedBox(width: 10),
                        Text(
                          "Chế độ hiển thị",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        )

                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        });
                      },
                      icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                      label: Text(isDarkMode ? 'Sáng' : 'Tối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.amber : Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 16),

              // Book Stats
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.book_outlined, color: isDarkMode ? Colors.white70 : Colors.green[700], size: 30),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$unlockedCount of $totalCount',
                                    style: TextStyle(fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,)),
                                Text('Books unlocked',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.more_horiz, color: isDarkMode ? Colors.white : Colors.black,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuyBookPage(currentUser: user),
                              ),
                            ).then((_) => fetchUserData());
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(icon: Icons.menu_book, label: 'Books Read', value: '14'),
                        _buildStat(icon: Icons.timer, label: 'Reading', value: '40 min'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info Section
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin ứng dụng',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black,),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoItem(
                      icon: Icons.info,
                      title: 'Về chúng tôi',
                      content: 'Ứng dụng đọc sách mọi lúc, mọi nơi.',
                    ),
                    _buildInfoItem(
                      icon: Icons.contact_mail,
                      title: 'Liên hệ',
                      content: 'Email: contact@appdocsach.com\nHotline: 0123 456 789',
                    ),
                    _buildInfoItem(
                      icon: Icons.feedback,
                      title: 'Phản hồi',
                      content: 'Gửi phản hồi để chúng tôi cải thiện dịch vụ.',
                    ),
                    _buildInfoItem(
                      icon: Icons.star,
                      title: 'Đánh giá',
                      content: 'Đánh giá 5 sao để ủng hộ ứng dụng.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black45 : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStat({required IconData icon, required String label, required String value}) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      children: [
        Icon(icon, size: 30,
            color: isDarkMode ? Colors.white70 : Colors.green[700]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,)),
        Text(label, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String title, required String content}) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDarkMode ? Colors.white70 : Colors.green[700], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
