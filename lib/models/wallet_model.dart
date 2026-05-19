class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String type; // 'card', 'bank', 'cash'
  final int colorIndex;
  final String? bankLogo; // bank logo name

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.type,
    required this.colorIndex,
    this.bankLogo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'cardHolder': cardHolder,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'type': type,
        'colorIndex': colorIndex,
        'bankLogo': bankLogo,
      };

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id'],
        name: json['name'],
        balance: (json['balance'] as num).toDouble(),
        cardHolder: json['cardHolder'],
        cardNumber: json['cardNumber'],
        expiryDate: json['expiryDate'],
        type: json['type'],
        colorIndex: json['colorIndex'],
        bankLogo: json['bankLogo'],
      );
}
