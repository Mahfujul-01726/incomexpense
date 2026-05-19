import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_model.dart';
import '../../theme/app_theme.dart';

class ConnectWalletScreen extends StatefulWidget {
  const ConnectWalletScreen({super.key});

  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final walletController = Get.find<WalletController>();
  final PageController _flowController = PageController();
  int _currentStep = 0;

  // Selected values
  String _selectedType = ''; // 'bank' | 'card' | 'manual'
  String _selectedBank = '';
  
  // Controllers for manual input
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _holderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();

  final List<Map<String, String>> _popularBanks = [
    {'name': 'PayPal', 'logo': 'PayPal'},
    {'name': 'Chase Bank', 'logo': 'Chase'},
    {'name': 'Bank of America', 'logo': 'Visa'},
    {'name': 'Wells Fargo', 'logo': 'Visa'},
    {'name': 'Citibank', 'logo': 'Visa'},
    {'name': 'Capital One', 'logo': 'Visa'},
    {'name': 'HSBC', 'logo': 'Visa'},
    {'name': 'Barclays', 'logo': 'Visa'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _holderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _flowController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Get.back();
      return;
    }
    setState(() {
      _currentStep--;
    });
    _flowController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _selectType(String type) {
    _selectedType = type;
    if (type == 'manual') {
      _nameController.text = 'My Cash Wallet';
      _holderController.text = 'Mahfujur Rahman';
      _cardNumberController.text = 'N/A';
      _expiryController.text = 'N/A';
      _flowController.jumpToPage(2); // Jump straight to details
      setState(() {
        _currentStep = 2;
      });
    } else {
      _nextStep();
    }
  }

  void _selectBank(String bankName, String bankLogo) {
    _selectedBank = bankName;
    _nameController.text = bankName;
    _holderController.text = 'Mahfujur Rahman';
    _expiryController.text = '12/30';
    
    // Generate random mock card number
    if (_selectedType == 'card') {
      _cardNumberController.text = '**** **** **** ${1000 + (bankName.hashCode % 8999)}';
    } else {
      _cardNumberController.text = '**** **** **** ${8000 + (bankName.hashCode % 1999)}';
    }

    _nextStep();
  }

  void _saveWallet() {
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a wallet name', backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    // Add wallet
    final newWallet = WalletModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      balance: balance,
      cardHolder: _holderController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      type: _selectedType,
      colorIndex: walletController.wallets.length % AppTheme.cardGradients.length,
      bankLogo: _selectedBank.isNotEmpty ? _selectedBank.split(' ')[0] : 'Visa',
    );

    walletController.addWallet(newWallet);
    Get.back();
    Get.snackbar(
      'Wallet Connected',
      'Successfully added "${newWallet.name}" to your wallets.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.incomeColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Wallet'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _prevStep,
        ),
      ),
      body: PageView(
        controller: _flowController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSelectTypeStep(),
          _buildSelectBankStep(),
          _buildCustomDetailsStep(),
        ],
      ),
    );
  }

  Widget _buildSelectTypeStep() {
    final optionList = [
      {
        'id': 'bank',
        'title': 'Link Bank Account',
        'desc': 'Log in to your bank securely and sync details.',
        'icon': Icons.account_balance_rounded,
        'color': AppTheme.primaryColor
      },
      {
        'id': 'card',
        'title': 'Link Credit/Debit Card',
        'desc': 'Visa, Mastercard, Amex, Discover, etc.',
        'icon': Icons.credit_card_rounded,
        'color': AppTheme.secondaryColor
      },
      {
        'id': 'manual',
        'title': 'Manual Wallet / Cash',
        'desc': 'Add cash pockets or local accounts manually.',
        'icon': Icons.add_circle_outline_rounded,
        'color': AppTheme.incomeColor
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Link a connection source',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Link your bank accounts or card to automatically sync your income and expenses, or keep a manual ledger.',
            style: TextStyle(
              color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: optionList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final opt = optionList[index];
                return GestureDetector(
                  onTap: () => _selectType(opt['id'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Get.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (opt['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSelectBankStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedType == 'bank' ? 'Select your bank' : 'Select card issuer',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search box
          TextField(
            decoration: InputDecoration(
              hintText: 'Search provider...',
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Get.isDarkMode ? AppTheme.darkSurface : Colors.black.withOpacity(0.04),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.4,
              ),
              itemCount: _popularBanks.length,
              itemBuilder: (context, index) {
                final bank = _popularBanks[index];
                return GestureDetector(
                  onTap: () => _selectBank(bank['name']!, bank['logo']!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Get.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          bank['logo'] == 'PayPal'
                              ? Icons.paypal
                              : bank['logo'] == 'Chase'
                                  ? Icons.account_balance
                                  : Icons.credit_card,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bank['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm connection details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill out the initial credentials. We will simulate connecting to this wallet.',
            style: TextStyle(
              color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 28),
          // Form fields
          _buildTextField('Wallet/Bank Name', _nameController, hint: 'e.g. My Savings Account'),
          const SizedBox(height: 16),
          _buildTextField('Card/Account Holder Name', _holderController, hint: 'e.g. Mahfujur Rahman'),
          const SizedBox(height: 16),
          _buildTextField('Initial Balance', _balanceController, hint: 'e.g. 5000.00', inputType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField('Masked Card/Account Number', _cardNumberController, hint: 'e.g. **** **** **** 1234'),
          const SizedBox(height: 16),
          _buildTextField('Expiry Date', _expiryController, hint: 'e.g. MM/YY'),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveWallet,
              child: const Text('Link Account Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Get.isDarkMode ? AppTheme.darkSurface : Colors.black.withOpacity(0.04),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
