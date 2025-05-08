import 'package:flutter/material.dart';

class CountdownPage extends StatelessWidget {
  const CountdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Countdown")),
      body: const Center(
        child: Text("Đây là trang lịch đếm / thử thách"),
      ),
    );
  }
}
