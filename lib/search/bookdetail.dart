import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:study_app/models/bookmodel.dart';
import 'package:study_app/models/usermodel.dart';
import 'package:study_app/search/chapter.dart';
import 'package:study_app/wallet/buypackage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  final UserModel currentUser;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.currentUser,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  bool _adInitialized = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _isAdWatched = false; // Quảng cáo đã xem xong chưa

  final TextEditingController _commentbookController = TextEditingController();
  UserModel? user;

  @override
  void initState() {
    super.initState();
  }

  // ignore: unused_element
  Future<void> _fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        setState(() {
          user = UserModel(
            username: doc['username'],
            email: doc['email'],
            password: '',
          );
        });
      }
    }
  }

  // ignore: unused_element
  Future<void> _addComment() async {
    final text = _commentbookController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (text.isNotEmpty && currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final username = doc['username'];

      final newComment = '$username: $text';

      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .collection('comments')
          .add({
        'username': username,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentbookController.clear();
    }
  }

  void _initializeAds() {
    _adInitialized = true;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // test banner ad
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner Ad failed to load');
        },
      ),
    );
    _bannerAd.load();

    _loadAndShowRewardedAd(); // Gọi luôn quảng cáo có thưởng
  }

  void _loadAndShowRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // test rewarded ad
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isAdWatched = true; // Quảng cáo đã xem xong
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('Rewarded Ad failed to show: $error');
              setState(() {
                _isAdWatched = true; // lỗi thì cũng cho xem luôn
              });
            },
          );

          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              debugPrint('User earned reward: ${reward.amount} ${reward.type}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed to load: $error');
          setState(() {
            _isAdWatched = true; // nếu load lỗi cho xem luôn
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!;
        final currentUser = UserModel.fromFirestore(userData);
        final now = DateTime.now();
        final isCurrentlyPremium = currentUser.premiumExpiry != null &&
            currentUser.premiumExpiry!.isAfter(now);

        // 👉 Gọi quảng cáo khi đã có dữ liệu và chưa gọi lần nào
        if (!_adInitialized && !_isAdWatched && !isCurrentlyPremium) {
          _initializeAds();
        }

        // Nếu vừa mua gói premium thì cập nhật lại trạng thái xem quảng cáo
        if (!_isAdWatched && isCurrentlyPremium) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _isAdWatched = true;
            });
          });
        }

        // Nếu chưa xem quảng cáo xong thì hiện màn hình chờ
        if (!_isAdWatched && !isCurrentlyPremium) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải quảng cáo, vui lòng đợi...'),
                ],
              ),
            ),
          );
        }

        // Sau khi xem xong hoặc user là premium thì hiển thị nội dung trang
        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Image.network(
                book.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                book.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Author: ${book.author}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 4,
                minRating: 1,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  debugPrint("Rating: $rating");
                },
              ),
              const SizedBox(height: 16),
              if (!isCurrentlyPremium)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "🔔 Quảng cáo 🔔",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          "Mua gói để đọc sách không bị gián đoạn bởi quảng cáo!"),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BuyPackagePage(currentUser: currentUser),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              _isAdWatched = true;
                            });
                          }
                        },
                        child: const Text("Mua gói ngay"),
                      ),
                    ],
                  ),
                ),
              const Text(
                'Chapters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Chapter ${index + 1}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChapterPage(chapterIndex: index),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text("Comments:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 300, // hoặc MediaQuery.of(context).size.height * 0.4
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .doc(widget.book.id)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Chưa có bình luận nào'));
                    }

                    final comments = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const Icon(Icons.comment),
                          title: Text(comment['username'] ?? 'Ẩn danh'),
                          subtitle: Text(comment['content'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentbookController,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!isCurrentlyPremium && _isBannerAdReady)
                SizedBox(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
            ],
          ),
        );
      },
    );
  }
}
