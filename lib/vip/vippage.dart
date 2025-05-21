import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:study_app/models/usermodel.dart';

class VipPage extends StatelessWidget {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Bạn chưa đăng nhập"));

    final userVipCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vip_purchases');

    final List<String> vipLevels = ['vip1', 'vip2', 'vip3'];

    return Scaffold(
      appBar: AppBar(title: const Text("Shop VIP")),
      body: StreamBuilder<QuerySnapshot>(
        stream: userVipCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final purchasedVips =
              snapshot.data!.docs.map((doc) => doc.id).toSet();

          return GridView.count(
            crossAxisCount: 1,
            padding: const EdgeInsets.all(16),
            childAspectRatio: 2.1,
            children: vipLevels.map((vipId) {
              final isPurchased = purchasedVips.contains(vipId);
              return VipCard(
                vipId: vipId,
                isPurchased: isPurchased,
                onBuy: () async {
                  final userDocRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid);

                  final userSnapshot = await userDocRef.get();
                  final userModel = UserModel.fromFirestore(userSnapshot);

                  const vipPrices = {
                    'vip1': 100000,
                    'vip2': 500000,
                    'vip3': 1000000,
                  };

                  final int price = vipPrices[vipId] ?? 0;

                  if (userModel.money >= price) {
                    // Trừ tiền và cập nhật
                    await userDocRef.update({
                      'money': userModel.money - price,
                    });

                    // Đánh dấu đã mua
                    await userVipCollection.doc(vipId).set({'purchased': true});

                    // Thông báo thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mua gói $vipId thành công!')),
                    );
                  } else {
                    // Không đủ tiền
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Bạn không đủ tiền để mua gói VIP này')),
                    );
                  }
                },
                onDetails: () {
                  if (isPurchased) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VipDetailPage(vipId: vipId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bạn chưa mua gói VIP này')),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class VipCard extends StatelessWidget {
  final String vipId;
  final bool isPurchased;
  final VoidCallback onBuy;
  final VoidCallback onDetails;

  const VipCard({
    super.key,
    required this.vipId,
    required this.isPurchased,
    required this.onBuy,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final vipPrices = {
      'vip1': 100000,
      'vip2': 500000,
      'vip3': 1000000,
    };

    return FlipCard(
      front: Card(
        elevation: 4,
        color: Colors.blue.shade100,
        child: Center(
          child: Text(
            vipId.toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      back: Card(
        color: Colors.amber.shade100,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Đặc quyền của $vipId",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "${vipPrices[vipId]!.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} VNĐ",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (isPurchased)
                  const Text("✅ Bạn đã mua gói này",
                      style: TextStyle(color: Colors.green))
                else
                  ElevatedButton(
                    onPressed: onBuy,
                    child: const Text("Mua"),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isPurchased ? onDetails : null,
                  child: const Text("Xem chi tiết"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VipDetailPage extends StatelessWidget {
  final String vipId;

  const VipDetailPage({super.key, required this.vipId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết $vipId")),
      body: Center(
        child: Text("Chi tiết quyền lợi của $vipId ở đây"),
      ),
    );
  }
}
