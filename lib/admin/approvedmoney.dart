import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTopUpApprovalScreen extends StatelessWidget {
  const AdminTopUpApprovalScreen({super.key});

  void _approveRequest(DocumentSnapshot requestDoc) async {
    final uid = requestDoc['uid'];
    final amount = requestDoc['amount'];

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userRef.get();

    final userData = userSnapshot.data();

    final currentMoney = userData?['money'] ?? 0;

    // Cập nhật tiền trong tài khoản người dùng
    await userRef.update({'money': currentMoney + amount});

    // Xoá yêu cầu nạp sau khi duyệt
    await requestDoc.reference.delete();

    debugPrint("✅ Đã cộng $amount vào tài khoản của ${requestDoc['username']}");
  }

  void _rejectRequest(DocumentSnapshot requestDoc) async {
    // Xoá yêu cầu nạp sau khi từ chối
    await requestDoc.reference.delete();
    debugPrint("❌ Đã từ chối và xoá yêu cầu của ${requestDoc['username']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt yêu cầu nạp tiền'),
      backgroundColor: Colors.blueAccent),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('topup_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs
              .where((doc) => doc['status'] == 'pending')
              .toList();

          if (requests.isEmpty) {
            return const Center(child: Text('Không có yêu cầu nào'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final username = doc['username'];
              final amount = doc['amount'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('$username muốn nạp $amount VNĐ'),
                  subtitle: Text('ID người dùng: ${doc['uid']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _approveRequest(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận từ chối'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn từ chối yêu cầu này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Huỷ'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(ctx).pop();
                                    _rejectRequest(doc);
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
