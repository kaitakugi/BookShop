import 'package:flutter/material.dart';
import 'package:study_app/storagefavour/bookfavour.dart';
import 'package:study_app/storagefavour/mystory.dart';

class StorageFavour extends StatefulWidget {
  const StorageFavour({super.key});

  @override
  State<StorageFavour> createState() => _StorageFavourState();
}

class _StorageFavourState extends State<StorageFavour> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FavouriteBook(),
    MyStoriesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện của tôi'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), // đổi thành icon nhật ký
            label: 'Truyện của tôi',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
