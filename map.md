# Income & Expense Tracker — Codebase Map

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── bindings/                          # GetX dependency injection bindings
│   ├── onboarding_binding.dart        # Injects OnboardingController
│   ├── dashboard_binding.dart         # Injects Navigation, Wallet, Transaction, Profile controllers
│   └── bills_binding.dart             # Injects BillController
├── constants/
│   ├── app_constants.dart             # Routes, SharedPreferences keys, default values
│   └── image_assets.dart              # All image asset paths
├── data/
│   └── mock_data.dart                 # Default mock transactions, wallets, bills
├── models/                            # Data models with JSON serialization
│   ├── transaction_model.dart         # id, title, amount, type, category, date, walletId, payee, note, status
│   ├── wallet_model.dart              # id, name, balance, cardHolder, cardNumber, expiryDate, type, colorIndex, bankLogo
│   └── bill_model.dart                # id, name, amount, dueDate, isPaid, category, autoPay, provider (+ copyWith)
├── pages/
│   ├── splash/
│   │   ├── splash_view.dart           # Full-screen splash image with fade animation
│   │   └── splash_controller.dart     # 2.5s delay → check Firebase auth → check onboarding → navigate
│   ├── onboarding/
│   │   ├── onboarding_view.dart       # "Spend Smarter Save More" + "Get Started"/"Log In"
│   │   └── onboarding_controller.dart # completeOnboarding() → signin; finishOnboarding() → save flag → dashboard
│   ├── auth/
│   │   ├── auth_controller.dart       # Google sign-in, sign-out, Firebase auth state stream
│   │   └── signin/
│   │       └── signin_view.dart       # "Welcome!" + Google sign-in + "Continue as Guest"
│   ├── dashboard/
│   │   ├── dashboard_view.dart        # IndexedStack of 4 tabs + FAB → AddTransactionScreen
│   │   └── navigation_controller.dart # selectedIndex observable, changeTab()
│   ├── home/
│   │   ├── home_tab.dart              # Greeting, balance card, transactions list (last 4), "Send Again"
│   │   ├── transaction_controller.dart# CRUD transactions, period/type filtering, category breakdown, totals
│   │   └── transaction_details_view.dart# Invoice-style detail view, delete with wallet reversal, "Download Receipt"
│   ├── statistics/
│   │   └── statistics_tab.dart        # Period filter (Day/Week/Month/Year), type dropdown, fl_chart line chart, "Top Spending"
│   ├── wallet/
│   │   ├── wallet_tab.dart            # Balance, Add/Pay/Send actions, Transactions/Upcoming Bills tabs
│   │   ├── wallet_controller.dart     # CRUD wallets, updateWalletBalance (income + / expense -)
│   │   ├── connect_wallet_view.dart   # Cards/Accounts segmented + card form with live preview, account picker
│   │   └── qr_scanner_view.dart       # Camera QR scan via mobile_scanner, returns scanned value
│   ├── add_transaction/
│   │   └── add_transaction_view.dart  # Merchant picker, amount, date, category, wallet, note, invoice mock
│   ├── profile/
│   │   ├── profile_tab.dart           # Avatar, name, menu: Invite/Account/Personal/Security/Data/Sign Out
│   │   └── profile_controller.dart    # Load/save name, email, phone, dark theme, notifications, biometrics
│   └── bills/
│       ├── bills_view.dart            # TabBar: Upcoming/Due + Paid History, "Add Bill" dialog
│       ├── bill_controller.dart       # CRUD bills, toggleAutoPay, payBill (marks paid + creates transaction)
│       ├── bill_details_view.dart     # Invoice layout, payment method picker, "Pay Now"
│       └── bill_payment_view.dart     # 3-step wizard: Review → Confirm → Success receipt
├── routes/
│   ├── routes.dart                    # Route constants
│   └── pages.dart                     # GetPage definitions with bindings
├── services/
│   ├── auth_service.dart              # GoogleSignIn + FirebaseAuth wrapper
│   └── preferences_service.dart       # SharedPreferences + FlutterSecureStorage with migration logic
├── theme/
│   └── app_theme.dart                 # Light/dark themes, Google Fonts (Outfit), card gradients, colors
├── utils/
│   ├── calculations.dart              # calculateFee(amount) → 2.9% + $0.30
│   ├── date_helpers.dart              # formatTransactionDate → "Today"/"Yesterday"/"MMM d, yyyy"
│   └── logo_helpers.dart              # getTransactionLogoAsset, getBillLogoAsset, getLogoPadding
└── widgets/
    ├── app_bottom_nav.dart            # BottomAppBar with 4 nav items + center FAB spacer
    ├── transaction_logo_widget.dart   # Logo or fallback icon for transaction items
    ├── bill_logo_widget.dart          # Logo or fallback for bill items
    ├── header_wave_clipper.dart       # CustomClipper for curved header bottom wave
    ├── dashed_border_painter.dart     # CustomPainter for dashed border on invoice upload
    └── payment_option_card.dart       # Radio-button card + DebitCardLogo, PayPalLogo, InvoiceRow, TransactionDetailRow
```

---

## App Flow

```
main()
  │
  ├── Firebase.initializeApp()
  ├── Get.putAsync(PreferencesService().init())   ← SharedPreferences + FlutterSecureStorage (with migration)
  ├── Get.put(AuthController())                   ← Firebase auth state stream
  │
  └── runApp(MyApp) → GetMaterialApp(
        initialRoute: '/splash',
        getPages: [
          '/splash'     → SplashScreen
          '/onboarding' → OnboardingScreen  (OnboardingBinding)
          '/signin'     → SignInScreen
          '/dashboard'  → DashboardScreen     (DashboardBinding)
          '/bills'      → BillsScreen         (BillsBinding)
        ]
      )
```

---

## Navigation Flow & Routes

| Route | Screen | Binding Injected |
|-------|--------|-----------------|
| `/splash` | SplashScreen | (none — local controller) |
| `/onboarding` | OnboardingScreen | OnboardingController |
| `/signin` | SignInScreen | (none — uses global AuthController) |
| `/dashboard` | DashboardScreen | NavigationController, WalletController, TransactionController, ProfileController |
| `/bills` | BillsScreen | BillController |

**Splash → Decision Tree:**
```
SplashScreen (2.5s fade animation)
  │
  ├── FirebaseAuth.currentUser != null?
  │     YES → Get.offAllNamed('/dashboard')
  │
  └── NO → PreferencesService.getOnboardingCompleted()?
        YES → Get.offAllNamed('/dashboard')
        NO  → Get.offAllNamed('/onboarding')
```

---

## Dashboard Tab System

**DashboardScreen** uses `IndexedStack` with 4 tabs controlled by `NavigationController.selectedIndex`:

| Index | Tab | Key Features |
|-------|-----|-------------|
| 0 | **HomeTab** | Greeting ("Good afternoon, {name}"), balance card (total/income/expense), last 4 transactions, "Send Again" avatars |
| 1 | **StatisticsTab** | Period filter (Day/Week/Month/Year), type (Expense/Income), fl_chart line chart with touch interaction, Top 3 spending |
| 2 | **WalletTab** | Total balance, Add/Pay/Send actions, sub-tabs: Transactions list / Upcoming Bills with "Pay" buttons |
| 3 | **ProfileTab** | Avatar, name/@handle, menu: Invite Friends, Account info (edit dialog), Personal profile (notifications toggle), Security (fingerprint lock), Data & Privacy (export), Sign Out |

**FAB** ("+" button) on Dashboard → `AddTransactionScreen` (pushed via `Get.to`)

---

## Controllers & Dependencies

### Global (initialized in main.dart)
- **`PreferencesService`** (`Get.putAsync`) — encrypted storage for all data, auto-migrates from SharedPreferences to FlutterSecureStorage
- **`AuthController`** (`Get.put`) — Firebase auth state, `signInWithGoogle()`, `signOut()`

### Dashboard-scoped (injected by DashboardBinding)
- **`NavigationController`** → `selectedIndex` observable, `changeTab(int)`
- **`WalletController`** → `wallets` list, `totalBalance`, `addWallet()`, `updateWalletBalance(walletId, amount, type)`
- **`TransactionController`** → `transactions` list, CRUD operations, `filteredTransactions` (by period+type), `categoryBreakdown`, `totalIncome`/`totalExpenses`
- **`ProfileController`** → `name`, `email`, `phone`, `isDarkTheme`, `receiveNotifications`, `biometricsEnabled`

### Onboarding-scoped (injected by OnboardingBinding)
- **`OnboardingController`** → `completeOnboarding()` (navigates to signin), `finishOnboarding()` (saves flag → dashboard)

### Bills-scoped (injected by BillsBinding)
- **`BillController`** → `bills` list, `addBill()`, `toggleAutoPay()`, `payBill(id, walletId, createTransaction)`

---

## Data Storage

| Data | Storage Backend | Key Prefix | Format |
|------|----------------|-----------|--------|
| Transactions | FlutterSecureStorage | `transactions` | JSON array |
| Wallets | FlutterSecureStorage | `wallets` | JSON array |
| Bills | FlutterSecureStorage | `bills` | JSON array |
| Profile name/email/phone | FlutterSecureStorage | `profile_name`, etc. | String |
| Onboarding flag | SharedPreferences | `onboarding_completed` | bool |
| Dark theme | SharedPreferences | `is_dark_theme` | bool |
| Notifications | SharedPreferences | `receive_notifications` | bool |
| Biometrics | FlutterSecureStorage | `biometrics_enabled` | bool |

**Migration logic:** On first launch, `PreferencesService._migrateIfNecessary()` transfers all sensitive data from SharedPreferences to FlutterSecureStorage.

---

## Key Transactions

### Adding a Transaction (expense example)
```
AddTransactionScreen
  ├── User picks merchant (Netflix/YouTube/Starbucks/PayPal/Upwork/Other)
  ├── Fills amount, date, category, wallet, note (invoice attachment is mock)
  └── _submitData()
        ├── Creates TransactionModel (id: UUID, status: 'completed')
        └── txController.addTransaction(newTx)
              ├── transactions.insert(0, newTx)    ← reactive list updates UI
              ├── saveTransactions()               ← secure storage
              └── WalletController.updateWalletBalance(walletId, amount, 'expense')
                    ├── wallet.balance -= amount
                    └── saveWallets()
```

### Deleting a Transaction
```
TransactionDetailsScreen → delete button
  └── txController.deleteTransaction(id)
        ├── transactions.removeAt(index)
        ├── saveTransactions()
        └── WalletController.updateWalletBalance(walletId, amount, reverseType)
              └── reverses the original income/expense effect
```

### Paying a Bill
```
BillsScreen / WalletTab → "Pay" button
  └── BillPaymentScreen (3-step wizard)
        Step 1: Review bill details + select payment method
        Step 2: Confirm payment summary
        Step 3: Success screen with receipt
        └── _processPayment()
              └── billController.payBill(id, walletId, createTransaction: false)
                    ├── bill.isPaid = true
                    ├── saveBills()
                    └── (transaction is NOT auto-created; payment is just marked paid)
```

### Sending Money (from WalletTab → "Send")
```
WalletTab → "Send" bottom sheet
  ├── Enter recipient name, amount, select wallet
  └── walletController.updateWalletBalance(walletId, amount, 'expense')
      txController.addTransaction(TransactionModel(type:'expense', category:'Transfer'))
```

---

## Theme System

- **Colors:** Primary teal (#429690), Secondary (#2F7E79), Income green (#25A969), Expense red (#F95B5A), Warning amber (#F59E0B)
- **Font:** Google Fonts "Outfit" throughout the app
- **Dark Mode:** Toggle in Profile → Personal profile (currently UI supports it but themeMode is hardcoded to `ThemeMode.light` in main.dart)
- **Card Gradients:** 5 predefined gradient pairs in `AppTheme.cardGradients` for wallet cards
- **Decorative pattern:** Concentric circles + `HeaderWaveClipper` on most screens (Home, AddTransaction, Wallet, Profile, TransactionDetails, BillDetails)

---

## Key Dependencies (pubspec.yaml)

| Package | Purpose |
|---------|---------|
| `get` ^4.7.3 | State management, DI, routing |
| `fl_chart` ^1.2.0 | Statistics line chart |
| `intl` ^0.20.2 | Date/number formatting |
| `google_fonts` ^8.1.0 | Outfit font |
| `shared_preferences` ^2.5.5 | Simple key-value storage |
| `flutter_secure_storage` ^10.3.0 | Encrypted storage for sensitive data |
| `uuid` ^4.5.3 | Generate unique IDs |
| `firebase_core` ^3.6.0 | Firebase initialization |
| `firebase_auth` ^5.3.1 | Firebase Authentication |
| `google_sign_in` ^6.2.1 | Google Sign-In |
| `mobile_scanner` ^7.2.0 | QR code scanning |
| `permission_handler` ^12.0.1 | Camera permission |

---

## File Index (all 30 Dart files)

| # | File Path | Role |
|---|-----------|------|
| 1 | `lib/main.dart` | App entry, Firebase init, DI setup |
| 2 | `lib/routes/routes.dart` | Route name constants |
| 3 | `lib/routes/pages.dart` | GetPage route definitions |
| 4 | `lib/bindings/onboarding_binding.dart` | DI: OnboardingController |
| 5 | `lib/bindings/dashboard_binding.dart` | DI: Navigation, Wallet, Transaction, Profile controllers |
| 6 | `lib/bindings/bills_binding.dart` | DI: BillController |
| 7 | `lib/constants/app_constants.dart` | Route keys, pref keys, default values |
| 8 | `lib/constants/image_assets.dart` | Image path constants |
| 9 | `lib/data/mock_data.dart` | Default mock transactions, wallets, bills |
| 10 | `lib/models/transaction_model.dart` | Transaction data model |
| 11 | `lib/models/wallet_model.dart` | Wallet data model |
| 12 | `lib/models/bill_model.dart` | Bill data model (+ copyWith) |
| 13 | `lib/services/auth_service.dart` | Google + Firebase auth wrapper |
| 14 | `lib/services/preferences_service.dart` | Secure/preferences storage with migration |
| 15 | `lib/theme/app_theme.dart` | Light/dark theme definitions |
| 16 | `lib/utils/calculations.dart` | Fee calculation |
| 17 | `lib/utils/date_helpers.dart` | Date formatting |
| 18 | `lib/utils/logo_helpers.dart` | Logo asset resolution |
| 19 | `lib/widgets/app_bottom_nav.dart` | Bottom navigation bar |
| 20 | `lib/widgets/transaction_logo_widget.dart` | Transaction logo display |
| 21 | `lib/widgets/bill_logo_widget.dart` | Bill logo display |
| 22 | `lib/widgets/header_wave_clipper.dart` | Header wave shape |
| 23 | `lib/widgets/dashed_border_painter.dart` | Dashed border for invoice |
| 24 | `lib/widgets/payment_option_card.dart` | Payment method card + related widgets |
| 25 | `lib/pages/splash/splash_view.dart` | Splash screen |
| 26 | `lib/pages/splash/splash_controller.dart` | Splash logic |
| 27 | `lib/pages/onboarding/onboarding_view.dart` | Onboarding screen |
| 28 | `lib/pages/onboarding/onboarding_controller.dart` | Onboarding navigation |
| 29 | `lib/pages/auth/auth_controller.dart` | Auth state management |
| 30 | `lib/pages/auth/signin/signin_view.dart` | Sign-in screen |
| 31 | `lib/pages/dashboard/dashboard_view.dart` | Main dashboard scaffold |
| 32 | `lib/pages/dashboard/navigation_controller.dart` | Tab navigation state |
| 33 | `lib/pages/home/home_tab.dart` | Home tab content |
| 34 | `lib/pages/home/transaction_controller.dart` | Transaction CRUD + filtering |
| 35 | `lib/pages/home/transaction_details_view.dart` | Transaction detail view |
| 36 | `lib/pages/statistics/statistics_tab.dart` | Statistics + chart |
| 37 | `lib/pages/wallet/wallet_controller.dart` | Wallet CRUD + balance updates |
| 38 | `lib/pages/wallet/wallet_tab.dart` | Wallet tab content |
| 39 | `lib/pages/wallet/connect_wallet_view.dart` | Add card/bank wallet form |
| 40 | `lib/pages/wallet/qr_scanner_view.dart` | QR scanner screen |
| 41 | `lib/pages/add_transaction/add_transaction_view.dart` | Add transaction form |
| 42 | `lib/pages/profile/profile_controller.dart` | Profile settings management |
| 43 | `lib/pages/profile/profile_tab.dart` | Profile tab content |
| 44 | `lib/pages/bills/bill_controller.dart` | Bill CRUD + payment |
| 45 | `lib/pages/bills/bills_view.dart` | Bills list with tabs |
| 46 | `lib/pages/bills/bill_details_view.dart` | Bill detail invoice |
| 47 | `lib/pages/bills/bill_payment_view.dart` | Bill payment wizard |

---

## Complete Data Cycle (Example: User adds an expense)

```
1. User sees HomeTab → taps "+" FAB
2. Get.to(AddTransactionScreen) navigates to form
3. User fills: Netflix, $9.99, today, Subscriptions, Wallet1, "Monthly"
4. User taps "Save Expense"
5. _submitData() runs:
   a. Creates TransactionModel{id: uuid, title:'Netflix', amount:9.99, type:'expense', ...}
6. txController.addTransaction(tx)
   a. transactions.insert(0, tx)          ← Obx() reactive listeners fire
   b. _prefsService.saveTransactions()    ← encrypted storage
   c. Get.find<WalletController>().updateWalletBalance(walletId, 9.99, 'expense')
      i.  wallet.balance -= 9.99
      ii. saveWallets()                  ← encrypted storage
7. Get.back() returns to HomeTab
8. Obx() reactive listeners update:
   a. Balance card → new total/income/expense
   b. Transaction list → new item at top
```

**Files involved:** `add_transaction_view.dart:30` → `transaction_controller.dart:67` → `wallet_controller.dart:58` → `preferences_service.dart:53,62` → `home_tab.dart:140,250` (auto-updates via Obx)
