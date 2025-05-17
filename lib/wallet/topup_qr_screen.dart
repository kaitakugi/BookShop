import 'package:flutter/material.dart';

class TopUpQRScreen extends StatelessWidget {
  final String username;
  final int amount;

  const TopUpQRScreen({
    super.key,
    required this.username,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final content =
        '"$username nạp $amount vào bookshop"'; // Đặt nội dung trong dấu ngoặc kép

    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển khoản')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Quét mã QR để chuyển khoản",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Image.asset('assets/images/myqrcodebank.png', height: 250),
                const SizedBox(height: 20),
                const Text("Nội dung chuyển khoản:",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                SelectableText(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '⚠️ Chú ý: Vui lòng **ghi đúng nội dung chuyển khoản**',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
