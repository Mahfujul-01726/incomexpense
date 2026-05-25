import '../constants/app_constants.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String walletId;
  final String payee;
  final String note;
  final String status;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.walletId,
    required this.payee,
    required this.note,
    this.status = AppConstants.statusCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
        'walletId': walletId,
        'payee': payee,
        'note': note,
        'status': status,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        type: json['type'],
        category: json['category'],
        date: DateTime.parse(json['date']),
        walletId: json['walletId'],
        payee: json['payee'],
        note: json['note'],
        status: json['status'] ?? AppConstants.statusCompleted,
      );
}
