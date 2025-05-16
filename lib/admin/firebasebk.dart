import 'package:flutter/material.dart';

class AdvancedWidgetsPage extends StatelessWidget {
  const AdvancedWidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Basics")),
      body: const Center(child: Text("Quản lý sách Flutter tại đây")),
    );
  }
}
