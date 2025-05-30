import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // hoặc nơi bạn lưu userId

class AddBankPage extends StatelessWidget {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();

  final String userId;

  AddBankPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm tài khoản ngân hàng")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: bankNameController,
              decoration: InputDecoration(labelText: 'Ngân hàng'),
            ),
            TextField(
              controller: accountNumberController,
              decoration: InputDecoration(labelText: 'Số tài khoản'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: accountHolderController,
              decoration: InputDecoration(labelText: 'Chủ tài khoản'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (bankNameController.text.isEmpty ||
                    accountNumberController.text.isEmpty ||
                    accountHolderController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Vui lòng điền đầy đủ thông tin")));
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('bankAccounts')
                    .add({
                  'bankName': bankNameController.text,
                  'accountNumber': accountNumberController.text,
                  'accountHolder': accountHolderController.text,
                });

                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}
