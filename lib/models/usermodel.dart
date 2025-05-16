class UserModel {
  String username;
  String email;
  String password;
  int booksBought;
  int coins;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    this.booksBought = 0,
    this.coins = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'booksBought': booksBought,
      'coins': coins,
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
    );
  }
}
