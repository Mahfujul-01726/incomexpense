# COMPLETE CODE WORKING FLOWCHART
## For Absolute Beginners

This document explains **every single file** in the project, what it does, and how they all connect together like puzzle pieces.

---

# PART 1: UNDERSTANDING THE STRUCTURE

## What is each folder?

```
incomexpense/                    ← THE PROJECT (the whole app)
│
├── lib/                         ← ALL THE CODE LIVES HERE
│   │
│   ├── main.dart                ← ENTRY POINT (app starts here)
│   │
│   ├── theme/                   ← COLORS & STYLES
│   │   └── app_theme.dart       ← defines teal color, fonts, light/dark mode
│   │
│   ├── services/                ← EXTERNAL HELPERS
│   │   └── auth_service.dart    ← talks to Firebase & Google for login
│   │
│   ├── models/                  ← DATA SHAPES (blueprints for data)
│   │   ├── transaction_model.dart   ← what a transaction looks like
│   │   ├── wallet_model.dart        ← what a wallet looks like
│   │   └── bill_model.dart          ← what a bill looks like
│   │
│   ├── controllers/             ← BRAINS (logic & data management)
│   │   ├── auth_controller.dart         ← login/logout logic
│   │   ├── transaction_controller.dart  ← add/delete transactions
│   │   ├── wallet_controller.dart       ← add wallets, update balance
│   │   ├── bill_controller.dart         ← manage bills, pay bills
│   │   ├── profile_controller.dart      ← user name, theme, settings
│   │   └── onboarding_controller.dart   ← tracks onboarding slides
│   │
│   └── views/                   ← SCREENS (what user sees & taps)
│       ├── splash_screen.dart              ← first screen (logo animation)
│       ├── dashboard_screen.dart           ← main screen with 4 tabs
│       ├── onboarding/                     ← intro screens
│       │   └── onboarding_screen.dart
│       ├── auth/                           ← login screen
│       │   └── signin_screen.dart
│       ├── home/                           ← home tab
│       │   ├── home_tab.dart               ← balance + transactions
│       │   └── transaction_details_screen.dart  ← receipt view
│       ├── statistics/                     ← charts tab
│       │   └── statistics_tab.dart
│       ├── wallet/                         ← wallet tab
│       │   ├── wallet_tab.dart             ← cards & bills
│       │   ├── connect_wallet_screen.dart  ← add card/bank form
│       │   └── qr_scanner_screen.dart      ← scan QR
│       ├── profile/                        ← profile tab
│       │   └── profile_tab.dart
│       ├── bills/                          ← bills screens
│       │   ├── bills_screen.dart           ← list of bills
│       │   ├── bill_details_screen.dart    ← bill receipt
│       │   └── bill_payment_screen.dart    ← 3-step payment wizard
│       ├── add_transaction/                ← add transaction form
│       │   └── add_transaction_screen.dart
│       └── widgets/                        ← reusable UI pieces
│           └── app_bottom_nav.dart         ← bottom navigation bar
```

---

## What does "import" mean?

When a file says `import 'controllers/auth_controller.dart'`, it means:
> "Hey, I need to use the code from `auth_controller.dart` file"

Think of it like saying "I need the hammer from the toolbox" before you can use it.

---

## What is `Get.find<Something>()`?

This is how one file gets access to another file's data.

Example in `home_tab.dart`:
```dart
final txController = Get.find<TransactionController>();
```
This means:
> "Find the TransactionController that was created in main.dart, and give me access to it"

Once you have `txController`, you can use its data:
```dart
txController.transactions      // the list of all transactions
txController.totalIncome       // total income amount
txController.addTransaction()  // function to add a new transaction
```

---

## What is `Obx()`?

`Obx()` is a widget that **watches** a controller's data. Whenever the data changes, the widget **re-builds itself** automatically.

Example:
```dart
Obx(() => Text(txController.totalIncome.toString()))
```
If `totalIncome` changes, the text updates by itself. **No need to refresh the page.**

---

## What is `Rx`?

`Rx` means "reactive" — it's a special variable that tells `Obx()` to watch it.

```dart
var transactions = <TransactionModel>[].obs;   // .obs makes it reactive
var isLoading = false.obs;                     // any Obx watching this will update
```

When you change it:
```dart
transactions.value = newList;   // ← this triggers Obx to rebuild
isLoading.value = true;         // ← this also triggers Obx
```

---

# PART 2: THE COMPLETE APP FLOW

## PHASE 1: APP LAUNCH

### Step-by-step: What happens when user opens the app?

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. PHONE RUNS main() in main.dart                               │
│                                                                  │
│    main() async {                                               │
│      // Turn on Flutter engine                                  │
│      WidgetsFlutterBinding.ensureInitialized();                  │
│                                                                  │
│      // Start Firebase (needed for Google login)                 │
│      await Firebase.initializeApp();                             │
│                                                                  │
│      // Open phone's storage to check settings                  │
│      final prefs = await SharedPreferences.getInstance();        │
│      final onboardingCompleted =                                 │
│          prefs.getBool('onboarding_completed') ?? false;         │
│                                                                  │
│      // Create all 6 controllers (THE BRAINS)                   │
│      // Now they exist in memory and any file can access them    │
│      Get.put(AuthController());          ← login logic           │
│      Get.put(ProfileController());       ← user settings         │
│      Get.put(WalletController());        ← wallet management     │
│      Get.put(TransactionController());   ← transaction logic     │
│      Get.put(BillController());          ← bill logic            │
│      Get.put(OnboardingController());    ← intro slides          │
│      Get.put(NavigationController());    ← tab switching         │
│                                                                  │
│      // Start the app with the splash screen                     │
│      runApp(MyApp(onboardingCompleted: onboardingCompleted));    │
│    }                                                             │
│                                                                  │
│    MyApp builds:                                                 │
│      GetMaterialApp(                                             │
│        theme: AppTheme.lightTheme,       ← teal colors           │
│        darkTheme: AppTheme.darkTheme,    ← dark colors           │
│        initialRoute: '/splash',          ← start here            │
│        getPages: [                                               │
│          '/splash'      → SplashScreen(),                        │
│          '/onboarding'  → OnboardingScreen(),                    │
│          '/signin'      → SignInScreen(),                        │
│          '/dashboard'   → DashboardScreen(),                     │
│        ],                                                        │
│      )                                                           │
└─────────────────────────────────────────────────────────────────┘
```

## PHASE 2: SPLASH SCREEN

### File: `views/splash_screen.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees: App logo fading in for 2.5 seconds              │
│                                                                  │
│ Code that runs:                                                  │
│                                                                  │
│ class _SplashScreenState {                                      │
│   @override                                                     │
│   void initState() {                                            │
│     // Start fade-in animation (1200ms)                          │
│     _animationController.forward();                              │
│     // Wait 2.5 seconds, then decide where to go                 │
│     _navigateToNext();                                           │
│   }                                                              │
│                                                                  │
│   Future<void> _navigateToNext() async {                        │
│     await Future.delayed(Duration(milliseconds: 2500));          │
│                                                                  │
│     // DECISION 1: Is user logged in with Google?                │
│     final firebaseUser = FirebaseAuth.instance.currentUser;      │
│     if (firebaseUser != null) {                                 │
│       // YES → go straight to dashboard                          │
│       Get.offAllNamed('/dashboard');                             │
│       return;                                                    │
│     }                                                            │
│                                                                  │
│     // DECISION 2: Has user completed onboarding before?         │
│     final prefs = await SharedPreferences.getInstance();         │
│     final onboardingCompleted =                                  │
│         prefs.getBool('onboarding_completed') ?? false;          │
│                                                                  │
│     if (onboardingCompleted) {                                   │
│       // YES → go to dashboard (guest mode)                      │
│       Get.offAllNamed('/dashboard');                             │
│     } else {                                                     │
│       // NO → show onboarding slides                             │
│       Get.offAllNamed('/onboarding');                            │
│     }                                                            │
│   }                                                              │
│ }                                                                │
│                                                                  │
│ FLOWCHART:                                                       │
│                                                                  │
│  START                                                           │
│    │                                                             │
│    ▼                                                             │
│  Show splash animation for 2.5 seconds                           │
│    │                                                             │
│    ▼                                                             │
│  Is Firebase user logged in?                                     │
│  ├── YES ──────────────────► Go to Dashboard                    │
│  └── NO                                                          │
│        │                                                         │
│        ▼                                                         │
│  Has onboarding_completed = true?                                │
│  ├── YES ──────────────────► Go to Dashboard (guest)            │
│  └── NO ───────────────────► Go to Onboarding                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 3: ONBOARDING SCREEN

### File: `views/onboarding/onboarding_screen.dart`
### Controller: `controllers/onboarding_controller.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - Illustration image at top                                   │
│   - "Spend Smarter Save More" text                             │
│   - "Get Started" teal gradient button                          │
│   - "Already Have Account? Log In" link                         │
│                                                                  │
│ Controller's data:                                               │
│   OnboardingController {                                         │
│     currentPage = 0  (which slide, 0-indexed)                   │
│     pageController = PageController()                            │
│                                                                  │
│     onboardingData = [                                           │
│       {title, description, image} for slide 1,                   │
│       {title, description, image} for slide 2,                   │
│       {title, description, image} for slide 3,                   │
│     ]                                                            │
│                                                                  │
│     // Goes to next slide or finishes if on last                 │
│     nextPage() {                                                 │
│       if currentPage < 2 → pageController.nextPage()             │
│       else → completeOnboarding()                                │
│     }                                                            │
│                                                                  │
│     // Called by "Get Started" button                            │
│     completeOnboarding() {                                       │
│       Get.toNamed('/signin');  ← go to Sign In screen            │
│     }                                                            │
│                                                                  │
│     // Called after successful login                             │
│     finishOnboarding() async {                                   │
│       prefs.setBool('onboarding_completed', true);               │
│       Get.offAllNamed('/dashboard');                             │
│     }                                                            │
│   }                                                              │
│                                                                  │
│ USER TAPS:                                                       │
│                                                                  │
│  "Get Started" button → completeOnboarding() → /signin          │
│  "Log In" link       → Get.toNamed('/signin')                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 4: SIGN IN SCREEN

### File: `views/auth/signin_screen.dart`
### Controller: `controllers/auth_controller.dart` & `controllers/onboarding_controller.dart`
### Service: `services/auth_service.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - Back button (top-left)                                      │
│   - App icon (wallet icon)                                      │
│   - "Welcome!" text                                             │
│   - 3 feature rows (Smart Analytics, Multi-Wallet, Cloud Sync)  │
│   - "Continue with Google" button (white with Google logo)      │
│   - "or" divider                                               │
│   - "Continue as Guest" button (outlined teal)                  │
│   - Terms of Service text                                       │
│                                                                  │
│ ─── GOOGLE SIGN-IN PATH ───                                    │
│                                                                  │
│ User taps "Continue with Google" →                              │
│   authController.signInWithGoogle()                              │
│                                                                  │
│   INSIDE AuthController:                                         │
│   ┌───────────────────────────────────────────────────────┐     │
│   │ signInWithGoogle() async {                            │     │
│   │   isLoading.value = true;   // show loading spinner   │     │
│   │                                                        │     │
│   │   // STEP 1: Call the service that talks to Google     │     │
│   │   final signedInUser = await _authService              │     │
│   │       .signInWithGoogle();                             │     │
│   │                                                        │     │
│   │   // STEP 2: If login succeeded, go to dashboard       │     │
│   │   if (signedInUser != null) {                         │     │
│   │     Get.find<OnboardingController>().finishOnboarding();│     │
│   │   }                                                    │     │
│   │                                                        │     │
│   │   isLoading.value = false;                             │     │
│   │ }                                                      │     │
│   └───────────────────────────────────────────────────────┘     │
│                                                                  │
│   INSIDE AuthService (services/auth_service.dart):               │
│   ┌───────────────────────────────────────────────────────┐     │
│   │ signInWithGoogle() async {                             │     │
│   │   // Open Google's login popup on phone                │     │
│   │   final googleUser = await GoogleSignIn().signIn();    │     │
│   │   if (googleUser == null) return null; // user cancelled│     │
│   │                                                        │     │
│   │   // Get tokens from Google                            │     │
│   │   final googleAuth = await googleUser.authentication;  │     │
│   │                                                        │     │
│   │   // Create Firebase login credentials                 │     │
│   │   final credential = GoogleAuthProvider.credential(    │     │
│   │     accessToken: googleAuth.accessToken,               │     │
│   │     idToken: googleAuth.idToken,                       │     │
│   │   );                                                    │     │
│   │                                                        │     │
│   │   // Log into Firebase with those credentials          │     │
│   │   final userCredential = await FirebaseAuth            │     │
│   │       .signInWithCredential(credential);               │     │
│   │                                                        │     │
│   │   return userCredential.user;  // the logged-in user   │     │
│   │ }                                                      │     │
│   └───────────────────────────────────────────────────────┘     │
│                                                                  │
│   After login: OnboardingController.finishOnboarding()         │
│     → saves "onboarding_completed = true" to phone storage      │
│     → Get.offAllNamed('/dashboard')  ← goes to main app        │
│                                                                  │
│ ─── GUEST MODE PATH ───                                        │
│                                                                  │
│ User taps "Continue as Guest" →                                 │
│   onboardingController.finishOnboarding()                        │
│     → saves "onboarding_completed = true"                        │
│     → Get.offAllNamed('/dashboard')                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 5: DASHBOARD (Main App Screen)

### File: `views/dashboard_screen.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - One of 4 tabs shown in the middle                           │
│   - "+" floating button at bottom-center                        │
│   - Bottom navigation bar with 4 icons                          │
│     [Home] [Statistics] [Wallet] [Profile]                      │
│                                                                  │
│ Code:                                                            │
│                                                                  │
│ class DashboardScreen {                                          │
│   // Get/create the NavigationController that tracks tabs        │
│   final navController = Get.find<NavigationController>();        │
│                                                                  │
│   // The 4 tab screens                                            │
│   final _tabs = [HomeTab(), StatisticsTab(),                    │
│                  WalletTab(), ProfileTab()];                     │
│                                                                  │
│   build() {                                                      │
│     Obx(() {            // ← watches selectedIndex              │
│       final selected = navController.selectedIndex.value;        │
│                                                                  │
│       Scaffold(                                                  │
│         body: IndexedStack(      // shows only the selected tab  │
│           index: selected,                                       │
│           children: _tabs,                                       │
│         ),                                                       │
│                                                                  │
│         floatingActionButton: "+" button →                       │
│           Get.to(() => AddTransactionScreen()),                  │
│                                                                  │
│         bottomNavigationBar: AppBottomNav()  ← the 4 icons      │
│       )                                                          │
│     })                                                           │
│   }                                                              │
│ }                                                                │
│                                                                  │
│ NavigationController (defined in home_tab.dart):                 │
│   selectedIndex = 0.obs   // 0=Home, 1=Stats, 2=Wallet, 3=Profile
│   changeTab(index) → selectedIndex.value = index                 │
│                                                                  │
│ HOW TABS WORK:                                                   │
│   User taps "Statistics" icon →                                  │
│     AppBottomNav calls navController.changeTab(1) →              │
│     selectedIndex becomes 1 →                                    │
│     IndexedStack shows StatisticsTab (child at index 1)          │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 3: THE 4 TABS EXPLAINED

## TAB 0: HOME TAB

### File: `views/home/home_tab.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  Teal curved header                                   │        │
│  │  Good afternoon,                                      │        │
│  │  Enjelin Morgeana                          🔔        │        │
│  │                                                       │        │
│  │  ┌─────────────────────────────────────────────┐     │        │
│  │  │ Total Balance                         ...   │     │        │
│  │  │ $ 2,548.00                                  │     │        │
│  │  │                                             │     │        │
│  │  │ ↓ Income    $1,840.00    ↑ Expenses $284.00 │     │        │
│  │  └─────────────────────────────────────────────┘     │        │
│  │                                                       │        │
│  │  Transactions History              See all            │        │
│  │  ┌─────────────────────────────────────────────┐     │        │
│  │  │ [Upwork icon] Upwork           + $850.00    │     │        │
│  │  │              Today                          │     │        │
│  │  ├─────────────────────────────────────────────┤     │        │
│  │  │ [Transfer]   Transfer          - $85.00     │     │        │
│  │  │              Yesterday                      │     │        │
│  │  ├─────────────────────────────────────────────┤     │        │
│  │  │ [PayPal]     PayPal            + $1,406.00  │     │        │
│  │  │              Jan 30, 2022                    │     │        │
│  │  ├─────────────────────────────────────────────┤     │        │
│  │  │ [YouTube]    Youtube            - $11.99    │     │        │
│  │  │              Jan 16, 2022                    │     │        │
│  │  └─────────────────────────────────────────────┘     │        │
│  │                                                       │        │
│  │  Send Again                      See all              │        │
│  │  [avatar1] [avatar2] [avatar3] [avatar4] [avatar5]   │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│ CODE STRUCTURE:                                                   │
│                                                                  │
│ class HomeTab {                                                   │
│   // Get access to 3 controllers                                  │
│   final txController = Get.find<TransactionController>();         │
│   final walletController = Get.find<WalletController>();          │
│   final profileController = Get.find<ProfileController>();        │
│                                                                  │
│   // The whole screen is wrapped in Obx() so it auto-updates     │
│   // whenever any controller's data changes                      │
│                                                                  │
│   _buildHeader() → shows "Good afternoon, [name]"                │
│                                                                  │
│   _buildBalanceCard() →                                           │
│     Obx(() {                                                      │
│       total = walletController.totalBalance  // sum of wallets    │
│       income = txController.totalIncome       // sum of incomes   │
│       expense = txController.totalExpenses    // sum of expenses  │
│       // Display as $2,548.00, etc.                              │
│     })                                                            │
│                                                                  │
│   _buildTransactionItem(tx) →                                     │
│     shows logo (from assets/cropped/), title, date, amount       │
│     onTap → Get.to(TransactionDetailsScreen(transaction: tx))   │
│                                                                  │
│   _buildSendAgainSection() →                                     │
│     shows 5 avatar images, "See all" opens bottom sheet          │
│ }                                                                 │
│                                                                  │
│ ALSO IN THIS FILE: NavigationController                          │
│   class NavigationController extends GetxController {             │
│     var selectedIndex = 0.obs;                                    │
│     void changeTab(int index) => selectedIndex.value = index;    │
│   }                                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## TAB 1: STATISTICS TAB

### File: `views/statistics/statistics_tab.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│                                                                  │
│  Statistics                                      [download icon]│
│  ← (back to home)                                                │
│                                                                  │
│  [Day]  [Week]  [Month]  [Year]    ← period filter buttons      │
│                                     [Expense ▼]  ← type dropdown│
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  Line Chart (fl_chart)                               │        │
│  │      ╱╲                                              │        │
│  │   ╱╱  ╲╲    ╱╲                                      │        │
│  │  ╱      ╲╲╱  ╲╲                                    │        │
│  │ ╱              ╲╲                                   │        │
│  │ M    T    W    T    F    S    S                     │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  Top Spending                                    ↕              │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ [YouTube]  Youtube                - $11.99           │        │
│  │            Jan 16, 2022                               │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ [Starbucks] Starbucks            - $150.00           │        │
│  │            Jan 12, 2022                               │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│ CODE STRUCTURE:                                                   │
│                                                                  │
│ class StatisticsTab {                                             │
│   final txController = Get.find<TransactionController>();         │
│                                                                  │
│   _buildPeriodFilter() →                                          │
│     Shows [Day] [Week] [Month] [Year]                            │
│     When tapped: txController.selectedPeriod.value = 'Week'     │
│     → triggers Obx rebuild of chart                              │
│                                                                  │
│   _buildDropdownSelector() →                                      │
│     Shows [Expense ▼] or [Income ▼]                              │
│     When changed: txController.selectedType.value = 'expense'   │
│     → triggers Obx rebuild of chart                              │
│                                                                  │
│   _buildChartArea() →                                             │
│     Obx(() {                                                      │
│       // Chart data changes based on period + type                │
│       // Uses fl_chart's LineChart widget                         │
│       // Touch: highlights dot and shows $ amount tooltip        │
│     })                                                            │
│                                                                  │
│   _buildTopSpendingList() →                                       │
│     Obx(() {                                                      │
│       // Takes all expenses, sorts by amount desc                 │
│       // Shows top 3                                              │
│       // Tap → TransactionDetailsScreen                          │
│     })                                                            │
│ }                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## TAB 2: WALLET TAB

### File: `views/wallet/wallet_tab.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│                                                                  │
│  Teal header with ← Wallet                       🔔             │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ Total Balance                                       │        │
│  │ $ 2,548.00                                          │        │
│  │                                                     │        │
│  │    [Add]    [Pay]    [Send]                         │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  [ Transactions ] [ Upcoming Bills ]        ← tab selector      │
│                                                                  │
│  If Transactions tab:                                            │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ [Upwork]  Upwork                    + $850.00        │        │
│  │           Today                                        │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ [Transfer] Transfer                  - $85.00        │        │
│  │           Yesterday                                   │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  If Upcoming Bills tab:                                          │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ [YouTube] YouTube Premium           $11.99 [Pay]    │        │
│  │           Feb 28, 2022                                │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ [House]   House Rent               $1,200.00 [Pay]  │        │
│  │           Mar 31, 2022                                │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│ CODE STRUCTURE:                                                   │
│                                                                  │
│ class WalletTab {                                                 │
│   final walletController = Get.find<WalletController>();          │
│   final txController = Get.find<TransactionController>();         │
│   final billController = Get.find<BillController>();              │
│                                                                  │
│   _selectedTab = 0  // 0 = Transactions, 1 = Upcoming Bills     │
│                                                                  │
│   "Add" button → Navigator.push(ConnectWalletScreen())          │
│   "Pay" button → Navigator.push(QrScannerScreen())              │
│   "Send" button → _showSendSimulator() (bottom sheet)           │
│                                                                  │
│   _buildTransactionsList() →                                      │
│     Obx(() {                                                      │
│       txController.transactions sorted by date                   │
│       each tap → TransactionDetailsScreen                        │
│     })                                                            │
│                                                                  │
│   _buildUpcomingBillsList() →                                     │
│     Obx(() {                                                      │
│       billController.bills where not paid                        │
│       each "Pay" button → BillPaymentScreen                      │
│     })                                                            │
│ }                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## TAB 3: PROFILE TAB

### File: `views/profile/profile_tab.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│                                                                  │
│  Teal wavy header                                                │
│  ← Profile                                        🔔           │
│                                                                  │
│              [Avatar image]                                      │
│              Enjelin Morgeana                                    │
│              @enjelin_morgeana                                   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ 💎 Invite Friends                                    │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 👤 Account info                                      │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 👥 Personal profile                                  │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ ✉️ Message center                                    │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 🛡️ Login and security                                │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 🔒 Data and privacy                                  │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 🚪 Sign Out (red)                                    │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│ WHAT EACH MENU ITEM DOES:                                        │
│                                                                  │
│  "Account info" →                                                │
│    Opens dialog to edit name, email, phone                       │
│    Save → profileController.updateProfile(name, email, phone)   │
│      → saves to SharedPreferences                               │
│                                                                  │
│  "Personal profile" →                                            │
│    Bottom sheet with toggles:                                    │
│      Dark Theme → profileController.toggleTheme()                │
│        ├── flips isDarkTheme.value                               │
│        ├── Get.changeThemeMode(dark/light)                       │
│        └── saves 'is_dark_theme' to SharedPreferences            │
│                                                                  │
│      Receive Notifications → toggle                              │
│        → saves 'receive_notifications' to SharedPreferences      │
│                                                                  │
│  "Login and security" →                                          │
│    Bottom sheet: Fingerprint Lock toggle                         │
│      → saves 'biometrics_enabled' to SharedPreferences           │
│                                                                  │
│  "Data and privacy" →                                            │
│    Bottom sheet: Export Transactions (mock)                      │
│                                                                  │
│  "Sign Out" →                                                    │
│    Confirmation dialog →                                         │
│      AuthController.signOut()                                    │
│        ├── AuthService.signOut()                                 │
│        │     ├── GoogleSignIn.signOut()                          │
│        │     └── FirebaseAuth.signOut()                         │
│        ├── SharedPreferences: onboarding_completed = false       │
│        └── Get.offAllNamed('/onboarding')                        │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 4: THE ADD TRANSACTION FLOW (Most Important)

### File: `views/add_transaction/add_transaction_screen.dart`

This is the most complex screen. Here's exactly what happens:

```
┌─────────────────────────────────────────────────────────────────┐
│ Screen opens when user taps "+" FAB on Dashboard                │
│                                                                  │
│ ─── WHAT USER SEES & DOES ───                                   │
│                                                                  │
│  ← Add Expense (or Add Income)                         ⋮       │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │                                                     │        │
│  │  NAME                                               │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ [Netflix logo] Netflix                  ▼   │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  AMOUNT                                             │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ $ 0.00                              [Clear] │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  DATE                                               │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ Sun, 24 May 2026                    📅      │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  CATEGORY                                           │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ Subscriptions                           ▼   │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  WALLET / SOURCE              [Link Card/Bank]     │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ Mono Debit Card (...8075)              ▼   │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  NOTE (OPTIONAL)                                    │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │ Add description...                         │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  │                                                     │        │
│  │  INVOICE                                            │        │
│  │  ┌ - - - - - - - - - - - - - - - - - - - - - - ┐  │        │
│  │  │         ＋ Add Invoice                       │  │        │
│  │  └ - - - - - - - - - - - - - - - - - - - - - - ┘  │        │
│  │                                                     │        │
│  │  ┌─────────────────────────────────────────────┐   │        │
│  │  │           Save Expense                      │   │        │
│  │  └─────────────────────────────────────────────┘   │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│                                                                  │
│ ─── WHAT HAPPENS WHEN USER TAPS EACH FIELD ───                  │
│                                                                  │
│  NAME field tap →                                                │
│    _showMerchantPicker()                                         │
│    → bottom sheet with: Netflix, YouTube, Starbucks,             │
│                         PayPal, Upwork, Other                    │
│    → selecting one: sets _selectedMerchant, _payeeController,    │
│                     _titleController, _selectedCategory          │
│    → If "Other" selected: shows text fields for custom name      │
│                                                                  │
│  DATE field tap →                                                │
│    showDatePicker() → sets _selectedDate                         │
│                                                                  │
│  CATEGORY field tap →                                            │
│    _showCategoryPicker()                                         │
│    → bottom sheet with categories (differs for income/expense)   │
│    Expense: Food, Groceries, Shopping, Entertainment, etc.      │
│    Income: Salary, Freelance, Consulting, Investments, etc.     │
│    → sets _selectedCategory                                      │
│                                                                  │
│  WALLET field tap →                                              │
│    _showWalletPicker()                                           │
│    → bottom sheet with existing wallets + "Link Card/Bank"       │
│    → sets _selectedWalletId                                      │
│    → "Link Card/Bank" → ConnectWalletScreen                     │
│                                                                  │
│  INVOICE field tap →                                             │
│    _showInvoiceSelector()                                        │
│    → bottom sheet: Simulate Camera / PDF / Gallery (all mock)   │
│                                                                  │
│  Top-right ⋮ button →                                            │
│    _showTypeChangeMenu()                                         │
│    → bottom sheet: "Expense" or "Income"                        │
│    → changes _selectedType, updates colors, resets merchant      │
│                                                                  │
│                                                                  │
│ ─── WHAT HAPPENS WHEN USER TAPS "SAVE EXPENSE" ───             │
│                                                                  │
│  _submitData() {                                                │
│                                                                  │
│    STEP 1: Validate form fields                                  │
│    if (!_formKey.currentState!.validate()) return;               │
│                                                                  │
│    STEP 2: Check amount > 0                                     │
│    final enteredAmount = double.tryParse(_amountController.text);│
│    if (enteredAmount <= 0) → show error, return                 │
│                                                                  │
│    STEP 3: Check wallet is selected                              │
│    if (_selectedWalletId.isEmpty) → show error, return          │
│                                                                  │
│    STEP 4: CREATE A TransactionModel OBJECT                     │
│    final newTx = TransactionModel(                              │
│      id: Uuid().v4(),         ← generates unique ID like        │
│                                 "a1b2c3d4-e5f6-..."             │
│      title: "Netflix",                                           │
│      amount: 9.99,                                               │
│      type: 'expense',                                            │
│      category: 'Subscriptions',                                  │
│      date: DateTime.now(),                                       │
│      walletId: 'wallet_1',                                       │
│      payee: 'Netflix',                                           │
│      note: 'Monthly subscription',                               │
│      status: 'completed',                                        │
│    );                                                             │
│                                                                  │
│    STEP 5: PASS IT TO THE CONTROLLER                             │
│    txController.addTransaction(newTx);                           │
│                                                                  │
│    STEP 6: GO BACK TO HOME TAB                                  │
│    Get.back();                                                    │
│                                                                  │
│    STEP 7: SHOW SUCCESS MESSAGE                                  │
│    Get.snackbar('Transaction Added', 'Logged successfully.');    │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 5: HOW TRANSACTIONCONTROLLER WORKS INSIDE

### File: `controllers/transaction_controller.dart`

This is the most important controller. Let's trace through it completely.

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. CREATION (happens in main.dart)                              │
│                                                                  │
│    Get.put(TransactionController());                             │
│                                                                  │
│    When created, onInit() runs:                                  │
│      loadTransactions()                                          │
│                                                                  │
│ 2. loadTransactions() — reads from phone storage                │
│                                                                  │
│    loadTransactions() async {                                    │
│      isLoading = true                                           │
│                                                                  │
│      // Open phone storage                                       │
│      prefs = await SharedPreferences.getInstance()              │
│                                                                  │
│      // Try to read saved data                                   │
│      transString = prefs.getString('transactions')              │
│                                                                  │
│      if (transString != null) {                                  │
│        // Convert JSON string back to Transaction objects        │
│        jsonList = jsonDecode(transString)                       │
│        // Convert each JSON item → TransactionModel             │
│        transactions = jsonList.map((e) =>                        │
│          TransactionModel.fromJson(e)                            │
│        ).toList()                                                │
│      }                                                          │
│      else {                                                     │
│        // FIRST TIME: create 5 sample transactions              │
│        transactions = [                                          │
│          TransactionModel(id:'t_1', title:'Upwork',             │
│            amount:850, type:'income', ...),                      │
│          TransactionModel(id:'t_2', title:'Transfer',           │
│            amount:85, type:'expense', ...),                      │
│          TransactionModel(id:'t_3', title:'Paypal',             │
│            amount:1406, type:'income', ...),                     │
│          TransactionModel(id:'t_4', title:'Youtube',            │
│            amount:11.99, type:'expense', ...),                   │
│          TransactionModel(id:'t_5', title:'Starbucks',          │
│            amount:150, type:'expense', ...),                     │
│        ]                                                         │
│        saveTransactions()  ← save these to phone                │
│      }                                                          │
│                                                                  │
│      isLoading = false                                          │
│    }                                                             │
│                                                                  │
│ 3. addTransaction(newTx) — adds new transaction                 │
│                                                                  │
│    addTransaction(TransactionModel transaction) {                │
│      // Add to the FRONT of the list                             │
│      transactions.insert(0, transaction);                        │
│                                                                  │
│      // Save to phone storage                                    │
│      saveTransactions();                                         │
│                                                                  │
│      // Also update the wallet's balance                         │
│      WalletController wc = Get.find<WalletController>();        │
│      wc.updateWalletBalance(                                     │
│        transaction.walletId,     ← which wallet                  │
│        transaction.amount,       ← how much                      │
│        transaction.type          ← 'income' adds, 'expense' subtracts
│      );                                                          │
│    }                                                             │
│                                                                  │
│ 4. saveTransactions() — writes to phone storage                 │
│                                                                  │
│    saveTransactions() async {                                    │
│      prefs = await SharedPreferences.getInstance()              │
│                                                                  │
│      // Convert all Transaction objects → JSON string           │
│      jsonString = jsonEncode(                                    │
│        transactions.map((e) => e.toJson()).toList()             │
│      )                                                           │
│                                                                  │
│      // Save to phone under key 'transactions'                  │
│      prefs.setString('transactions', jsonString)                │
│    }                                                             │
│                                                                  │
│ 5. deleteTransaction(id) — removes a transaction                │
│                                                                  │
│    deleteTransaction(String transactionId) {                     │
│      // Find the transaction in the list                         │
│      index = transactions.indexWhere((t) => t.id == id)         │
│                                                                  │
│      if (index != -1) {                                          │
│        transaction = transactions[index]                        │
│        transactions.removeAt(index);                             │
│        saveTransactions();                                       │
│                                                                  │
│        // Reverse the wallet balance update                      │
│        WalletController wc = Get.find<WalletController>();      │
│        reverseType = transaction.type == 'income'                │
│                      ? 'expense' : 'income';                     │
│        wc.updateWalletBalance(                                   │
│          transaction.walletId,                                   │
│          transaction.amount,                                     │
│          reverseType                                             │
│        );                                                        │
│      }                                                           │
│    }                                                             │
│                                                                  │
│ 6. Computed properties                                           │
│                                                                  │
│    double get totalIncome {                                      │
│      // Go through all transactions, sum up ones with type == 'income'
│      return transactions                                         │
│          .where((t) => t.type == 'income')                       │
│          .fold(0.0, (sum, t) => sum + t.amount);                 │
│    }                                                             │
│                                                                  │
│    double get totalExpenses {                                    │
│      // Same but for 'expense' type                              │
│      return transactions                                         │
│          .where((t) => t.type == 'expense')                      │
│          .fold(0.0, (sum, t) => sum + t.amount);                 │
│    }                                                             │
│                                                                  │
│    List<TransactionModel> get filteredTransactions {             │
│      // Return only transactions that match selected period      │
│      // and selected type (income/expense)                       │
│      // Used by Statistics tab for charts                        │
│      now = DateTime.now()                                        │
│      if (selectedPeriod == 'Day')   threshold = now - 1 day     │
│      if (selectedPeriod == 'Week')  threshold = now - 7 days    │
│      if (selectedPeriod == 'Month') threshold = now - 30 days   │
│      if (selectedPeriod == 'Year')  threshold = now - 365 days  │
│                                                                  │
│      return transactions.where(                                  │
│        type == selectedType AND date > threshold                 │
│      ).toList()                                                  │
│    }                                                             │
│                                                                  │
│    Map<String, double> get categoryBreakdown {                   │
│      // Group filtered transactions by category                  │
│      // e.g., {'Subscriptions': 11.99, 'Food': 150.00}          │
│      // Used on Statistics tab for pie/bar chart                 │
│    }                                                             │
│ }                                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 6: MODEL FILES — WHAT DATA LOOKS LIKE

## TransactionModel (`models/transaction_model.dart`)

```dart
class TransactionModel {
  final String id;        // unique ID like "a1b2c3d4"
  final String title;     // "Netflix", "Upwork", etc.
  final double amount;    // 9.99, 850.00
  final String type;      // 'income' or 'expense'
  final String category;  // 'Subscriptions', 'Freelance'
  final DateTime date;    // when it happened
  final String walletId;  // which wallet it belongs to
  final String payee;     // who it was paid to/from
  final String note;      // optional description
  final String status;    // 'completed', 'pending', 'failed'

  // Constructor: required to create a TransactionModel
  TransactionModel({required this.id, required this.title, ...});

  // CONVERT TO JSON (for saving to phone)
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'amount': amount,
    'type': type, 'category': category,
    'date': date.toIso8601String(),  // converts DateTime to string
    'walletId': walletId, 'payee': payee,
    'note': note, 'status': status,
  };

  // CONVERT FROM JSON (for reading from phone)
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'], title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'], category: json['category'],
      date: DateTime.parse(json['date']),  // converts string back to DateTime
      walletId: json['walletId'], payee: json['payee'],
      note: json['note'], status: json['status'] ?? 'completed',
    );
}
```

### How JSON conversion works:
```
Saving:   TransactionModel → toJson() → Map → jsonEncode → String → SharedPreferences
Loading:  SharedPreferences → String → jsonDecode → Map → fromJson() → TransactionModel
```

Example of what's actually stored on phone:
```json
[
  {
    "id": "t_1",
    "title": "Upwork",
    "amount": 850.0,
    "type": "income",
    "category": "Freelance",
    "date": "2026-05-24T10:30:00.000",
    "walletId": "wallet_1",
    "payee": "Upwork Global Inc.",
    "note": "Freelance mobile app development milestone",
    "status": "completed"
  }
]
```

## WalletModel (`models/wallet_model.dart`)

```dart
class WalletModel {
  final String id;          // unique ID
  final String name;        // "Mono Debit Card"
  final double balance;     // 5750.25
  final String cardHolder;  // "IRVAN MOSES"
  final String cardNumber;  // "**** **** **** 8075" (masked)
  final String expiryDate;  // "12/28"
  final String type;        // 'card', 'bank', 'cash'
  final int colorIndex;     // which gradient color to use (0-4)
  final String? bankLogo;   // "Visa", "PayPal"

  // toJson() and fromJson() same pattern as TransactionModel
}
```

## BillModel (`models/bill_model.dart`)

```dart
class BillModel {
  final String id;        // "bill_1"
  final String name;      // "YouTube Premium"
  final double amount;    // 11.99
  final DateTime dueDate;  // when it's due
  final bool isPaid;      // true/false
  final String category;  // "Entertainment"
  final bool autoPay;     // auto-pay enabled?
  final String provider;  // "YouTube LLC"

  // Also has copyWith() method — creates a copy with some fields changed
  // Used when toggling autoPay or marking as paid
  BillModel copyWith({id, name, amount, dueDate, isPaid, ...}) {
    return BillModel(
      id: id ?? this.id,        // keep existing if not provided
      name: name ?? this.name,
      ...
    );
  }
}
```

---

# PART 7: HOW THE THEME SYSTEM WORKS

### File: `theme/app_theme.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ AppTheme is a class with STATIC properties (no need to create) │
│ Any file can use: AppTheme.primaryColor                         │
│                                                                  │
│ COLORS:                                                          │
│   primaryColor    = #429690 (Teal)                              │
│   secondaryColor  = #2F7E79 (Dark Teal)                         │
│   incomeColor     = #25A969 (Green)                             │
│   expenseColor    = #F95B5A (Red)                               │
│   warningColor    = #F59E0B (Amber)                             │
│                                                                  │
│ LIGHT THEME:                                                     │
│   background: #F8FAFC (light gray)                              │
│   surface: White                                                │
│   text: #0F172A (dark blue-gray)                                │
│   secondary text: #64748B                                       │
│                                                                  │
│ DARK THEME:                                                      │
│   background: #0B0F19 (near black)                              │
│   surface: #1E293B (dark gray-blue)                             │
│   text: #F8FAFC (white)                                         │
│   secondary text: #94A3B8 (light gray)                          │
│                                                                  │
│ FONTS: Google Outfit font across all text                       │
│                                                                  │
│ HOW THEME TOGGLE WORKS:                                          │
│   ProfileController.toggleTheme()                               │
│     ├── isDarkTheme.value = !isDarkTheme.value                   │
│     ├── Get.changeThemeMode(ThemeMode.dark or ThemeMode.light)  │
│     └── saves 'is_dark_theme' to SharedPreferences              │
│                                                                  │
│   When app restarts:                                             │
│     ProfileController.loadProfileSettings()                     │
│     ├── reads 'is_dark_theme' from SharedPreferences            │
│     └── Get.changeThemeMode() accordingly                       │
│                                                                  │
│ CARD GRADIENTS (for wallet cards):                               │
│   cardGradients = [                                              │
│     [Blue Indigo], [Pink Crimson], [Emerald Green],             │
│     [Amber Orange], [Purple Violet]                             │
│   ]                                                              │
│   Each wallet gets one based on colorIndex                      │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 8: HOW EVERYTHING CONNECTS

## Complete Data Flow Diagram

```
USER TAPS ON SCREEN
        │
        ▼
┌──────────────────┐
│   VIEW FILE      │  (e.g., home_tab.dart)
│   (What user     │
│    sees & taps)  │
│                  │
│  Get.find<Ctrl>()│──→ gets reference to controller
│  calls function  │──→ e.g., txController.addTransaction(tx)
│  reads data      │──→ e.g., txController.transactions
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ CONTROLLER FILE  │  (e.g., transaction_controller.dart)
│   (The brain)    │
│                  │
│  Holds data:     │
│  transactions[]  │──→ .obs = reactive, Obx watches it
│                  │
│  Functions:      │
│  addTransaction  │──→ changes data, saves to storage
│  deleteTransact  │──→ changes data, saves to storage
│  loadTransact    │──→ reads from storage on startup
│  saveTransact    │──→ writes to storage
│                  │
│  Computed:       │
│  totalIncome     │──→ calculated from transactions[]
│  totalExpenses   │──→ calculated from transactions[]
│  filteredTx      │──→ calculated with filters
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌──────────────────┐
│ MODEL  │ │ SHAREDPREFERENCES│
│ File   │ │ (Phone Storage)  │
│        │ │                  │
│ toJson │ │ key:             │
│ fromJson││ 'transactions'   │
│        │ │ value: JSON      │
│ Blue-  │ │ string           │
│ print  │ │                  │
└────────┘ └──────────────────┘
         │
         ▼
    DATA CHANGED
         │
         ▼
┌──────────────────┐
// Obx() DETECTS   │
// CHANGE          │
// Auto-rebuilds   │
└──────────────────┘
         │
         ▼
┌──────────────────┐
│ SCREEN UPDATES   │
│ New balance      │
│ New transaction  │
│ New chart        │
└──────────────────┘
```

## Visual Map: Which Files Access Which Controllers

```
VIEW FILE                    CONTROLLERS IT USES
─────────────────────        ─────────────────────────────
splash_screen.dart           None (uses FirebaseAuth directly)

onboarding_screen.dart       OnboardingController

signin_screen.dart           AuthController, OnboardingController

dashboard_screen.dart        NavigationController (from home_tab.dart)

home_tab.dart                TransactionController, WalletController,
                             ProfileController

statistics_tab.dart          TransactionController

wallet_tab.dart              WalletController, TransactionController,
                             BillController

profile_tab.dart             ProfileController, AuthController

add_transaction_screen.dart  TransactionController, WalletController

transaction_details_screen   TransactionController

connect_wallet_screen.dart   WalletController

bills_screen.dart            BillController, WalletController

bill_details_screen.dart     BillController

bill_payment_screen.dart     BillController, TransactionController,
                             WalletController

qr_scanner_screen.dart       None (just camera)


CONTROLLER FILE              SERVICES/MODELS IT USES
─────────────────────        ─────────────────────────────
AuthController               AuthService (firebase_auth + google_sign_in)

TransactionController        TransactionModel, WalletController

WalletController             WalletModel

BillController               BillModel, TransactionController, Uuid

ProfileController            None (just SharedPreferences directly)

OnboardingController         None (just SharedPreferences directly)
```

---

# PART 9: COMPLETE WALLET FLOW

## Adding a Wallet

```
User is on Wallet Tab
  │
  ├── Taps "Add" button
  │     │
  │     └── Navigator.push(ConnectWalletScreen())
  │           │
  │           ├── Shows "Cards" tab:
  │           │     ├── Preview credit card (auto-updates as user types)
  │           │     ├── Form: Name, Card Number, CVC, Expiry, ZIP
  │           │     └── "Link Card Now" button →
  │           │           _saveCardWallet()
  │           │           │
  │           │           └── Creates WalletModel:
  │           │                 id: Uuid().v4()
  │           │                 name: "Mono Debit Card"
  │           │                 balance: 5750.25  (mock default)
  │           │                 cardHolder: "IRVAN MOSES"
  │           │                 cardNumber: "**** **** **** 8075"
  │           │                 expiryDate: "12/28"
  │           │                 type: 'card'
  │           │                 colorIndex: (cycles through 0-4)
  │           │                 bankLogo: "Visa"
  │           │               │
  │           │               └── walletController.addWallet(newWallet)
  │           │                     │
  │           │                     ├── wallets.add(wallet)  ← adds to list
  │           │                     └── saveWallets()
  │           │                           └── SharedPreferences: 'wallets' = JSON
  │           │
  │           └── Shows "Accounts" tab:
  │                 ├── Options: Bank Link / Microdeposits / PayPal
  │                 └── "Next" button →
  │                       _saveAccountWallet()
  │                       └── Creates WalletModel(balance, type:'bank')
  │                             → walletController.addWallet()
  │
  ├── Taps "Pay" button
  │     └── Navigator.push(QrScannerScreen())
  │           └── Returns scanned string → snackbar "Payment Processed"
  │
  └── Taps "Send" button
        └── _showSendSimulator() (bottom sheet)
              ├── Form: Recipient, Amount, Select Wallet
              └── "Send Payment" →
                    ├── walletController.updateWalletBalance(walletId, amount, 'expense')
                    │     └── wallet.balance -= amount
                    ├── txController.addTransaction(TransactionModel(
                    │     title: 'Transfer to [recipient]',
                    │     type: 'expense',
                    │     category: 'Transfer',
                    │     ...))
                    └── shows "Sent successfully" snackbar
```

---

## Updating Wallet Balance (when a transaction is added/deleted)

```
WHEN TRANSACTION IS ADDED:
  TransactionController.addTransaction(tx)
    │
    └── WalletController.updateWalletBalance(tx.walletId, tx.amount, tx.type)
          │
          ├── Find wallet with matching ID
          ├── if type == 'income' → balance += amount
          ├── if type == 'expense' → balance -= amount
          └── saveWallets()

WHEN TRANSACTION IS DELETED:
  TransactionController.deleteTransaction(txId)
    │
    └── WalletController.updateWalletBalance(tx.walletId, tx.amount, REVERSE_TYPE)
          │
          ├── if original was 'income' → reverse = 'expense' → balance -= amount
          ├── if original was 'expense' → reverse = 'income' → balance += amount
          └── saveWallets()
```

---

# PART 10: COMPLETE BILLS FLOW

## Paying a Bill

```
User is on Wallet Tab (Upcoming Bills section)
  or on Bills Screen (from Profile)
  │
  └── Taps "Pay" button on a bill
        │
        └── Get.to(BillPaymentScreen(bill: bill))
              │
              ├── STEP 1: Review bill details
              │     Show: bill name, amount, due date, provider
              │     "Continue" button
              │
              ├── STEP 2: Confirm payment
              │     Show: wallet selector, payment summary
              │     "Confirm" button
              │
              └── STEP 3: Success / Receipt
                    │
                    └── BillController.payBill(bill.id, walletId, createTransaction: true)
                          │
                          ├── Find bill in list
                          ├── Mark isPaid = true
                          ├── saveBills()
                          │
                          └── If createTransaction == true:
                                ├── Get.find<TransactionController>()
                                ├── Create TransactionModel(
                                │     id: Uuid().v4(),
                                │     title: 'Paid: YouTube Premium',
                                │     amount: 11.99,
                                │     type: 'expense',
                                │     category: 'Entertainment',
                                │     date: DateTime.now(),
                                │     walletId: walletId,
                                │     payee: bill.provider,
                                │     note: 'Auto payment for bill'
                                │   )
                                └── txController.addTransaction(newTx)
                                      └── Also updates wallet balance!
```

---

# PART 11: NAVIGATION & ROUTING

## Route Map

```
GetMaterialApp routes:
  /splash       → SplashScreen          (animated logo)
  /onboarding   → OnboardingScreen       (intro + "Get Started")
  /signin       → SignInScreen           (Google login or Guest)
  /dashboard    → DashboardScreen        (main app with 4 tabs)

Navigating between screens:
  Get.to(() => AddTransactionScreen())         ← push new screen
  Get.toNamed('/onboarding')                   ← go to named route
  Get.back()                                   ← go back
  Get.offAllNamed('/dashboard')                ← clear all & go to dashboard
```

## Screen Hierarchy (Which screens can you reach from where?)

```
SPLASH
  │
  ├──→ ONBOARDING
  │      │
  │      └──→ SIGN IN
  │             │
  │             └──→ DASHBOARD ─────────────────────────────────────
  │                    │                                            │
  │                    ├── [HOME TAB]                               │
  │                    │     ├── Tap transaction → TRANSACTION      │
  │                    │     │                    DETAILS           │
  │                    │     │                      │               │
  │                    │     │                      └── Delete →    │
  │                    │     │                         back home    │
  │                    │     │                                      │
  │                    │     └── Tap "+" → ADD TRANSACTION          │
  │                    │                    │                        │
  │                    │                    └── Save → back home    │
  │                    │                                            │
  │                    ├── [STATISTICS TAB]                         │
  │                    │     └── Tap item → TRANSACTION DETAILS    │
  │                    │                                            │
  │                    ├── [WALLET TAB]                             │
  │                    │     ├── "Add" → CONNECT WALLET             │
  │                    │     ├── "Pay" → QR SCANNER                │
  │                    │     ├── "Send" → bottom sheet send form   │
  │                    │     ├── Tap transaction → TRANSACTION     │
  │                    │     │                   DETAILS            │
  │                    │     └── "Pay" bill → BILL PAYMENT         │
  │                    │                                            │
  │                    ├── [PROFILE TAB]                            │
  │                    │     ├── "Account info" → edit dialog      │
  │                    │     ├── "Personal profile" → bottom sheet │
  │                    │     ├── "Login and security" → sheet      │
  │                    │     ├── "Data and privacy" → sheet       │
  │                    │     ├── "Bills" → BILLS SCREEN           │
  │                    │     │              │                        │
  │                    │     │              ├── Tap bill → BILL    │
  │                    │     │              │            DETAILS   │
  │                    │     │              │              │        │
  │                    │     │              │              └── "Pay │
  │                    │     │              │                  Now"│
  │                    │     │              │                    → │
  │                    │     │              │               BILL   │
  │                    │     │              │               PAYMENT│
  │                    │     │              │                      │
  │                    │     │              └── "+" → add bill     │
  │                    │     │                       dialog        │
  │                    │     │                                      │
  │                    │     └── "Sign Out" → back to ONBOARDING   │
  │                    │                                            │
  │                    └── DASHBOARD IS BROUGHT BY                  │
  │                        (all routes end here or go through it)  │
```

---

# PART 12: SUMMARY — THE BIG PICTURE

## Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        VIEWS LAYER                              │
│  (What user sees and interacts with)                            │
│                                                                  │
│  Files: splash_screen.dart, home_tab.dart,                      │
│         statistics_tab.dart, wallet_tab.dart,                   │
│         profile_tab.dart, add_transaction_screen.dart,          │
│         bills_screen.dart, etc.                                 │
│                                                                  │
│  Job: Display data, capture taps, show animations               │
│  Pattern: Get data via Get.find<Controller>()                   │
│           Auto-update via Obx()                                 │
└──────────────────────┬──────────────────────────────────────────┘
                       │  Calls functions
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CONTROLLERS LAYER                          │
│  (The brain / business logic)                                   │
│                                                                  │
│  Files: AuthController, TransactionController,                  │
│         WalletController, BillController,                       │
│         ProfileController, OnboardingController                 │
│                                                                  │
│  Job: Hold data in Rx variables, provide functions,             │
│       persist data to phone storage                             │
│  Pattern: Get.put() in main.dart                                │
│           Get.find() everywhere else                            │
└──────────────────────┬──────────────────────────────────────────┘
                       │  Reads/Writes
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  (Storage and models)                                           │
│                                                                  │
│  Models: TransactionModel, WalletModel, BillModel               │
│           ├── toJson() → for saving                              │
│           └── fromJson() → for loading                          │
│                                                                  │
│  Storage: SharedPreferences (phone key-value store)             │
│            ├── 'transactions' → JSON string                     │
│            ├── 'wallets' → JSON string                          │
│            ├── 'bills' → JSON string                            │
│            └── 'profile_name', 'is_dark_theme', etc.            │
└─────────────────────────────────────────────────────────────────┘
```

## The Golden Rule of this App

```
User does something (tap, type, swipe)
        │
        ▼
View calls a function on a Controller
        │
        ▼
Controller updates its Rx data
        │
        ├── Saves to phone storage
        └── Data changes
                │
                ▼
Obx() detects change in the View
        │
        ▼
Screen section re-builds with new data

And the user sees the update instantly.
```

## What makes this tick? Key technologies:

| Technology | What it does |
|-----------|-------------|
| **Flutter** | The framework — draws everything on screen |
| **Dart** | The programming language |
| **GetX** | State management — connects View ↔ Controller |
| **SharedPreferences** | Phone storage — saves data permanently |
| **Firebase Auth** | Google login service |
| **Google Sign-In** | Opens Google login popup |
| **fl_chart** | Draws the line chart in Statistics |
| **mobile_scanner** | Opens camera for QR scanning |
| **Google Fonts** | Outfit font throughout app |
| **uuid** | Generates unique IDs for transactions/bills/wallets |
| **intl** | Formats dates and currency ($1,234.56) |
