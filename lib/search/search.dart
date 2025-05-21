import 'package:flutter/material.dart';
import 'package:study_app/search/bookdetail.dart';
import 'package:study_app/listhome/attendance_page.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/services/bookservice.dart';
import 'package:study_app/listhome/home.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            user = null;
            isLoading = false;
          });
        }
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Lấy danh sách ID sách đã mở khóa
      final unlockedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('unlockedBooks')
          .get();

      // Lấy tất cả sách cần xu để mở
      final lockedBooksSnap = await FirebaseFirestore.instance
          .collection('books')
          .where('lock', isEqualTo: true)
          .where('price', isGreaterThan: 0)
          .get();

      // Lọc sách đã mở khóa trong danh sách cần xu
      final unlockedBookIds = unlockedSnap.docs.map((doc) => doc.id).toSet();
      final unlockedLockedBooks = lockedBooksSnap.docs
          .where((doc) => unlockedBookIds.contains(doc.id))
          .toList();

      if (mounted) {
        setState(() {
          user = userDoc.exists
              ? UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
              : null;
          unlockedCount = unlockedLockedBooks.length;
          totalCount = lockedBooksSnap.size;
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
        'category': book.category,
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background image with loading and error handling
            Positioned.fill(
              child: Image.asset(
                "assets/images/search.avif",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black45),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left app bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble,
                                  color: Color.fromARGB(255, 84, 158, 28),
                                  size: 28),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Level 2',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 6,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 228, 91, 0),
                                          Color.fromARGB(255, 217, 139, 86),
                                          Color.fromARGB(255, 221, 221, 221),
                                          Color.fromARGB(255, 221, 221, 221),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right app bar
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AttendancePage()),
                                ).then((_) =>
                                    fetchUserData()); // reload lại coin sau khi điểm danh
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.amber),
                              label: Text('${user?.coins ?? 0}'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              icon: const Icon(Icons.translate,
                                  color: Color.fromARGB(255, 19, 199, 25)),
                              label: const Text('ENG',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Discover',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    'Find your favorite book',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 220, 220, 220)),
                  ),
                  const SizedBox(height: 20),
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Search by title or more...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchTerm = value;
                            });
                          }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Categories
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: [
                        categoryItem(
                          'Adventure',
                          'assets/images/adventure.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Adventure';
                            });
                          },
                        ),
                        categoryItem(
                          'Comedy',
                          'assets/images/comedy.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Comedy';
                            });
                          },
                        ),
                        categoryItem(
                          'Fantasy',
                          'assets/images/fantasy.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Fantasy';
                            });
                          },
                        ),
                        categoryItem(
                          'Horror',
                          'assets/images/horror.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Horror';
                            });
                          },
                        ),
                        categoryItem(
                          'Drama',
                          'assets/images/drama.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Drama';
                            });
                          },
                        ),
                        categoryItem(
                          'Fiction',
                          'assets/images/fiction.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Fiction';
                            });
                          },
                        ),
                        categoryItem(
                          'Liternature',
                          'assets/images/liternator.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Liternator';
                            });
                          },
                        ),
                        categoryItem(
                          'Manga',
                          'assets/images/manga.avif',
                          () {
                            setState(() {
                              selectedCategory = 'Manga';
                            });
                          },
                        ),
                        categoryItem(
                          'All',
                          'assets/images/books.png', // icon tùy bạn chọn
                          () {
                            setState(() {
                              selectedCategory = 'All';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Book Grid
                  Expanded(
                    child: StreamBuilder<List<Book>>(
                      stream: BookService().getFreeBooks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Failed to load books.'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No books found.'));
                        }

                        final filtered = snapshot.data!.where((book) {
                          final matchCategory = selectedCategory == 'All' ||
                              book.category == selectedCategory;
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
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookDetailPage(
                                      book: book,
                                      currentUser:
                                          user!, // ✅ truyền thêm dòng này
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                          child: Image.network(
                                            book.image,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                height: 150,
                                                color: Colors.grey[200],
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
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () async {
                                              toggleFavorite(
                                                  book); // Lưu vào Firestore
                                              setState(() {
                                                if (favoriteBookIds
                                                    .contains(book.id)) {
                                                  favoriteBookIds
                                                      .remove(book.id);
                                                } else {
                                                  favoriteBookIds.add(book.id);
                                                }
                                              });
                                            },
                                            child: Icon(
                                              favoriteBookIds.contains(book.id)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: favoriteBookIds
                                                      .contains(book.id)
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            book.category,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
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
            )
          ],
        ),
      ),
    );
  }

  //Widget của loại sách
  Widget categoryItem(String title, String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
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
                height: 50, // giảm height tại đây
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
