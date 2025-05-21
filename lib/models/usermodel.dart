import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username;
  String email;
  String password;
  int booksBought;
  int coins;
  int money;
  DateTime? premiumExpiry; // Chỉ cần trường này

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    this.booksBought = 0,
    this.coins = 0,
    this.money = 0,
    this.premiumExpiry,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'booksBought': booksBought,
      'coins': coins,
      'money': money,
      'premiumExpiry':
          premiumExpiry != null ? Timestamp.fromDate(premiumExpiry!) : null,
      'role': 'user',
      'createdAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: '',
      booksBought: map['booksBought'] ?? 0,
      coins: map['coins'] ?? 0,
      money: map['money'] ?? 0,
      premiumExpiry: map['premiumExpiry'] != null
          ? (map['premiumExpiry'] as Timestamp).toDate()
          : null,
    );
  }
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
