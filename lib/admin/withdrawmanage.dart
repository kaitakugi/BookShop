import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawAdminPage extends StatelessWidget {
  const WithdrawAdminPage({super.key});

  Future<void> approveWithdraw(String docId, Map<String, dynamic> data) async {
    final userId = data['userId'];
    final amount = data['amount'];

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Bước 1: Chuyển đơn rút tiền sang collection lịch sử
    await FirebaseFirestore.instance
        .collection('withdrawHistory')
        .doc(docId)
        .set({
      ...data,
      'userId': userId, // đảm bảo userId tồn tại rõ ràng
      'status': 'Thành công',
      'approvedAt': Timestamp.now(),
    });


    // Bước 2: Xóa đơn trong withdrawRequests
    await FirebaseFirestore.instance
        .collection('withdrawRequests')
        .doc(docId)
        .delete();

    // Bước 3: Trừ tiền của user
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception("User không tồn tại");
      }

      final currentMoney = snapshot.get('money') ?? 0;
      if (currentMoney < amount) {
        throw Exception("Số dư không đủ để rút");
      }

      transaction.update(userRef, {
        'money': currentMoney - amount,
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Duyệt đơn rút tiền")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawRequests')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text("Không có đơn chờ duyệt"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final docId = requests[index].id;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("User: ${data['userId']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Số tiền: ${data['amount']} VNĐ"),
                      Text("Ngân hàng: ${data['bank']['bankName']}"),
                      Text("STK: ${data['bank']['accountNumber']}"),
                      Text("Chủ TK: ${data['bank']['accountHolder']}"),
                      Text("Thời gian: ${data['createdAt'].toDate()}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => approveWithdraw(docId, data),
                    child: Text("Duyệt"),
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
