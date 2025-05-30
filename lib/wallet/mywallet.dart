import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/chargemoney/withdram.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/wallet/buypackage.dart';
import '../chargemoney/history.dart';
import 'topup_form.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _money = 0;
  String _username = '';
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    //dùng uid để truy cấn document trong collection
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        _money = data['money'] ?? 0;
        _username = data['username'] ?? '';
        //Tạo đối tượng currentUser từ snapshot
        currentUser = UserModel.fromFirestore(snapshot);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hiển thị số tiền hiện có
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số tiền hiện có:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '${NumberFormat("#,###", "vi_VN").format(_money)} VNĐ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LessWidget: Form nạp tiền
            TopUpForm(username: _username),

            const SizedBox(height: 20),

            // LessWidget: Mua gói (làm sau)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.blueAccent
                  .withOpacity(0.3), // hiệu ứng splash nhẹ nhàng màu xanh
              highlightColor:
                  Colors.transparent, // tránh highlight mặc định gây khó chịu
              onTap: () {
                if (currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BuyPackagePage(currentUser: currentUser!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đang tải dữ liệu người dùng...')),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E3C72), // xanh đậm
                      Color(0xFF2A5298), // xanh lạnh
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Premium Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.orangeAccent.withOpacity(0.3),
              highlightColor: Colors.transparent,
              onTap: () {
                if (currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WithdrawPage(
                          userId: FirebaseAuth.instance.currentUser!.uid),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Vui lòng chờ tải thông tin người dùng...')),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF8008), // cam đậm
                      Color(0xFFFFC837), // vàng cam
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    '💸 Rút tiền',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.blueGrey.withOpacity(0.3),
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithdrawHistoryPage(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF232526), // xám đậm
                      Color(0xFF414345), // xám nhạt
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    '📜 Lịch sử rút tiền',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
