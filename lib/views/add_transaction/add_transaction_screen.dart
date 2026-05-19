import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final txController = Get.find<TransactionController>();
  final walletController = Get.find<WalletController>();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _payeeController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'expense'; // 'expense' | 'income'
  String _selectedCategory = 'Food & Dining';
  String _selectedWalletId = '';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Groceries',
    'Shopping',
    'Entertainment',
    'Utilities',
    'Subscriptions',
    'Transport',
    'Health & Fitness',
    'Software',
    'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Consulting',
    'Investments',
    'Refunds',
    'Gifts',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (walletController.wallets.isNotEmpty) {
      _selectedWalletId = walletController.wallets.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _payeeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (enteredAmount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter an amount greater than zero',
          backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    if (_selectedWalletId.isEmpty) {
      Get.snackbar('No Wallet Selected', 'Please select a wallet to process the transaction',
          backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    final newTx = TransactionModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: enteredAmount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
      walletId: _selectedWalletId,
      payee: _payeeController.text.trim().isEmpty 
          ? (_selectedType == 'income' ? 'Self' : 'Merchant') 
          : _payeeController.text.trim(),
      note: _noteController.text.trim(),
      status: 'completed',
    );

    txController.addTransaction(newTx);
    Get.back();
    Get.snackbar(
      'Transaction Added',
      'Logged successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.incomeColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${_selectedType.capitalizeFirst}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Toggle (Income / Expense)
                _buildTypeToggle(),
                const SizedBox(height: 28),

                // Amount Field (Large neon styled)
                _buildAmountInput(activeColor),
                const SizedBox(height: 28),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title Textbox
                      _buildTextField('Title / Label', _titleController, Icons.label_outline_rounded, 'e.g. Starbucks, Payout'),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      _buildCategoryDropdown(),
                      const SizedBox(height: 20),

                      // Wallet Selector Dropdown
                      _buildWalletDropdown(),
                      const SizedBox(height: 20),

                      // Payee / Recipient Textbox
                      _buildTextField(_selectedType == 'income' ? 'Sender / Source' : 'Recipient / Payee', _payeeController, Icons.person_outline_rounded, 'e.g. Upwork, Walmart'),
                      const SizedBox(height: 20),

                      // Date selector row
                      _buildDateSelector(activeColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Note description card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add notes or description here...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Add ${_selectedType.capitalizeFirst}'),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'expense';
                  _selectedCategory = _expenseCategories.first;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'expense' ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedType == 'expense' ? Colors.white : (Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'income';
                  _selectedCategory = _incomeCategories.first;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'income' ? AppTheme.incomeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedType == 'income' ? Colors.white : (Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(Color activeColor) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('Enter Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Get.isDarkMode ? Colors.white10 : Colors.black12),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Field is required';
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _selectedType == 'income' ? _incomeCategories : _expenseCategories;
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.grid_view_rounded, size: 20),
      ),
      items: categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (val) {
        if (val == null) return;
        setState(() {
          _selectedCategory = val;
        });
      },
    );
  }

  Widget _buildWalletDropdown() {
    return Obx(() {
      final wallets = walletController.wallets;
      return DropdownButtonFormField<String>(
        value: _selectedWalletId.isNotEmpty ? _selectedWalletId : null,
        decoration: const InputDecoration(
          labelText: 'Wallet / Card Source',
          prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
        ),
        items: wallets.map((w) {
          return DropdownMenuItem<String>(
            value: w.id,
            child: Text('${w.name} (${w.cardNumber.split(' ').last})'),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            _selectedWalletId = val;
          });
        },
      );
    });
  }

  Widget _buildDateSelector(Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, 
              size: 20, 
              color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            )
          ],
        ),
        TextButton(
          onPressed: _presentDatePicker,
          child: Text(
            'Change',
            style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
