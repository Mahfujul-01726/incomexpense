# Income & Expense Tracker — Complete Code Flowchart

## 1. APP START — `main.dart`

```
main() runs
  │
  ├── Firebase.initializeApp()           ← starts Google login service
  ├── SharedPreferences.getInstance()    ← opens phone storage
  ├── Check: onboarding_completed?       ← have they seen intro?
  │
  ├── Get.put(AuthController())          ← creates & stores in memory
  ├── Get.put(ProfileController())       ← creates & stores in memory  
  ├── Get.put(WalletController())        ← creates & stores in memory
  ├── Get.put(TransactionController())   ← creates & stores in memory
  ├── Get.put(BillController())          ← creates & stores in memory
  ├── Get.put(OnboardingController())    ← creates & stores in memory
  ├── Get.put(NavigationController())    ← creates & stores in memory
  │
  └── runApp(MyApp())
        │
        └── GetMaterialApp(
              initialRoute: '/splash',
              routes:
                '/splash'      → SplashScreen
                '/onboarding'  → OnboardingScreen
                '/signin'      → SignInScreen
                '/dashboard'   → DashboardScreen
            )
```

---

## 2. SPLASH SCREEN — `views/splash_screen.dart`

```
SplashScreen shows (animated image for 2.5 seconds)
  │
  └── _navigateToNext()
        │
        ├── FirebaseAuth.instance.currentUser != null?
        │     YES → Get.offAllNamed('/dashboard')
        │
        └── NO → SharedPreferences: onboarding_completed?
              YES → Get.offAllNamed('/dashboard')
              NO  → Get.offAllNamed('/onboarding')
```

---

## 3. ONBOARDING — `views/onboarding/onboarding_screen.dart`

```
OnboardingScreen
  │
  ├── Shows 1 screen with:
  │     "Spend Smarter Save More" text
  │     "Get Started" button
  │     "Already Have Account? Log In" link
  │
  ├── Tap "Get Started" →
  │     controller.completeOnboarding()
  │     → Get.toNamed('/signin')
  │
  └── Tap "Log In" →
        Get.toNamed('/signin')
```

---

## 4. SIGN IN — `views/auth/signin_screen.dart`

```
SignInScreen
  │
  ├── Uses: Get.find<AuthController>()
  │        Get.find<OnboardingController>()
  │
  ├── Shows: app icon, "Welcome!", 3 feature rows
  │
  ├── "Continue with Google" button →
  │     authController.signInWithGoogle()
  │     │
  │     └── AuthController.signInWithGoogle()
  │           │
  │           ├── isLoading = true
  │           ├── _authService.signInWithGoogle()
  │           │     │
  │           │     └── auth_service.dart:
  │           │           GoogleSignIn.signIn()          ← opens Google popup
  │           │           googleUser.authentication      ← gets tokens
  │           │           FirebaseAuth.signInWithCredential()  ← logs into Firebase
  │           │           returns User
  │           │
  │           ├── if user != null →
  │           │     OnboardingController.finishOnboarding()
  │           │     │
  │           │     └── OnboardingController.finishOnboarding()
  │           │           │
  │           │           ├── SharedPreferences: onboarding_completed = true
  │           │           └── Get.offAllNamed('/dashboard')
  │           │
  │           └── catch error → Get.snackbar("Sign-In Failed")
  │
  └── "Continue as Guest" button →
        onboardingController.finishOnboarding()
        → same path: save flag → navigate to /dashboard
```

---

## 5. DASHBOARD — `views/dashboard_screen.dart`

```
DashboardScreen
  │
  ├── Finds: NavigationController (tracks selected tab index)
  │
  ├── _tabs = [HomeTab, StatisticsTab, WalletTab, ProfileTab]
  │
  ├── Body: IndexedStack (shows one tab at a time)
  │
  ├── FloatingActionButton "+" →
  │     Get.to(() => AddTransactionScreen())
  │
  └── bottomNavigationBar: AppBottomNav (4 icons)
        Home | Statistics | Wallet | Profile
```

---

## 6. HOME TAB — `views/home/home_tab.dart` (Tab Index 0)

```
HomeTab
  │
  ├── Uses: Get.find<TransactionController>()
  │        Get.find<WalletController>()
  │        Get.find<ProfileController>()
  │
  ├── BUILD:
  │     │
  │     ├── Greeting: "Good afternoon, [profileController.name]"
  │     │
  │     ├── Total Balance Card (Obx auto-updates):
  │     │     ├── walletController.totalBalance (sum of all wallets)
  │     │     ├── txController.totalIncome
  │     │     └── txController.totalExpenses
  │     │
  │     ├── "Transactions History" (last 4)
  │     │     ├── txController.transactions.take(4)
  │     │     ├── each shows: logo, title, date, amount (+/-)
  │     │     └── Tap → Get.to(TransactionDetailsScreen)
  │     │
  │     └── "Send Again" section
  │           └── shows 5 avatar images
  │
  └── ALSO CONTAINS: NavigationController class
        var selectedIndex = 0.obs
        changeTab(int index)  ← used by other tabs to switch to Home
```

---

## 7. ADD TRANSACTION — `views/add_transaction/add_transaction_screen.dart`

```
AddTransactionScreen
  │
  ├── Uses: Get.find<TransactionController>()
  │        Get.find<WalletController>()
  │
  ├── State variables:
  │     _selectedType = 'expense' | 'income'
  │     _selectedMerchant = Netflix/YouTube/Starbucks/PayPal/Upwork/Other
  │     _selectedCategory (10 expense / 7 income options)
  │     _selectedWalletId
  │     _selectedDate
  │     _amountController, _titleController, etc.
  │
  ├── Form fields:
  │     NAME (merchant picker) → _showMerchantPicker() bottom sheet
  │     AMOUNT (numeric input with $)
  │     DATE (date picker)
  │     CATEGORY (bottom sheet list)
  │     WALLET / SOURCE (bottom sheet, or link new)
  │     NOTE (optional text)
  │     INVOICE (mock attachment)
  │
  └── Tap "Save Expense" or "Save Income" →
        _submitData()
        │
        ├── validates form
        ├── creates TransactionModel(
        │     id: Uuid().v4(),
        │     title, amount, type, category, date,
        │     walletId, payee, note, status: 'completed'
        │   )
        │
        └── txController.addTransaction(newTx)
              │
              └── TransactionController.addTransaction()
                    │
                    ├── transactions.insert(0, transaction)    ← adds to top of list
                    ├── saveTransactions()                      ← saves to phone
                    │     │
                    │     └── SharedPreferences:
                    │           key: 'transactions'
                    │           value: JSON string of all transactions
                    │
                    └── WalletController.updateWalletBalance()
                          │
                          ├── finds wallet by walletId
                          ├── if income → balance += amount
                          ├── if expense → balance -= amount
                          └── saveWallets()    ← saves updated balance
```

---

## 8. TRANSACTION DETAILS — `views/home/transaction_details_screen.dart`

```
TransactionDetailsScreen(transaction: tx)
  │
  ├── Uses: Get.find<TransactionController>()
  │
  ├── Shows: logo, title, category badge
  │         Status (COMPLETED/PENDING)
  │         From/To, Time, Date, Spending, Fee
  │
  ├── Tap delete icon (trash) →
  │     _showDeleteConfirmation()
  │     │
  │     └── confirm →
  │           txController.deleteTransaction(widget.transaction.id)
  │           │
  │           └── TransactionController.deleteTransaction()
  │                 ├─ finds transaction in list
  │                 ├─ transactions.removeAt(index)
  │                 ├─ saveTransactions()
  │                 └─ WalletController.updateWalletBalance()
  │                       (reverse: income→expense, expense→income)
  │
  └── "Download Receipt" button → snackbar (mock)
```

---

## 9. STATISTICS TAB — `views/statistics/statistics_tab.dart` (Tab Index 1)

```
StatisticsTab
  │
  ├── Uses: Get.find<TransactionController>()
  │
  ├── Period Filter: Day | Week | Month | Year
  │     → txController.selectedPeriod.value = 'Week'
  │
  ├── Type dropdown: Expense | Income
  │     → txController.selectedType.value = 'expense'
  │
  ├── Line Chart (fl_chart):
  │     ├── Chart data changes based on period + type
  │     ├── Touch interaction highlights dots
  │     └── Tooltip shows dollar amount
  │
  └── "Top Spending" list (top 3 expenses by amount)
        └── Tap → Get.to(TransactionDetailsScreen)
```

---

## 10. WALLET TAB — `views/wallet/wallet_tab.dart` (Tab Index 2)

```
WalletTab
  │
  ├── Uses: Get.find<WalletController>()
  │        Get.find<TransactionController>()
  │        Get.find<BillController>()
  │
  ├── Shows: Total Balance (from wallets)
  │
  ├── Action buttons:
  │     "Add" → ConnectWalletScreen (add card/bank)
  │     "Pay" → QrScannerScreen (mock QR scan)
  │     "Send" → Bottom sheet: recipient + amount + wallet
  │               → creates Transaction + updates wallet balance
  │
  ├── Tab selector: "Transactions" | "Upcoming Bills"
  │
  ├── Transactions tab:
  │     ├── txController.transactions (sorted by date)
  │     └── each → tap → TransactionDetailsScreen
  │
  └── Upcoming Bills tab:
        ├── billController.bills (unpaid)
        └── each → "Pay" button → BillPaymentScreen
```

---

## 11. CONNECT WALLET — `views/wallet/connect_wallet_screen.dart`

```
ConnectWalletScreen
  │
  ├── Uses: Get.find<WalletController>()
  │
  ├── Segmented control: "Cards" | "Accounts"
  │
  ├── Cards view:
  │     ├── Visual credit card preview (live-updates)
  │     ├── Form: Name on card, card number, CVC, expiry, ZIP
  │     └── "Link Card Now" →
  │           _saveCardWallet()
  │           └── creates WalletModel(type:'card') → walletController.addWallet()
  │
  └── Accounts view:
        ├── Options: Bank Link | Microdeposits | PayPal
        └── "Next" →
              _saveAccountWallet()
              └── creates WalletModel(type:'bank') → walletController.addWallet()
```

---

## 12. PROFILE TAB — `views/profile/profile_tab.dart` (Tab Index 3)

```
ProfileTab
  │
  ├── Uses: Get.find<ProfileController>()
  │        Get.find<AuthController>()
  │
  ├── Shows: Avatar, name, @handle
  │
  ├── Menu options:
  │     ├── "Invite Friends" → snackbar (mock)
  │     │
  │     ├── "Account info" → edit dialog (name, email, phone)
  │     │     → profileController.updateProfile() → saves to SharedPreferences
  │     │
  │     ├── "Personal profile" → bottom sheet:
  │     │     ├── Dark Theme toggle
  │     │     │     → profileController.toggleTheme()
  │     │     │       ├── flips isDarkTheme
  │     │     │       ├── Get.changeThemeMode(dark/light)
  │     │     │       └── saves to SharedPreferences
  │     │     │
  │     │     └── Receive Notifications toggle
  │     │
  │     ├── "Login and security" → bottom sheet:
  │     │     └── Fingerprint Lock toggle
  │     │
  │     ├── "Data and privacy" → bottom sheet:
  │     │     └── Export Transactions (mock)
  │     │
  │     └── "Sign Out" (red text) →
  │           confirmation dialog →
  │           AuthController.signOut()
  │           ├── _authService.signOut()
  │           │     ├── GoogleSignIn.signOut()
  │           │     └── FirebaseAuth.signOut()
  │           ├── SharedPreferences: onboarding_completed = false
  │           └── Get.offAllNamed('/onboarding')
```

---

## 13. BILLS — `views/bills/bills_screen.dart`

```
BillsScreen (from Profile → Bills)
  │
  ├── Uses: Get.find<BillController>()
  │        Get.find<WalletController>()
  │
  ├── TabBar: "Upcoming / Due" | "Paid History"
  │
  ├── Each bill shows: logo, name, due status, amount, Pay button
  │     Status logic:
  │       difference < 0  → "Overdue by X days" (red)
  │       difference == 0 → "Due Today" (amber)
  │       difference == 1 → "Due Tomorrow" (amber)
  │       difference > 1  → "Due in X days" (blue)
  │       isPaid == true  → "Paid" (green)
  │
  ├── Tap bill → BillDetailsScreen
  ├── Tap "Pay" → BillPaymentScreen
  │
  └── "+" button → _showAddBillDialog()
        └── fills form → BillController.addBill()
              └── saves to SharedPreferences
```

---

## 14. BILL DETAILS & PAYMENT

```
BillDetailsScreen(bill)
  ├── Invoice-style layout
  ├── Auto-pay toggle → BillController.toggleAutoPay()
  └── "Pay Now" → BillPaymentScreen

BillPaymentScreen(bill)
  ├── 3-step wizard: Review → Confirm → Success
  ├── BillController.payBill(id, walletId, createTransaction: true)
  │     ├── marks bill as paid
  │     ├── creates TransactionModel via TransactionController
  │     └── wallet balance updated via chain
  └── Shows receipt on success
```

---

## 15. QR SCANNER — `views/wallet/qr_scanner_screen.dart`

```
QrScannerScreen (from Wallet → Pay)
  ├── Opens camera via mobile_scanner
  └── Returns scanned QR code string back to WalletTab
```

---

## DATA STORAGE SUMMARY

Every controller saves/loads from `SharedPreferences`:

| Controller | Storage Key | What It Saves |
|-----------|-------------|---------------|
| TransactionController | `'transactions'` | JSON array of all TransactionModel |
| WalletController | `'wallets'` | JSON array of all WalletModel |
| BillController | `'bills'` | JSON array of all BillModel |
| ProfileController | `'profile_name'`, `'profile_email'`, `'profile_phone'`, `'is_dark_theme'`, etc. | Individual string/bool values |
| OnboardingController | `'onboarding_completed'` | true/false |
| AuthController | (via Firebase) | Login state persisted by Firebase |

---

## THE COMPLETE CYCLE (Example: User adds an expense)

```
1. User sees HomeTab → taps "+" FAB
2. Get.to(AddTransactionScreen) navigates to form
3. User fills: Netflix, $9.99, today, Subscriptions, Wallet1, "Monthly"
4. User taps "Save Expense"
5. _submitData() runs:
   a. Creates TransactionModel{id, title:'Netflix', amount:9.99, type:'expense', ...}
6. txController.addTransaction(tx)
   a. transactions.insert(0, tx)          ← list updates
   b. jsonEncode → SharedPreferences     ← saved to phone
   c. Get.find<WalletController>().updateWalletBalance(walletId, 9.99, 'expense')
      i.  wallet.balance -= 9.99
      ii. saveWallets()                  ← wallet saved
7. Get.back() returns to HomeTab
8. Obx() reactive listeners fire:
   a. Balance card re-renders with new total
   b. Transaction list re-renders with new item at top
```

**Total files involved:** `AddTransactionScreen → TransactionController → WalletController → SharedPreferences → HomeTab auto-updates`
