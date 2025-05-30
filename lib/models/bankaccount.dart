class BankAccount {
  String bankName;
  String accountNumber;
  String accountHolder;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountHolder: map['accountHolder'] ?? '',
    );
  }
}
