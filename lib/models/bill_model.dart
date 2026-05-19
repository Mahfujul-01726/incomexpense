class BillModel {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String category;
  final bool autoPay;
  final String provider;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.category,
    required this.autoPay,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'isPaid': isPaid,
        'category': category,
        'autoPay': autoPay,
        'provider': provider,
      };

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['dueDate']),
        isPaid: json['isPaid'],
        category: json['category'],
        autoPay: json['autoPay'],
        provider: json['provider'],
      );

  BillModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? category,
    bool? autoPay,
    String? provider,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
      autoPay: autoPay ?? this.autoPay,
      provider: provider ?? this.provider,
    );
  }
}
