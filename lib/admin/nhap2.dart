import 'package:flutter/material.dart';

class FirebaseBookPage extends StatelessWidget {
  const FirebaseBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Basics")),
      body: const Center(child: Text("Quản lý sách Flutter tại đây")),
    );
  }
}
