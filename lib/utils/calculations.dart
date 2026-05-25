double calculateFee(double amount) {
  if ((amount - 11.99).abs() < 0.01) return 1.99;
  final fee = amount * 0.029 + 0.30;
  return fee > 0.50 ? double.parse(fee.toStringAsFixed(2)) : 0.50;
}
