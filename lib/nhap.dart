
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
                          'Drama',
                          'https://img.freepik.com/free-vector/theatre-masks-backdrop_98292-6042.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip',
                          () {
                            setState(() {
                              selectedCategory = 'Drama';
                            });
                          },
                        ),
                        categoryItem(
                          'Fiction',
                          'https://img.freepik.com/free-vector/realistic-fantasy-illustration-dwarf-illustration_52683-95391.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip',
                          () {
                            setState(() {
                              selectedCategory = 'Fiction';
                            });
                          },
                        ),
                        categoryItem(
                          'Liternature',
                          'https://img.freepik.com/free-vector/eco-tourism-concept_23-2148630127.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip',
                          () {
                            setState(() {
                              selectedCategory = 'Liternator';
                            });
                          },
                        ),
                        categoryItem(
                          'Manga',
                          'https://img.freepik.com/free-vector/hand-drawn-vintage-comic-illustration_23-2149624608.jpg?ga=GA1.1.983139440.1730316710&semt=ais_siglip',
                          () {
                            setState(() {
                              selectedCategory = 'Manga';
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