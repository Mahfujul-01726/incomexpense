class AppConstants {
  AppConstants._();

  // Routes
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeSignin = '/signin';
  static const String routeDashboard = '/dashboard';
  static const String routeBills = '/bills';

  // SharedPreferences keys
  static const String prefTransactions = 'transactions';
  static const String prefWallets = 'wallets';
  static const String prefWalletsMigrated = 'wallets_migrated';
  static const String prefBills = 'bills';
  static const String prefBillsVersion = 'bills_version';
  static const String prefProfileName = 'profile_name';
  static const String prefProfileEmail = 'profile_email';
  static const String prefProfilePhone = 'profile_phone';
  static const String prefIsDarkTheme = 'is_dark_theme';
  static const String prefReceiveNotifications = 'receive_notifications';
  static const String prefBiometricsEnabled = 'biometrics_enabled';
  static const String prefOnboardingCompleted = 'onboarding_completed';

  // Transaction types
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';

  // Transaction statuses
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusFailed = 'failed';

  // Wallet types
  static const String walletCard = 'card';
  static const String walletBank = 'bank';
  static const String walletCash = 'cash';

  // Default profile values
  static const String defaultProfileName = 'Enjelin Morgeana';
  static const String defaultProfileEmail = 'enjelin@community.com';
  static const String defaultProfilePhone = '+1 (555) 019-2834';
}
