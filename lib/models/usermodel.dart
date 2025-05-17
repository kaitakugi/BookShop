class UserModel {
  String username;
  String email;
  String password;
  int booksBought;
  int coins;
  int money; // thêm trường money để quản lý tiền thật

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    this.booksBought = 0,
    this.coins = 0,
    this.money = 0, // mặc định 0
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'booksBought': booksBought,
      'coins': coins,
      'money': money, // thêm vào map
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
      money: map['money'] ?? 0, // lấy dữ liệu money
    );
  }
}
