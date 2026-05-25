import 'package:intl/intl.dart';

String formatTransactionDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final txDate = DateTime(date.year, date.month, date.day);

  if (txDate == today) return 'Today';
  if (txDate == yesterday) return 'Yesterday';
  return DateFormat('MMM d, yyyy').format(date);
}
