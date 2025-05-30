import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/chargemoney/chargemoney.dart';

class WithdrawPage extends StatefulWidget {
  final String userId;
  const WithdrawPage({super.key, required this.userId});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController amountController = TextEditingController();
  List<Map<String, dynamic>> bankAccounts = [];
  int? selectedBankIndex;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    final bankSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('bankAccounts')
        .get();

    setState(() {
      bankAccounts = bankSnap.docs.map((doc) => doc.data()).toList();
      // Nếu đã có tài khoản, mặc định chọn tài khoản đầu tiên
      if (bankAccounts.isNotEmpty) selectedBankIndex = 0;
    });
  }

  void _gotoAddBank() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBankPage(userId: widget.userId),
      ),
    );
    _loadBankAccounts(); // Reload sau khi thêm bank
  }

  void _submitWithdraw() async {
    if (amountController.text.isEmpty || selectedBankIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Vui lòng nhập số tiền và chọn tài khoản ngân hàng")));
      return;
    }

    int amount = int.parse(amountController.text);
    Map<String, dynamic> selectedBank = bankAccounts[selectedBankIndex!];

    await FirebaseFirestore.instance.collection('withdrawRequests').add({
      'userId': widget.userId,
      'amount': amount,
      'status': 'pending',
      'createdAt': Timestamp.now(),
      'bank': selectedBank,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Đã gửi yêu cầu rút tiền")));
    amountController.clear();
  }

  Widget _buildBankCard(Map<String, dynamic> bank, int index) {
    final isSelected = index == selectedBankIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBankIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.grey[200],
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ngân hàng: ${bank['bankName']}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Số tài khoản: ${bank['accountNumber']}"),
            Text("Chủ tài khoản: ${bank['accountHolder']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rút tiền")),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoAddBank,
        tooltip: "Thêm ngân hàng",
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Chọn tài khoản ngân hàng để rút tiền:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (bankAccounts.isEmpty)
              Text("Chưa có tài khoản ngân hàng nào. Thêm mới bằng nút '+' bên dưới."),
            if (bankAccounts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: bankAccounts.length,
                  itemBuilder: (context, index) =>
                      _buildBankCard(bankAccounts[index], index),
                ),
              ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Số tiền muốn rút"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitWithdraw,
              child: Text("Rút tiền"),
            ),
          ],
        ),
      ),
    );
  }
}

