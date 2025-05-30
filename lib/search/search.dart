import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/search/bookdetail.dart';
import 'package:study_app/listhome/attendance_page.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/services/adminservices/bookservice.dart';
import 'package:study_app/listhome/home.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_app/vip/vippage.dart';

import '../darkmode.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int currentPageIndex = 0;

  //cập nhật 2 thông số để xác định sách đã mở và tổng số sách trong book vipvip
  int unlockedCount = 0;
  int totalCount = 0;

  UserModel? user;
  bool isLoading = true;

  //hàm fetch data để lấy dữ liệu từ firestore
  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      if (mounted) {
        setState(() {
          user = userDoc.exists
              ? UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
              : null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu Firestore: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải dữ liệu người dùng')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadFavoriteBooks();
  }

  //hàm load dữ liệu yêu thích từ firestore
  void loadFavoriteBooks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    setState(() {
      favoriteBookIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  final userId = FirebaseAuth.instance.currentUser!.uid;

  void toggleFavorite(Book book) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(book.id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete(); // Bỏ yêu thích
    } else {
      await docRef.set({
        'title': book.title,
        'categories': book.categories,
        'imageUrl': book.image,
        'author': book.author,
        // Thêm các trường khác nếu cần
      });
    }
  }

  Set<String> favoriteBookIds = {}; // giả sử bạn dùng book.id

  String selectedCategory = 'All';

  String searchTerm = '';

  void handleHome() {
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Coins + Attendance
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AttendancePage()),
                        ).then((_) => fetchUserData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey[850] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                      icon: Icon(
                        Icons.add_circle,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.amber, // Màu icon thay đổi theo chế độ
                      ),
                      label: Text(
                        '${user?.coins ?? 0}',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Màu chữ thay đổi theo chế độ
                        ),
                      ),
                    ),
                    // VIP
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VipPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey[850] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: borderColor),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      icon: Icon(Icons.diamond,
                          color: isDarkMode ? Colors.white : Colors.green),
                      label: Text(
                        "VIP",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Màu chữ thay đổi theo chế độ
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Text(
                'Discover',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'Find your favorite book',
                style: TextStyle(
                  fontSize: 18,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 20),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Search by title or more...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              //category
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    categoryItem('Adventure', 'assets/images/adventure.jpg',
                        () {
                      setState(() {
                        selectedCategory = 'Adventure';
                      });
                    }, context),
                    categoryItem('Comedy', 'assets/images/comedy.avif', () {
                      setState(() {
                        selectedCategory = 'Comedy';
                      });
                    }, context),
                    categoryItem('Fantasy', 'assets/images/fantasy.avif', () {
                      setState(() {
                        selectedCategory = 'Fantasy';
                      });
                    }, context),
                    categoryItem('Horror', 'assets/images/horror.avif', () {
                      setState(() {
                        selectedCategory = 'Horror';
                      });
                    }, context),
                    categoryItem('Drama', 'assets/images/drama.avif', () {
                      setState(() {
                        selectedCategory = 'Drama';
                      });
                    }, context),
                    categoryItem('Fiction', 'assets/images/fiction.avif', () {
                      setState(() {
                        selectedCategory = 'Fiction';
                      });
                    }, context),
                    categoryItem('Liternature', 'assets/images/liternator.jpg',
                        () {
                      setState(() {
                        selectedCategory = 'Liternator';
                      });
                    }, context),
                    categoryItem('Manga', 'assets/images/manga.avif', () {
                      setState(() {
                        selectedCategory = 'Manga';
                      });
                    }, context),
                    categoryItem(
                        'All', 'assets/images/books.png', // icon tùy bạn chọn
                        () {
                      setState(() {
                        selectedCategory = 'All';
                      });
                    }, context),
                  ],
                ),
              ),

              // Book Grid
              Expanded(
                child: StreamBuilder<List<Book>>(
                  stream: BookService().getFreeBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load books.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No books found.'));
                    }

                    //snap.data lấy dữ liệu từ streambuilder realtime
                    final filtered = snapshot.data!.where((book) {
                      final matchCategory = selectedCategory == 'All' ||
                          book.categories.contains(selectedCategory);
                      final matchTitle = book.title
                          .toLowerCase()
                          .contains(searchTerm.toLowerCase());
                      return matchCategory && matchTitle;
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        final isFavorite = favoriteBookIds.contains(book.id);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailPage(
                                    book: book, currentUser: user!),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        book.image,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    // Favorite Icon
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () async {
                                          toggleFavorite(book);
                                          setState(() {
                                            if (isFavorite) {
                                              favoriteBookIds.remove(book.id);
                                            } else {
                                              favoriteBookIds.add(book.id);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Title + Category
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.categories.join(', '),
                                        style: TextStyle(
                                            fontSize: 12, color: subtitleColor),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //Widget của loại sách
  Widget categoryItem(
      String title, String imageUrl, VoidCallback onTap, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.05); // Sáng rõ hơn

    final List<BoxShadow> boxShadow = isDarkMode
        ? [] // Không đổ bóng ở dark mode
        : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3), // bóng trắng đục nhẹ
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: boxShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.asset(
                imageUrl,
                width: 40,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
