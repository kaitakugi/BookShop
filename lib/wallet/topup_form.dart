import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/wallet/topup_qr_screen.dart';

class TopUpForm extends StatefulWidget {
  final String username;

  const TopUpForm({super.key, required this.username});

  @override
  State<TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<TopUpForm> {
  final _amountController = TextEditingController();

  void _submitTopUpRequest() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập số tiền hợp lệ")));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('topup_requests').add({
      'uid': uid,
      'username': widget.username,
      'amount': amount,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    // Điều hướng đến trang QR code
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopUpQRScreen(
          username: widget.username,
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nạp tiền',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Số tiền muốn nạp (VNĐ)',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitTopUpRequest,
          child: const Text('Nạp'),
        ),
      ],
    );
  }
}
