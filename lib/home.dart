import 'package:flutter/material.dart';
import 'package:study_app/listhome/attendance_page.dart';
import 'package:study_app/listhome/buybook_page.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/search.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

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
          child: Image.network(
            "https://img.freepik.com/free-vector/hand-drawn-cardinal-cartoon-illustration_52683-129480.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip",
            fit: BoxFit.cover,
          ),
        ),

        // App bar (top)
        Positioned(
          top: 50,
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
                      onPressed: () {},
                      icon: const Icon(Icons.translate, color: Colors.green),
                      label: const Text("ENG"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),

        // Welcome Text
        Positioned(
          top: 180,
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
          top: 300,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
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
                          child: Image.network(
                            'https://img.freepik.com/free-vector/school-timetable-template_1308-32663.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip',
                            width: 42,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('10 of 120',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Day challenge'),
                          ],
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BuyBookPage()),
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
                            child: Image.network(
                              'https://img.freepik.com/free-vector/open-book-with-nature-scene_1308-171788.jpg',
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
                            child: Image.network(
                              'https://img.freepik.com/free-photo/clock-cartoon-illustration_23-2151470825.jpg',
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
        Positioned(
          top: 540,
          width: width,
          child: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Book category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
