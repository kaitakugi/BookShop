import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawHistoryPage extends StatelessWidget {
  final String userId;

  const WithdrawHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    print("WithdrawHistoryPage userId: $userId");
    return Scaffold(
      appBar: AppBar(title: Text("Lịch sử rút tiền")),
      body: StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('withdrawHistory')
            .where('userId', isEqualTo: userId)  // Lọc chỉ lấy dữ liệu của user hiện tại
            // .orderBy('createdAt', descending: true)
            .snapshots(),
          builder: (context, snapshot) {
            print('Snapshot: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, Docs: ${snapshot.data?.docs.length}');
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text("Chưa có yêu cầu nào"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final status = data['status'];
              return ListTile(
                title: Text("${data['amount']} VNĐ"),
                subtitle: Text("Trạng thái: $status"),
                trailing: Text("${(data['createdAt'] as Timestamp).toDate()}"),
              );
            },
          );
        },
      ),
    );
  }
}
