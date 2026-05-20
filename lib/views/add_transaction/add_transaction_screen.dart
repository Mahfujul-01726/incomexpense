import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class MerchantItem {
  final String name;
  final String defaultCategory;
  final String logoType; // 'netflix' | 'asset' | 'icon'
  final String? assetPath;
  final IconData? fallbackIcon;

  MerchantItem({
    required this.name,
    required this.defaultCategory,
    required this.logoType,
    this.assetPath,
    this.fallbackIcon,
  });
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final txController = Get.find<TransactionController>();
  final walletController = Get.find<WalletController>();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '0.00');
  final _titleController = TextEditingController();
  final _payeeController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'expense'; // 'expense' | 'income'
  String _selectedCategory = 'Food & Dining';
  String _selectedWalletId = '';
  DateTime _selectedDate = DateTime.now();

  // No custom keyboard state needed

  // Mock invoice attachment state
  String? _selectedInvoiceName;

  // Predefined merchants list
  final List<MerchantItem> _merchants = [
    MerchantItem(
      name: 'Netflix',
      defaultCategory: 'Subscriptions',
      logoType: 'netflix',
    ),
    MerchantItem(
      name: 'Youtube',
      defaultCategory: 'Subscriptions',
      logoType: 'asset',
      assetPath: 'assets/cropped/logo_youtube.png',
    ),
    MerchantItem(
      name: 'Starbucks',
      defaultCategory: 'Food & Dining',
      logoType: 'asset',
      assetPath: 'assets/cropped/logo_starbucks.png',
    ),
    MerchantItem(
      name: 'PayPal',
      defaultCategory: 'Software',
      logoType: 'asset',
      assetPath: 'assets/cropped/logo_paypal.png',
    ),
    MerchantItem(
      name: 'Upwork',
      defaultCategory: 'Freelance',
      logoType: 'asset',
      assetPath: 'assets/cropped/logo_upwork.png',
    ),
    MerchantItem(
      name: 'Other',
      defaultCategory: 'Other',
      logoType: 'icon',
      fallbackIcon: Icons.storefront_rounded,
    ),
  ];

  late MerchantItem _selectedMerchant;
  String _selectedMerchantName = 'Netflix';

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
    _selectedMerchant = _merchants.first; // Netflix
    _selectedMerchantName = _selectedMerchant.name;
    _payeeController.text = _selectedMerchant.name;
    _titleController.text = _selectedMerchant.name;
    _selectedCategory = _selectedMerchant.defaultCategory;

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
      initialDate: _selectedDate,
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

  void _clearAmount() {
    setState(() {
      _amountController.text = '0.00';
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
      title: _titleController.text.trim().isEmpty ? _selectedMerchantName : _titleController.text.trim(),
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

  void _showTypeChangeMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Transaction Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.expenseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_outward_rounded, color: AppTheme.expenseColor),
              ),
              title: const Text('Expense', style: TextStyle(fontWeight: FontWeight.bold)),
              selected: _selectedType == 'expense',
              onTap: () {
                setState(() {
                  _selectedType = 'expense';
                  _selectedMerchant = _merchants.firstWhere((m) => m.name == 'Netflix', orElse: () => _merchants.last);
                  _selectedMerchantName = _selectedMerchant.name;
                  _payeeController.text = _selectedMerchant.name;
                  _titleController.text = _selectedMerchant.name;
                  _selectedCategory = _selectedMerchant.defaultCategory;
                });
                Get.back();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_received_rounded, color: AppTheme.incomeColor),
              ),
              title: const Text('Income', style: TextStyle(fontWeight: FontWeight.bold)),
              selected: _selectedType == 'income',
              onTap: () {
                setState(() {
                  _selectedType = 'income';
                  _selectedMerchant = _merchants.firstWhere((m) => m.name == 'Upwork', orElse: () => _merchants.last);
                  _selectedMerchantName = _selectedMerchant.name;
                  _payeeController.text = _selectedMerchant.name;
                  _titleController.text = _selectedMerchant.name;
                  _selectedCategory = _selectedMerchant.defaultCategory;
                });
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMerchantPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Merchant / Payee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _merchants.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  color: Get.isDarkMode ? Colors.white10 : Colors.black12
                ),
                itemBuilder: (context, index) {
                  final merchant = _merchants[index];
                  return ListTile(
                    leading: _buildMerchantLogo(merchant, size: 36),
                    title: Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      setState(() {
                        _selectedMerchant = merchant;
                        _selectedMerchantName = merchant.name;
                        if (merchant.name != 'Other') {
                          _payeeController.text = merchant.name;
                          _titleController.text = merchant.name;
                          _selectedCategory = merchant.defaultCategory;
                        } else {
                          _payeeController.clear();
                          _titleController.clear();
                          _selectedCategory = 'Other';
                        }
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final categories = _selectedType == 'income' ? _incomeCategories : _expenseCategories;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: _selectedCategory == cat ? Icon(Icons.check_circle, color: _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor) : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker() {
    final wallets = walletController.wallets;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Card / Wallet Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  final isSelected = _selectedWalletId == wallet.id;
                  final activeColor = _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor;
                  return ListTile(
                    leading: Icon(Icons.credit_card_rounded, color: activeColor),
                    title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(wallet.cardNumber.split(' ').last),
                    trailing: isSelected ? Icon(Icons.check_circle, color: activeColor) : null,
                    onTap: () {
                      setState(() {
                        _selectedWalletId = wallet.id;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceSelector() {
    final activeColor = _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attach Invoice / Receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: activeColor),
              title: const Text('Simulate Camera Photo'),
              onTap: () {
                setState(() {
                  _selectedInvoiceName = 'receipt_${_selectedMerchantName.toLowerCase()}_camera.jpg';
                });
                Get.back();
                Get.snackbar('Mock Attached', 'Simulated camera photo upload.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.incomeColor.withOpacity(0.9),
                    colorText: Colors.white);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              title: const Text('Simulate PDF Document'),
              onTap: () {
                setState(() {
                  _selectedInvoiceName = 'invoice_${_selectedMerchantName.toLowerCase()}.pdf';
                });
                Get.back();
                Get.snackbar('Mock Attached', 'Simulated PDF document upload.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.incomeColor.withOpacity(0.9),
                    colorText: Colors.white);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.blue),
              title: const Text('Simulate Gallery Upload'),
              onTap: () {
                setState(() {
                  _selectedInvoiceName = 'bill_${_selectedMerchantName.toLowerCase()}_screenshot.png';
                });
                Get.back();
                Get.snackbar('Mock Attached', 'Simulated gallery upload.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.incomeColor.withOpacity(0.9),
                    colorText: Colors.white);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor;
    final isDark = Get.isDarkMode;
    final isSystemKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Stack(
          children: [
                  // Curved Teal Header background
                  ClipPath(
                    clipper: HeaderWaveClipper(),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor,
                            _selectedType == 'income' 
                                ? AppTheme.incomeColor.withOpacity(0.8) 
                                : AppTheme.secondaryColor,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Soft circle rings ornaments
                          Positioned(
                            top: -40,
                            left: -40,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 26,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -30,
                            top: -10,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form Overlay
                  Padding(
                    padding: const EdgeInsets.only(top: 130, left: 20, right: 20, bottom: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME (Merchant selector)
                            _buildFieldLabel('NAME'),
                            GestureDetector(
                              onTap: _showMerchantPicker,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    _buildMerchantLogo(_selectedMerchant),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedMerchantName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            // CUSTOM NAME (if "Other" selected)
                            if (_selectedMerchantName == 'Other') ...[
                              _buildFieldLabel('CUSTOM PAYEE / NAME'),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: TextFormField(
                                  controller: _titleController,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter payee or title...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    _payeeController.text = val;
                                  },
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Required';
                                    return null;
                                  },
                                ),
                              ),
                            ],

                            // AMOUNT
                            _buildFieldLabel('AMOUNT'),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkBg : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: activeColor,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '\$',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: activeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: activeColor,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Required';
                                        final double? amt = double.tryParse(val);
                                        if (amt == null || amt <= 0) return 'Enter a valid amount';
                                        return null;
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _clearAmount,
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: activeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // DATE
                            _buildFieldLabel('DATE'),
                            GestureDetector(
                              onTap: _presentDatePicker,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 20),
                                  ],
                                ),
                              ),
                            ),

                            // CATEGORY
                            _buildFieldLabel('CATEGORY'),
                            GestureDetector(
                              onTap: _showCategoryPicker,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedCategory,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            // WALLET
                            _buildFieldLabel('WALLET / SOURCE'),
                            GestureDetector(
                              onTap: _showWalletPicker,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() {
                                        final wallet = walletController.wallets.firstWhereOrNull((w) => w.id == _selectedWalletId);
                                        return Text(
                                          wallet != null 
                                              ? '${wallet.name} (${wallet.cardNumber.split(' ').last})'
                                              : 'Select Wallet',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        );
                                      }),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            // NOTE (Optional description)
                            _buildFieldLabel('NOTE (OPTIONAL)'),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkBg : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: TextField(
                                controller: _noteController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: 'Add description...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            // INVOICE
                            _buildFieldLabel('INVOICE'),
                            _buildInvoiceField(activeColor),

                            const SizedBox(height: 30),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: activeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  _selectedType == 'expense' ? 'Save Expense' : 'Save Income',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Header actions row (AppBar overlay)
                  Positioned(
                    top: 50,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Get.back(),
                        ),
                        Text(
                          _selectedType == 'expense' ? 'Add Expense' : 'Add Income',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
                          onPressed: _showTypeChangeMenu,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMerchantLogo(MerchantItem merchant, {double size = 36}) {
    if (merchant.logoType == 'netflix') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'N',
          style: TextStyle(
            color: const Color(0xFFE50914), // Netflix Red
            fontWeight: FontWeight.w900,
            fontSize: size * 0.55,
            letterSpacing: -1,
          ),
        ),
      );
    } else if (merchant.logoType == 'asset' && merchant.assetPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          merchant.assetPath!,
          width: size - 12,
          height: size - 12,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            merchant.fallbackIcon ?? Icons.storefront_rounded,
            color: Colors.grey,
            size: size - 16,
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (_selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          merchant.fallbackIcon ?? Icons.storefront_rounded,
          color: _selectedType == 'income' ? AppTheme.incomeColor : AppTheme.primaryColor,
          size: size * 0.55,
        ),
      );
    }
  }

  Widget _buildInvoiceField(Color activeColor) {
    return GestureDetector(
      onTap: _showInvoiceSelector,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Get.isDarkMode ? Colors.white24 : Colors.black12,
          borderRadius: 16.0,
          dashLength: 6,
          gap: 4,
        ),
        child: Container(
          width: double.infinity,
          height: 65,
          alignment: Alignment.center,
          child: _selectedInvoiceName != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        _selectedInvoiceName!.endsWith('.pdf')
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_rounded,
                        color: _selectedInvoiceName!.endsWith('.pdf') ? Colors.red : activeColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedInvoiceName!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedInvoiceName = null;
                          });
                        },
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: activeColor, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Invoice',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }


}

class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width / 2, size.height + 15);
    final firstEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dashLength = 5.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
