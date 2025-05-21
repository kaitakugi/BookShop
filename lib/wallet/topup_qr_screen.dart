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
    final content = "$username nạp $amount vào bookshop";

    // Thay bằng ngân hàng và STK thực tế
    final bankId = "MB"; // hoặc "VCB", "TCB", v.v.
    final accountNumber = "0867773047";

    final encodedContent = Uri.encodeComponent(content);
    final qrUrl =
        "https://img.vietqr.io/image/$bankId-$accountNumber-qr_only.png?amount=$amount&addInfo=$encodedContent";

    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển khoản')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Quét mã QR để chuyển khoản",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),

                // Hiển thị hình ảnh QR từ vietqr
                Image.network(
                  qrUrl,
                  width: 250,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("Không tải được mã QR"),
                ),

                const SizedBox(height: 20),
                const Text("Nội dung chuyển khoản:",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),

                // Hiển thị nội dung chuyển khoản
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade50,
                  ),
                  child: SelectableText(
                    content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Thông báo chú ý
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '⚠️ Chú ý: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'Vui lòng '),
                      TextSpan(
                        text:
                            'ghi đúng nội dung chuyển khoản nếu app không tự động điền.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
