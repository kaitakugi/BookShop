import 'package:flutter/material.dart';
import 'package:study_app/bookdetail.dart';
import 'package:study_app/home.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class Book {
  final String id;
  final String title;
  final String imageUrl;
  final String category;

  Book(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.category});
}

class _SearchState extends State<Search> {
  int currentPageIndex = 0;

  Set<String> favoriteBookIds = {}; // giả sử bạn dùng book.id

  List<Book> allBooks = [
    Book(
        id: '1',
        title: 'Harry Potter',
        imageUrl: 'https://i.imgur.com/2yaf2wb.jpg',
        category: 'Fantasy'),
    Book(
        id: '2',
        title: 'Naruto',
        imageUrl: 'https://i.imgur.com/rBbc0D2.jpg',
        category: 'Adventure'),
    Book(
        id: '3',
        title: 'IT',
        imageUrl: 'https://i.imgur.com/zYO1hX0.jpg',
        category: 'Horror'),
    Book(
        id: '4',
        title: 'Detective Conan',
        imageUrl: 'https://i.imgur.com/UXVcVj9.jpg',
        category: 'Comedy'),
    Book(
        id: '5',
        title: 'One Piece',
        imageUrl: 'https://i.imgur.com/hC4HdNV.jpg',
        category: 'Adventure'),
  ];

  String selectedCategory = 'All';

  String searchTerm = '';

  List<Book> get filteredBooks {
    return allBooks.where((book) {
      final matchCategory =
          selectedCategory == 'All' || book.category == selectedCategory;
      final matchTitle =
          book.title.toLowerCase().contains(searchTerm.toLowerCase());
      return matchCategory && matchTitle;
    }).toList();
  }

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
              child: Image.network(
                "https://img.freepik.com/free-photo/bookshelf-filled-with-books-library_123827-23429.jpg",
                fit: BoxFit.cover,
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: Colors.black12);
                },
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              icon: const Icon(Icons.add_circle,
                                  color: Color.fromARGB(255, 224, 195, 7)),
                              label: const Text('28',
                                  style: TextStyle(color: Colors.black)),
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
                          'https://img.freepik.com/free-photo/3d-rendering-cartoon-characters-exploring-like-forest_23-2150991431.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Adventure';
                            });
                          },
                        ),
                        categoryItem(
                          'Comedy',
                          'https://img.freepik.com/free-vector/cartoon-stand-up-comedy-background_52683-75229.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Comedy';
                            });
                          },
                        ),
                        categoryItem(
                          'Fantasy',
                          'https://img.freepik.com/free-vector/gradient-children-book-illustration_52683-142946.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Fantasy';
                            });
                          },
                        ),
                        categoryItem(
                          'Horror',
                          'https://img.freepik.com/free-photo/scary-background-design_23-2150912069.jpg',
                          () {
                            setState(() {
                              selectedCategory = 'Horror';
                            });
                          },
                        ),
                        categoryItem(
                          'All',
                          'https://img.icons8.com/color/96/books.png', // icon tùy bạn chọn
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBooks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to book detail page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(book: book),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        book.imageUrl,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
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
                                        onTap: () {
                                          setState(() {
                                            if (favoriteBookIds
                                                .contains(book.id)) {
                                              favoriteBookIds.remove(book.id);
                                            } else {
                                              favoriteBookIds.add(book.id);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          favoriteBookIds.contains(book.id)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              favoriteBookIds.contains(book.id)
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
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //Widget của sách
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
              child: Image.network(
                imageUrl,
                width: 40,
                height: 50, // giảm height tại đây
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 40,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
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
