import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/bill_model.dart';

class MockData {
  static const bool useMockData = true;

  static List<TransactionModel> get defaultTransactions {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 't_1',
        title: 'Upwork',
        amount: 850.00,
        type: 'income',
        category: 'Freelance',
        date: now,
        walletId: 'wallet_1',
        payee: 'Upwork Global Inc.',
        note: 'Freelance mobile app development milestone',
        status: 'completed',
      ),
      TransactionModel(
        id: 't_2',
        title: 'Transfer',
        amount: 85.00,
        type: 'expense',
        category: 'Transfer',
        date: now.subtract(const Duration(days: 1)),
        walletId: 'wallet_1',
        payee: 'Bank Account Transfer',
        note: 'Peer to peer transfer',
        status: 'completed',
      ),
      TransactionModel(
        id: 't_3',
        title: 'Paypal',
        amount: 1406.00,
        type: 'income',
        category: 'Consulting',
        date: DateTime(2022, 1, 30, 14, 30),
        walletId: 'wallet_1',
        payee: 'PayPal Inc.',
        note: 'Online payment received',
        status: 'completed',
      ),
      TransactionModel(
        id: 't_4',
        title: 'Youtube',
        amount: 11.99,
        type: 'expense',
        category: 'Subscriptions',
        date: DateTime(2022, 1, 16, 9, 15),
        walletId: 'wallet_1',
        payee: 'Google Youtube Premium',
        note: 'Monthly premium subscription fee',
        status: 'completed',
      ),
      TransactionModel(
        id: 't_5',
        title: 'Starbucks',
        amount: 150.00,
        type: 'expense',
        category: 'Food & Dining',
        date: DateTime(2022, 1, 12, 8, 30),
        walletId: 'wallet_1',
        payee: 'Starbucks Coffee',
        note: 'Coffee and snacks',
        status: 'completed',
      ),
    ];
  }

  static List<BillModel> get defaultBills {
    final now = DateTime.now();
    return [
      BillModel(
        id: 'bill_1',
        name: 'Youtube Premium',
        amount: 11.99,
        dueDate: DateTime(2022, 2, 28),
        isPaid: false,
        category: 'Entertainment',
        autoPay: true,
        provider: 'YouTube LLC',
      ),
      BillModel(
        id: 'bill_3',
        name: 'House Rent',
        amount: 1200.00,
        dueDate: now.add(const Duration(days: 1)),
        isPaid: false,
        category: 'Housing',
        autoPay: false,
        provider: 'Sunset Properties',
      ),
      BillModel(
        id: 'bill_2',
        name: 'Electricity',
        amount: 85.40,
        dueDate: now.add(const Duration(days: 7)),
        isPaid: false,
        category: 'Utilities',
        autoPay: false,
        provider: 'Metro Power Utility',
      ),
      BillModel(
        id: 'bill_4',
        name: 'Spotify',
        amount: 9.99,
        dueDate: now.add(const Duration(days: 10)),
        isPaid: false,
        category: 'Entertainment',
        autoPay: true,
        provider: 'Spotify AB',
      ),
    ];
  }

  static List<WalletModel> get defaultWallets {
    return [
      WalletModel(
        id: 'wallet_1',
        name: 'Mono Debit Card',
        balance: 2548.00,
        cardHolder: 'Mahfujur Rahman',
        cardNumber: '**** **** **** 8075',
        expiryDate: '22/01',
        type: 'card',
        colorIndex: 0,
        bankLogo: 'Visa',
      ),
    ];
  }
}
