import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_model.dart';
import '../../theme/app_theme.dart';

class ConnectWalletScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ConnectWalletScreen({super.key, this.onBack});

  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final walletController = Get.find<WalletController>();
  
  int _selectedSegment = 0; // 0 = Cards, 1 = Accounts
  int _selectedAccountIndex = 0; // 0 = Bank Link, 1 = Microdeposits, 2 = Paypal

  // Controllers for Card details
  final _holderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill as shown in the screenshot for perfect visual fidelity
    _holderController.text = 'IRVAN MOSES';
    _cardNumberController.text = '6219  8610  2888  8075';
    _expiryController.text = '22/01';
    _cvcController.text = '123';
    _zipController.text = '90210';
  }

  @override
  void dispose() {
    _holderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveCardWallet() {
    final holder = _holderController.text.trim();
    final number = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();

    if (holder.isEmpty) {
      Get.snackbar('Error', 'Please enter holder name', backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }
    if (number.isEmpty) {
      Get.snackbar('Error', 'Please enter card number', backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    final newWallet = WalletModel(
      id: const Uuid().v4(),
      name: 'Mono Debit Card',
      balance: 5750.25, // Mock default card balance
      cardHolder: holder,
      cardNumber: number.length > 4 ? '**** **** **** ${number.replaceAll(' ', '').substring(number.replaceAll(' ', '').length - 4)}' : number,
      expiryDate: expiry.isEmpty ? '12/28' : expiry,
      type: 'card',
      colorIndex: walletController.wallets.length % AppTheme.cardGradients.length,
      bankLogo: 'Visa', // Since it is Visa style
    );

    walletController.addWallet(newWallet);
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Get.back();
    }
    Get.snackbar(
      'Wallet Connected',
      'Successfully added "${newWallet.name}" to your wallets.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.incomeColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _saveAccountWallet() {
    WalletModel newWallet;
    if (_selectedAccountIndex == 0) {
      newWallet = WalletModel(
        id: const Uuid().v4(),
        name: 'Bank Link Account',
        balance: 15000.00,
        cardHolder: 'Mahfujur Rahman',
        cardNumber: '•••• •••• •••• 8812',
        expiryDate: 'N/A',
        type: 'bank',
        colorIndex: walletController.wallets.length % AppTheme.cardGradients.length,
        bankLogo: 'Chase',
      );
    } else if (_selectedAccountIndex == 1) {
      newWallet = WalletModel(
        id: const Uuid().v4(),
        name: 'Microdeposits Account',
        balance: 500.00,
        cardHolder: 'Mahfujur Rahman',
        cardNumber: '•••• •••• •••• 2345',
        expiryDate: 'N/A',
        type: 'bank',
        colorIndex: walletController.wallets.length % AppTheme.cardGradients.length,
        bankLogo: 'Visa',
      );
    } else {
      newWallet = WalletModel(
        id: const Uuid().v4(),
        name: 'PayPal Wallet',
        balance: 890.50,
        cardHolder: 'Mahfujur Rahman',
        cardNumber: 'paypal@example.com',
        expiryDate: 'N/A',
        type: 'bank',
        colorIndex: walletController.wallets.length % AppTheme.cardGradients.length,
        bankLogo: 'PayPal',
      );
    }

    walletController.addWallet(newWallet);
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Get.back();
    }
    Get.snackbar(
      'Account Linked',
      'Successfully connected "${newWallet.name}" to your wallets.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.incomeColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Curved Teal Header
          Stack(
            children: [
              // Teal Header Container with decorative rings
              Container(
                height: statusBarHeight + 80, // height including status bar
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2F7E79),
                      Color(0xFF25726D),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative ring 1
                    Positioned(
                      top: -45,
                      left: -45,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 18,
                          ),
                        ),
                      ),
                    ),
                    // Decorative ring 2
                    Positioned(
                      top: -25,
                      right: -35,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Header Row content
              Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight + 10,
                  left: 10,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Get.back();
                        }
                      },
                    ),
                    const Text(
                      'Connect Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Notification Icon inside translucent box
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.orangeAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Main Body with White Background
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Column(
                  children: [
                    // Segmented Control
                    _buildSegmentedControl(),
                    
                    // Views Content
                    Expanded(
                      child: _selectedSegment == 0 
                          ? _buildCardsView() 
                          : _buildAccountsView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Get.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(0, 'Cards'),
          ),
          Expanded(
            child: _buildSegmentButton(1, 'Accounts'),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label) {
    final isSelected = _selectedSegment == index;
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkBg : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF222222))
                : (isDark ? Colors.white60 : const Color(0xFF888888)),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Credit Card stack
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Background card peaking out
                  Container(
                    height: 165,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25726D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Foreground Card
                  Container(
                    height: 185,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 8, right: 8, top: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2F7E79),
                          Color(0xFF429690),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2F7E79).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Wave patterns on card
                        Positioned(
                          right: -60,
                          bottom: -60,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.04),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -40,
                          bottom: -40,
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.07),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Debit Card',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Mono',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              // Card chip
                              Container(
                                width: 34,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                              // Card Number
                              Text(
                                _cardNumberController.text.isEmpty
                                    ? '••••  ••••  ••••  ••••'
                                    : _cardNumberController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              // Holder & Expiry
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _holderController.text.isEmpty
                                          ? 'CARD HOLDER'
                                          : _holderController.text.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _expiryController.text.isEmpty
                                        ? 'MM/YY'
                                        : _expiryController.text,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Form Content
          const Text(
            'Add your debit Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This card must be connected to a bank account under your name',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          
          // Input Fields
          _buildInputField(
            labelText: 'Name on card',
            controller: _holderController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField(
                  labelText: 'Debit card number',
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CardNumberFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildInputField(
                  labelText: 'CVC',
                  controller: _cvcController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField(
                  labelText: 'Expiration MM/YY',
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildInputField(
                  labelText: 'ZIP',
                  controller: _zipController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCardWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F7E79),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Link Card Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountOption(
            index: 0,
            title: 'Bank Link',
            desc: 'Connect your bank account to deposit & fund',
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: 16),
          _buildAccountOption(
            index: 1,
            title: 'Microdeposits',
            desc: 'Connect bank in 5-7 days',
            icon: Icons.monetization_on_rounded,
          ),
          const SizedBox(height: 16),
          _buildAccountOption(
            index: 2,
            title: 'Paypal',
            desc: 'Connect you paypal account',
            icon: Icons.paypal,
            imagePath: 'assets/cropped/logo_paypal.png',
          ),
          const SizedBox(height: 60), // spacer before button
          OutlinedButton(
            onPressed: _saveAccountWallet,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2F7E79), width: 1.5),
              minimumSize: const Size(double.infinity, 54),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                color: Color(0xFF2F7E79),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption({
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    String? imagePath,
  }) {
    final isSelected = _selectedAccountIndex == index;
    final isDark = Get.isDarkMode;
    
    final bgColor = isSelected 
        ? (isDark ? const Color(0xFF1E3A37) : const Color(0xFFEEF7F6))
        : (isDark ? AppTheme.darkSurface : const Color(0xFFF8FAFC));
        
    final borderColor = isSelected 
        ? const Color(0xFF2F7E79).withValues(alpha: 0.4)
        : Colors.transparent;
        
    final iconBgColor = isSelected 
        ? Colors.white
        : (isDark ? Colors.white10 : const Color(0xFFE2E8F0));
        
    final iconColor = isSelected 
        ? const Color(0xFF2F7E79)
        : (isDark ? const Color(0xFF94A3B8) : Colors.white);

    final Widget iconWidget = imagePath != null
        ? ClipOval(
            child: Image.asset(
              imagePath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(icon, color: iconColor, size: 24);
              },
            ),
          )
        : Icon(icon, color: iconColor, size: 24);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2F7E79).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? const Color(0xFF2F7E79)
                          : (isDark ? Colors.white : const Color(0xFF475569)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF2F7E79).withValues(alpha: 0.7)
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2F7E79),
                size: 26,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    final isDark = Get.isDarkMode;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF222222),
      ),
      decoration: InputDecoration(
        labelText: labelText.toUpperCase(),
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF2F7E79),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: isDark ? AppTheme.darkSurface : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2F7E79),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // 2 spaces
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
