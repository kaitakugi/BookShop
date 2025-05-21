import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/models/usermodel.dart';

class BuyPackagePage extends StatefulWidget {
  final UserModel currentUser;

  const BuyPackagePage({super.key, required this.currentUser});

  @override
  State<BuyPackagePage> createState() => _BuyPackagePageState();
}

class _BuyPackagePageState extends State<BuyPackagePage> {
  bool isWeekPurchased = false;
  bool isMonthPurchased = false;

  @override
  void initState() {
    super.initState();
    checkPremiumStatus();
  }

  Future<void> checkPremiumStatus() async {
    final expiry = widget.currentUser.premiumExpiry;
    final now = DateTime.now();

    if (expiry != null && expiry.isAfter(now)) {
      final duration = expiry.difference(now).inDays;
      setState(() {
        if (duration <= 7) {
          isWeekPurchased = true;
        } else {
          isMonthPurchased = true;
        }
      });
    }
  }

  void updatePremiumStatus(BuildContext context, int price, Duration duration,
      String packageType) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (widget.currentUser.money < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đủ tiền để mua gói!')),
      );
      return;
    }

    if ((packageType == "week" && isMonthPurchased) ||
        (packageType == "month" && isWeekPurchased)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã mua gói khác. Hãy đợi hết hạn!')),
      );
      return;
    }

    final now = DateTime.now();
    final expiryDate = now.add(duration);

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'premiumExpiry': Timestamp.fromDate(expiryDate),
        'money': widget.currentUser.money - price,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mua gói thành công!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Widget buildPackageCard({
    required String title,
    required String price,
    required VoidCallback onBuy,
    required bool isPurchased,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // vàng trầm nhạt
        border: Border.all(
            color: const Color(0xFFFFD600), width: 2), // viền vàng đậm
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Giá: $price', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isPurchased ? null : onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPurchased ? Colors.grey : Colors.amber,
                ),
                child: Text(isPurchased ? 'Đã mua' : 'Mua ngay'),
              ),
            ],
          ),
          if (isPurchased)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.check_circle, color: Colors.green, size: 28),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Chọn gói muốn mua:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            buildPackageCard(
              title: 'Gói tuần (7 ngày)',
              price: '29.000₫',
              onBuy: () => updatePremiumStatus(
                context,
                29000,
                const Duration(days: 7),
                "week",
              ),
              isPurchased: isWeekPurchased,
            ),
            buildPackageCard(
              title: 'Gói tháng (30 ngày)',
              price: '99.000₫',
              onBuy: () => updatePremiumStatus(
                context,
                99000,
                const Duration(days: 30),
                "month",
              ),
              isPurchased: isMonthPurchased,
            ),
          ],
        ),
      ),
    );
  }
}
