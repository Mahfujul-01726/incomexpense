import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'bill_details_screen.dart';
import 'bill_payment_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> with SingleTickerProviderStateMixin {
  final billController = Get.find<BillController>();
  final walletController = Get.find<WalletController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Payments'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () => _showAddBillDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Get.isDarkMode ? Colors.white : AppTheme.primaryColor,
          unselectedLabelColor: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          tabs: const [
            Tab(text: 'Upcoming / Due'),
            Tab(text: 'Paid History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillList(isPaidFilter: false),
          _buildBillList(isPaidFilter: true),
        ],
      ),
    );
  }

  Widget _buildBillList({required bool isPaidFilter}) {
    return Obx(() {
      final list = billController.bills.where((b) => b.isPaid == isPaidFilter).toList();
      
      if (list.isEmpty) {
        return _buildEmptyBills(isPaidFilter);
      }

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final bill = list[index];
          return _buildBillItem(context, bill);
        },
      );
    });
  }

  Widget _buildBillItem(BuildContext context, BillModel bill) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final now = DateTime.now();
    final difference = bill.dueDate.difference(now).inDays;
    
    Color dueColor;
    String dueText;
    
    if (bill.isPaid) {
      dueColor = AppTheme.incomeColor;
      dueText = 'Paid';
    } else if (difference < 0) {
      dueColor = AppTheme.expenseColor;
      dueText = 'Overdue by ${difference.abs()} days';
    } else if (difference == 0) {
      dueColor = AppTheme.warningColor;
      dueText = 'Due Today';
    } else if (difference == 1) {
      dueColor = AppTheme.warningColor;
      dueText = 'Due Tomorrow';
    } else {
      dueColor = Colors.blue;
      dueText = 'Due in $difference days';
    }

    return GestureDetector(
      onTap: () => Get.to(() => BillDetailsScreen(bill: bill)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Bill icon based on category
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getBillIcon(bill.name),
                color: dueColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Title & Due date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dueColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount & Pay button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatter.format(bill.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (bill.autoPay) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AUTOPAY',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ),
                ],
                if (!bill.isPaid) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => BillPaymentScreen(bill: bill)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      child: const Text('Pay'),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBills(bool isPaidFilter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaidFilter ? Icons.history_rounded : Icons.pending_actions_rounded,
              size: 56,
              color: AppTheme.primaryColor.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isPaidFilter ? 'No Paid Bills' : 'All Settled Up!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isPaidFilter
                  ? 'Bills you pay will show up here as history.'
                  : 'You have no outstanding or upcoming bills due.',
              style: TextStyle(
                fontSize: 12,
                color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBillIcon(String name) {
    final cleanName = name.toLowerCase();
    if (cleanName.contains('youtube')) {
      return Icons.play_arrow_rounded;
    } else if (cleanName.contains('electricity') || cleanName.contains('power')) {
      return Icons.flash_on_rounded;
    } else if (cleanName.contains('rent') || cleanName.contains('house')) {
      return Icons.home_filled;
    } else if (cleanName.contains('spotify') || cleanName.contains('music')) {
      return Icons.music_note_rounded;
    }
    return Icons.receipt_long_outlined;
  }

  void _showAddBillDialog(BuildContext context) {
    final nameField = TextEditingController();
    final amountField = TextEditingController();
    final providerField = TextEditingController();
    String category = 'Utilities';
    bool autoPay = false;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Scheduled Bill'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameField,
                    decoration: const InputDecoration(labelText: 'Bill Name', hintText: 'e.g. Electricity, Gym'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountField,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount Due', hintText: 'e.g. 45.00'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: providerField,
                    decoration: const InputDecoration(labelText: 'Biller / Provider', hintText: 'e.g. Comcast, Netflix'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Utilities', child: Text('Utilities')),
                      DropdownMenuItem(value: 'Internet', child: Text('Internet')),
                      DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                      DropdownMenuItem(value: 'Software', child: Text('Software')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          category = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto-Pay bill'),
                      Switch(
                        value: autoPay,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (val) {
                          setDialogState(() {
                            autoPay = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due Date', style: TextStyle(fontSize: 12)),
                          Text(DateFormat('MMMM dd, yyyy').format(dueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          ).then((picked) {
                            if (picked != null) {
                              setDialogState(() {
                                dueDate = picked;
                              });
                            }
                          });
                        },
                        child: const Text('Change'),
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameField.text.trim();
                  final amount = double.tryParse(amountField.text) ?? 0.0;
                  final provider = providerField.text.trim();

                  if (name.isEmpty || amount <= 0 || provider.isEmpty) {
                    Get.snackbar('Error', 'Please fill all required fields');
                    return;
                  }

                  final newBill = BillModel(
                    id: Uuid().v4(),
                    name: name,
                    amount: amount,
                    dueDate: dueDate,
                    isPaid: false,
                    category: category,
                    autoPay: autoPay,
                    provider: provider,
                  );

                  billController.addBill(newBill);
                  Get.back();
                  Get.snackbar(
                    'Bill Added',
                    'Successfully scheduled bill.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.incomeColor,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }
}
