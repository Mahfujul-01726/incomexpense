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
│   │   └── app_theme.dart       ← defines teal color, fonts, light/dark mode, card gradients
│   │
│   ├── constants/               ← CENTRALIZED CONSTANTS
│   │   ├── app_constants.dart   ← route paths, SharedPreferences keys, default values, type constants
│   │   └── image_assets.dart    ← all image asset paths in one place
│   │
│   ├── models/                  ← DATA SHAPES (blueprints for data)
│   │   ├── transaction_model.dart   ← what a transaction looks like
│   │   ├── wallet_model.dart        ← what a wallet looks like
│   │   └── bill_model.dart          ← what a bill looks like
│   │
│   ├── data/                    ← DEFAULT/SEED DATA
│   │   └── mock_data.dart       ← starter transactions, wallets & bills
│   │
│   ├── services/                ← EXTERNAL HELPERS & PERSISTENCE
│   │   ├── auth_service.dart         ← talks to Firebase & Google for login
│   │   └── preferences_service.dart  ← reads/writes all data via SharedPreferences + FlutterSecureStorage
│   │
│   ├── bindings/                ← GETX LAZY-LOADING SETUP
│   │   ├── dashboard_binding.dart    ← registers Navigation, Wallet, Transaction, Profile controllers
│   │   ├── bills_binding.dart        ← registers BillController
│   │   └── onboarding_binding.dart   ← registers OnboardingController
│   │
│   ├── routes/                  ← ROUTE DEFINITIONS
│   │   ├── routes.dart          ← route string constants
│   │   └── pages.dart           ← GetPage list with bindings attached
│   │
│   ├── pages/                   ← ALL SCREENS — each feature has its own folder
│   │   ├── splash/              ← splash screen
│   │   │   ├── splash_view.dart           ← UI (fade-in logo)
│   │   │   └── splash_controller.dart     ← animation + nav logic
│   │   │
│   │   ├── onboarding/          ← intro screen
│   │   │   ├── onboarding_view.dart       ← big illustration + "Get Started" button
│   │   │   └── onboarding_controller.dart ← finish / skip logic
│   │   │
│   │   ├── auth/                ← authentication
│   │   │   ├── auth_controller.dart       ← Google sign-in / sign-out logic
│   │   │   └── signin/
│   │   │       └── signin_view.dart       ← Google button + guest mode
│   │   │
│   │   ├── dashboard/           ← main shell with 4 tabs
│   │   │   ├── dashboard_view.dart        ← IndexedStack + FAB + bottom nav
│   │   │   └── navigation_controller.dart ← tab index state
│   │   │
│   │   ├── home/                ← home tab (tab 0)
│   │   │   ├── home_tab.dart              ← balance card + transaction list
│   │   │   ├── transaction_controller.dart← CRUD transactions + totals + filtering
│   │   │   └── transaction_details_view.dart ← receipt-style detail screen
│   │   │
│   │   ├── statistics/          ← statistics tab (tab 1)
│   │   │   └── statistics_tab.dart        ← line chart + top spending
│   │   │
│   │   ├── wallet/              ← wallet tab (tab 2)
│   │   │   ├── wallet_tab.dart            ← cards, send/pay actions, bills list
│   │   │   ├── wallet_controller.dart     ← CRUD wallets + balance update
│   │   │   ├── connect_wallet_view.dart   ← add card/bank form with live preview
│   │   │   └── qr_scanner_view.dart       ← camera QR scanner
│   │   │
│   │   ├── profile/             ← profile tab (tab 3)
│   │   │   ├── profile_tab.dart           ← avatar, menu, edit dialog, sign-out
│   │   │   └── profile_controller.dart    ← name, theme, notifications, biometrics
│   │   │
│   │   ├── bills/               ← bill management
│   │   │   ├── bills_view.dart            ← upcoming + paid tabs
│   │   │   ├── bill_controller.dart       ← CRUD bills + pay bill
│   │   │   ├── bill_details_view.dart     ← invoice layout + pay now
│   │   │   └── bill_payment_view.dart     ← 3-step payment wizard
│   │   │
│   │   └── add_transaction/     ← add income/expense
│   │       └── add_transaction_view.dart  ← merchant picker, amount, date, wallet, etc.
│   │
│   ├── utils/                   ← HELPER FUNCTIONS
│   │   ├── date_helpers.dart    ← "Today" / "Yesterday" / date formatting
│   │   ├── calculations.dart    ← fee calculation (2.9% + $0.30)
│   │   └── logo_helpers.dart    ← maps names to logo asset paths
│   │
│   └── widgets/                 ← REUSABLE UI PIECES
│       ├── app_bottom_nav.dart         ← 4-tab bottom navigation bar
│       ├── bill_logo_widget.dart       ← bill provider logo resolver
│       ├── transaction_logo_widget.dart← merchant logo with fallback icons
│       ├── payment_option_card.dart    ← payment method cards + logos
│       ├── header_wave_clipper.dart    ← CustomClipper for teal curved headers
│       └── dashed_border_painter.dart  ← dashed border for invoice area
```

---

## What does "import" mean?

When a file says `import '../pages/auth/auth_controller.dart'`, it means:
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
│      // Create the storage service (GetxService, async init)    │
│      await Get.putAsync(() => PreferencesService().init());     │
│      //      ↑ This creates PreferencesService which sets up    │
│      //        SharedPreferences + FlutterSecureStorage         │
│      //        and migrates any old plain-text data             │
│                                                                  │
│      // Create AuthController (the ONLY eager controller)       │
│      Get.put(AuthController());          ← login logic           │
│      //      ↑ All other controllers are lazy-loaded            │
│      //        via Get.lazyPut in bindings (see below)          │
│                                                                  │
│      // Start the app                                           │
│      runApp(const MyApp());                                     │
│    }                                                             │
│                                                                  │
│    MyApp builds:                                                 │
│      GetMaterialApp(                                             │
│        theme: AppTheme.lightTheme,       ← teal colors           │
│        themeMode: ThemeMode.light,        ← light by default     │
│        initialRoute: Routes.splash,       ← start here           │
│        getPages: Pages.pages,             ← routes with bindings │
│          // Routes defined in routes/pages.dart:                 │
│          //   '/splash'      → SplashScreen                      │
│          //   '/onboarding'  → OnboardingScreen (OnboardingBinding)
│          //   '/signin'      → SignInScreen                      │
│          //   '/dashboard'   → DashboardScreen (DashboardBinding)
│          //   '/bills'       → BillsScreen (BillsBinding)        │
│      )                                                           │
│                                                                  │
│ ─── HOW CONTROLLERS GET CREATED (via Bindings) ───             │
│                                                                  │
│  DashboardBinding (runs when user visits /dashboard):           │
│    Get.put(NavigationController());      ← tab switching        │
│    Get.lazyPut(() => WalletController(), fenix: true);          │
│    Get.lazyPut(() => TransactionController(), fenix: true);     │
│    Get.lazyPut(() => ProfileController(), fenix: true);         │
│                                                                  │
│  BillsBinding (runs when user visits /bills):                   │
│    Get.lazyPut(() => BillController(), fenix: true);            │
│                                                                  │
│  OnboardingBinding (runs when user visits /onboarding):         │
│    Get.lazyPut(() => OnboardingController(), fenix: true);      │
│                                                                  │
│  What does "fenix: true" mean?                                   │
│    If the controller is ever destroyed (e.g. user leaves page), │
│    it will be re-created automatically when needed again.        │
│                                                                  │
│  Why lazy? Controllers are only created when first needed,       │
│  saving memory at startup.                                       │
└─────────────────────────────────────────────────────────────────┘
```

## PHASE 2: SPLASH SCREEN

### Files: `pages/splash/splash_view.dart` + `pages/splash/splash_controller.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees: App logo fading in for 2.5 seconds              │
│                                                                  │
│ Code that runs:                                                  │
│                                                                  │
│ SplashView uses GetBuilder<SplashController>:                   │
│   init: SplashController()      ← created locally, not global   │
│                                                                  │
│ SplashController (extends GetxController                        │
│                  with GetSingleTickerProviderStateMixin):        │
│                                                                  │
│   @override                                                     │
│   void onInit() {                                               │
│     // Start fade-in animation (1200ms)                          │
│     _initializeAnimations();                                     │
│     // Wait 2.5 seconds, then decide where to go                 │
│     _navigateToNext();                                           │
│   }                                                              │
│                                                                  │
│   void _initializeAnimations() {                                │
│     animationController = AnimationController(                   │
│       duration: Duration(milliseconds: 1200),                   │
│     );                                                           │
│     fadeAnimation = CurvedAnimation(parent: ..., curve: easeIn); │
│     animationController.forward();                               │
│   }                                                              │
│                                                                  │
│   Future<void> _navigateToNext() async {                        │
│     await Future.delayed(Duration(milliseconds: 2500));          │
│                                                                  │
│     // DECISION 1: Is user logged in with Google?                │
│     final firebaseUser = FirebaseAuth.instance.currentUser;      │
│     if (firebaseUser != null) {                                 │
│       // YES → go straight to dashboard                          │
│       Get.offAllNamed(Routes.dashboard);                         │
│       return;                                                    │
│     }                                                            │
│                                                                  │
│     // DECISION 2: Has user completed onboarding before?         │
│     final prefsService = Get.find<PreferencesService>();         │
│     final onboardingCompleted =                                  │
│         await prefsService.getOnboardingCompleted();             │
│                                                                  │
│     if (onboardingCompleted) {                                   │
│       // YES → go to dashboard (guest mode)                      │
│       Get.offAllNamed(Routes.dashboard);                         │
│     } else {                                                     │
│       // NO → show onboarding screen                             │
│       Get.offAllNamed(Routes.onboarding);                        │
│     }                                                            │
│   }                                                              │
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

### Files: `pages/onboarding/onboarding_view.dart` + `pages/onboarding/onboarding_controller.dart`
### Binding: `bindings/onboarding_binding.dart` (lazy-loads OnboardingController)

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - Illustration guy image at top (62% of screen height)        │
│   - Teal-ish background behind illustration                     │
│   - "Spend Smarter Save More" text (32px, dark teal, bold)     │
│   - "Get Started" teal gradient button with animated scale      │
│   - "Already Have Account? Log In" link                         │
│                                                                  │
│ Controller's code:                                               │
│   OnboardingController {                                         │
│                                                                  │
│     // Uses PreferencesService (GetxService) for storage         │
│     final _prefsService = Get.find<PreferencesService>();        │
│                                                                  │
│     // Called by "Get Started" button                            │
│     completeOnboarding() {                                       │
│       Get.toNamed(Routes.signin);  ← go to Sign In screen        │
│     }                                                            │
│                                                                  │
│     // Called from AuthController after successful login,        │
│     // or from SignInScreen "Continue as Guest" tap              │
│     finishOnboarding() async {                                   │
│       await _prefsService.setOnboardingCompleted(true);          │
│       Get.offAllNamed(Routes.dashboard);                         │
│     }                                                            │
│   }                                                              │
│                                                                  │
│ NOTE: This is NOT a slideshow. Just a single landing page.       │
│ No PageView, no swipeable slides.                                │
│                                                                  │
│ USER TAPS:                                                       │
│                                                                  │
│  "Get Started" button → completeOnboarding() → /signin          │
│  "Log In" link       → Get.toNamed(Routes.signin)               │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 4: SIGN IN SCREEN

### Files: `pages/auth/signin/signin_view.dart` + `pages/auth/auth_controller.dart`
### Service: `services/auth_service.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - Back button (top-left)                                      │
│   - App icon (wallet icon)                                      │
│   - "Welcome!" text                                             │
│   - 3 feature highlight cards (Smart Analytics, Multi-Wallet,   │
│     Cloud Sync) with press animations                           │
│   - "Continue with Google" button with custom Google G painter  │
│   - "or" divider                                               │
│   - "Continue as Guest" button (outlined teal)                  │
│   - Terms of Service text                                       │
│                                                                  │
│ AuthController:                                                  │
│   - Created once at startup in main.dart via Get.put()          │
│   - Binds Firebase auth state stream to `user` Rx on init:      │
│     user.bindStream(_authService.authStateChanges)              │
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
│   │   // STEP 2: If login succeeded, save onboarding flag  │     │
│   │   // and go to dashboard directly                      │     │
│   │   if (signedInUser != null) {                         │     │
│   │     final prefsService = Get.find<PreferencesService>();│     │
│   │     await prefsService.setOnboardingCompleted(true);   │     │
│   │     Get.offAllNamed(Routes.dashboard);                  │     │
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
│   After login: AuthController directly calls:                   │
│     → prefsService.setOnboardingCompleted(true)                 │
│     → Get.offAllNamed(Routes.dashboard)                         │
│   (Does NOT delegate to OnboardingController anymore)           │
│                                                                  │
│ ─── GUEST MODE PATH ───                                        │
│                                                                  │
│ User taps "Continue as Guest" →                                 │
│   OnboardingController.finishOnboarding() (from signin_view)    │
│     → calls _prefsService.setOnboardingCompleted(true)           │
│     → Get.offAllNamed(Routes.dashboard)                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## PHASE 5: DASHBOARD (Main App Screen)

### File: `pages/dashboard/dashboard_view.dart`
### Controller: `pages/dashboard/navigation_controller.dart`

```
┌─────────────────────────────────────────────────────────────────┐
│ What user sees:                                                 │
│   - One of 4 tabs shown in the middle                           │
│   - "+" floating action button at bottom-center (teal, glow)    │
│   - Bottom navigation bar with 4 icons                          │
│     [Home] [Statistics] [Wallet] [Profile]                      │
│                                                                  │
│ Code:                                                            │
│                                                                  │
│ class DashboardScreen {                                          │
│   // Get the NavigationController (created by DashboardBinding) │
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
│         floatingActionButton: teal circular button →             │
│           Get.to(() => AddTransactionScreen()),                  │
│                                                                  │
│         bottomNavigationBar: AppBottomNav()  ← the 4 icons in   │
│       )                                                          │
│     })                                                           │
│   }                                                              │
│ }                                                                │
│                                                                  │
│ NavigationController (pages/dashboard/navigation_controller.dart)│
│   class NavigationController extends GetxController {            │
│     var selectedIndex = 0.obs;  // 0=Home, 1=Stats, 2=Wallet,   │
│                                 // 3=Profile                     │
│     void changeTab(int index) => selectedIndex.value = index;    │
│   }                                                              │
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

### File: `pages/home/home_tab.dart`

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
│     onTap → Get.to(TransactionDetailsScreen(transaction: tx))
    // TransactionDetailsScreen: pages/home/transaction_details_view.dart   │
│                                                                  │
│   _buildSendAgainSection() →                                     │
│     shows 5 avatar images, "See all" opens bottom sheet          │
│ }                                                                 │
 │                                                                  │
│ NOTE: NavigationController is in a separate file:                │
│   pages/dashboard/navigation_controller.dart                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## TAB 1: STATISTICS TAB

### File: `pages/statistics/statistics_tab.dart`

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

### File: `pages/wallet/wallet_tab.dart`
### Controllers: `pages/wallet/wallet_controller.dart`, `pages/home/transaction_controller.dart`, `pages/bills/bill_controller.dart`

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
│  │           (due date varies based on mock data)       │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ [House]   House Rent               $1,200.00 [Pay]  │        │
│  │           (tomorrow from today)                        │        │
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

### File: `pages/profile/profile_tab.dart`
### Controllers: `pages/profile/profile_controller.dart`, `pages/auth/auth_controller.dart`

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
│  │ 📋 Bills                                             │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │ 🚪 Sign Out (red)                                    │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│ WHAT EACH MENU ITEM DOES:                                        │
│                                                                  │
│  "Account info" →                                                │
│    Opens dialog to edit name, email, phone                       │
│    Save → profileController.updateProfile(name, email, phone)   │
│      → saves via PreferencesService (FlutterSecureStorage)      │
│                                                                  │
│  "Personal profile" →                                            │
│    Bottom sheet with toggle:                                     │
│      Receive Notifications → toggle                              │
│        → saves 'receive_notifications' to SharedPreferences      │
│                                                                  │
│  "Login and security" →                                          │
│    Bottom sheet: Fingerprint Lock toggle                         │
│      → saves 'biometrics_enabled' to FlutterSecureStorage       │
│                                                                  │
│  "Data and privacy" →                                            │
│    Bottom sheet: Export Transactions (mock)                      │
│                                                                  │
│  "Bills" →                                                       │
│    Get.toNamed(Routes.bills) → navigates to BillsScreen         │
│      (separate full-screen view via /bills route)                │
│                                                                  │
│  "Sign Out" →                                                    │
│    Confirmation dialog →                                         │
│      AuthController.signOut()                                    │
│        ├── AuthService.signOut()                                 │
│        │     ├── GoogleSignIn.signOut()                          │
│        │     └── FirebaseAuth.signOut()                         │
│        ├── PreferencesService: onboarding_completed = false     │
│        └── Get.offAllNamed(Routes.onboarding)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

# PART 4: THE ADD TRANSACTION FLOW (Most Important)

### File: `pages/add_transaction/add_transaction_view.dart`

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

### File: `pages/home/transaction_controller.dart`

This is the most important controller. Let's trace through it completely.

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. CREATION (happens via DashboardBinding when first needed)    │
│                                                                  │
│    Get.lazyPut(() => TransactionController(), fenix: true);     │
│                                                                  │
│    When created, onInit() runs:                                  │
│      ever(transactions, (_) => _recalculateTotals());           │
│      loadTransactions();                                         │
│                                                                  │
│ 2. loadTransactions() — reads from phone storage                │
│    (via PreferencesService, which uses FlutterSecureStorage)     │
│                                                                  │
│    loadTransactions() async {                                   │
│      isLoading = true                                           │
│                                                                  │
│      // Use PreferencesService (GetxService) to read             │
│      loaded = await _prefsService.loadTransactions()            │
│                                                                  │
│      if (loaded is not empty) {                                 │
│        // Data exists in storage → load it                       │
│        transactions.value = loaded                               │
│      }                                                          │
│      else if (MockData.useMockData) {                           │
│        // FIRST TIME: use seed data from MockData class          │
│        transactions.value = MockData.defaultTransactions         │
│        saveTransactions()  ← save these to phone                │
│      }                                                          │
│                                                                  │
│      isLoading = false                                          │
│    }                                                             │
│                                                                  │
│    MockData.defaultTransactions (in data/mock_data.dart):       │
│      [TransactionModel(id:'t_1', title:'Upwork',                │
│         amount:850,   type:'income',  date: now),               │
│       TransactionModel(id:'t_2', title:'Transfer',              │
│         amount:85,    type:'expense', date: now - 1 day),       │
│       TransactionModel(id:'t_3', title:'Paypal',                │
│         amount:1406,  type:'income',  date: Jan 30, 2022),      │
│       TransactionModel(id:'t_4', title:'Youtube',               │
│         amount:11.99, type:'expense', date: Jan 16, 2022),      │
│       TransactionModel(id:'t_5', title:'Starbucks',             │
│         amount:150,   type:'expense', date: Jan 12, 2022)]      │
│                                                                  │
│ 3. addTransaction(newTx) — adds new transaction                 │
│                                                                  │
│    addTransaction(TransactionModel transaction) {                │
│      // Add to the FRONT of the list                             │
│      transactions.insert(0, transaction);                        │
│                                                                  │
│      // Save to phone storage via PreferencesService             │
│      saveTransactions();                                         │
│                                                                  │
│      // Also update the wallet's balance                         │
│      WalletController wc = Get.find<WalletController>();        │
│      wc.updateWalletBalance(                                     │
│        transaction.walletId,     ← which wallet                  │
│        transaction.amount,       ← how much                      │
│        transaction.type          ← 'income' adds, 'expense' sub  │
│      );                                                          │
│    }                                                             │
│                                                                  │
│ 4. saveTransactions() — writes to phone storage                 │
│                                                                  │
│    saveTransactions() async {                                    │
│      // Delegates to PreferencesService (FlutterSecureStorage)   │
│      await _prefsService.saveTransactions(transactions.toList()) │
│                                                                  │
│      // Inside PreferencesService:                               │
│      //   1. jsonEncode(transactions.map(e → e.toJson()))       │
│      //   2. Write to FlutterSecureStorage (encrypted)          │
│      //      under key 'transactions'                           │
│    }                                                             │
│                                                                  │
│ 5. deleteTransaction(id) — removes a transaction                │
│                                                                  │
│    deleteTransaction(String transactionId) {                     │
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
│ 6. Reactive totals (with ever() listener)                        │
│                                                                  │
│    // Instead of computed getters, totals are Rx< double > that  │
│    // auto-recalculate whenever the transactions list changes:   │
│                                                                  │
│    rxTotalIncome = 0.0.obs                                       │
│    rxTotalExpenses = 0.0.obs                                     │
│                                                                  │
│    onInit() {                                                    │
│      ever(transactions, (_) => _recalculateTotals());            │
│      // ↑ "every time transactions changes, run this function"   │
│    }                                                             │
│                                                                  │
│    _recalculateTotals() {                                        │
│      // Loop through all transactions and sum income vs expense  │
│      rxTotalIncome.value = sum of all 'income' amounts          │
│      rxTotalExpenses.value = sum of all 'expense' amounts       │
│    }                                                             │
│                                                                  │
│    // Exposed as regular getters:                                │
│    double get totalIncome => rxTotalIncome.value;                │
│    double get totalExpenses => rxTotalExpenses.value;            │
│                                                                  │
│ 7. Filtering (used by Statistics tab)                            │
│                                                                  │
│    selectedPeriod = 'Week'.obs   // 'Day', 'Week', 'Month',     │
│                                  // 'Year'                       │
│    selectedType = 'expense'.obs  // 'income' or 'expense'       │
│                                                                  │
│    List<TransactionModel> get filteredTransactions {             │
│      // Return only transactions that match selected period      │
│      // AND selected type                                        │
│      // Used by Statistics tab for line chart                    │
│      now = DateTime.now()                                        │
│      threshold = switch (selectedPeriod.value) {                 │
│        'Day'   => now - 1 day                                    │
│        'Week'  => now - 7 days                                   │
│        'Month' => now - 30 days                                  │
│        _       => now - 365 days  // 'Year'                      │
│      }                                                           │
│                                                                  │
│      return transactions.where(                                  │
│        type == selectedType.value AND date.isAfter(threshold)    │
│      ).toList()                                                  │
│    }                                                             │
│                                                                  │
│    Map<String, double> get categoryBreakdown {                   │
│      // Group filteredTransactions by category                   │
│      // e.g., {'Subscriptions': 11.99, 'Food & Dining': 150.00} │
│      // Used on Statistics tab for chart breakdown               │
│      for each t in filteredTransactions:                         │
│        breakdown[t.category] += t.amount                         │
│      return breakdown                                            │
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
Saving:   TransactionModel → toJson() → Map → jsonEncode → String → FlutterSecureStorage
Loading:  FlutterSecureStorage → String → jsonDecode → Map → fromJson() → TransactionModel
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
  final double balance;     // 2548.00
  final String cardHolder;  // "Mahfujur Rahman"
  final String cardNumber;  // "**** **** **** 8075" (masked)
  final String expiryDate;  // "22/01"
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
│ DARK THEME SUPPORT:                                               │
│   AppTheme.darkTheme is fully defined but currently not           │
│   togglable from the UI — main.dart uses themeMode: ThemeMode    │
│   .light (hardcoded).                                            │
│   ProfileController loads/saves 'is_dark_theme' to SharedPrefs   │
│   but no UI toggle calls Get.changeThemeMode() yet.              │
│   (Theme is ready for future implementation.)                     │
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
┌────────┐ ┌────────────────────────────┐
│ MODEL  │ │ PREFERENCES SERVICE        │
│ File   │ │ (GetxService)              │
│        │ │                            │
│ toJson │ │ ├── FlutterSecureStorage   │
│ fromJson│ │ │   (encrypted data)      │
│        │ │ │   'transactions' → JSON  │
│ Blue-  │ │ │   'wallets'      → JSON  │
│ print  │ │ │   'bills'        → JSON  │
│        │ │ │                            │
│        │ │ └── SharedPreferences      │
│        │ │     (plain settings)       │
│        │ │     'is_dark_theme' → bool │
│        │ │     'onboarding_completed' │
└────────┘ └────────────────────────────┘
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
splash_view.dart             None (uses SplashController locally,
                              FirebaseAuth directly + PreferencesService)

onboarding_view.dart         OnboardingController (via GetView)

signin_view.dart             AuthController, OnboardingController

dashboard_view.dart          NavigationController

home_tab.dart                TransactionController, WalletController,
                             ProfileController

statistics_tab.dart          TransactionController

wallet_tab.dart              WalletController, TransactionController,
                             BillController

profile_tab.dart             ProfileController, AuthController,
                             NavigationController (for back button)

add_transaction_view.dart    TransactionController, WalletController

transaction_details_view     TransactionController

connect_wallet_view.dart     WalletController

bills_view.dart              BillController

bill_details_view.dart       BillController

bill_payment_view.dart       BillController, WalletController

qr_scanner_view.dart         None (just camera)

navigation_controller.dart   None (pure state management)


CONTROLLER FILE              SERVICES/MODELS IT USES
─────────────────────        ─────────────────────────────
AuthController               AuthService (firebase_auth + google_sign_in),
                             PreferencesService (for onboarding flag)

TransactionController        PreferencesService (FlutterSecureStorage),
                             TransactionModel, WalletController,
                             MockData (seed data)

WalletController             PreferencesService (FlutterSecureStorage),
                             WalletModel, MockData (seed data)

BillController               PreferencesService (FlutterSecureStorage),
                             BillModel, TransactionController,
                             Uuid, MockData (seed data)

ProfileController            PreferencesService (FlutterSecureStorage
                             for name/email/phone/biometrics,
                             SharedPreferences for notif/theme)

OnboardingController         PreferencesService (SharedPreferences
                             for onboarding_completed flag)

SplashController             PreferencesService + FirebaseAuth
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
  │           │   File: pages/wallet/connect_wallet_view.dart
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
  │           │                 balance: 2548.00  (mock default)
  │           │                 cardHolder: "Mahfujur Rahman"
  │           │                 cardNumber: "**** **** **** 8075"
  │           │                 expiryDate: "22/01"
  │           │                 type: 'card'
  │           │                 colorIndex: (cycles through 0-4)
  │           │                 bankLogo: "Visa"
  │           │               │
  │           │               └── walletController.addWallet(newWallet)
  │           │                     │
  │           │                     ├── wallets.add(wallet)  ← adds to list
  │           │                     └── saveWallets()
  │           │                           └── via PreferencesService (secure)
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
  │           │   File: pages/wallet/qr_scanner_view.dart
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
  or on Bills Screen (from Profile → "Bills" menu, /bills route)
  │
  └── Taps "Pay" button on a bill
        │
        └── Get.to(BillPaymentScreen(bill: bill))
              │   Bill views: pages/bills/bills_view.dart,
              │              bill_details_view.dart, bill_payment_view.dart
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
                          │   Controller: pages/bills/bill_controller.dart
                          │
                          ├── Find bill in list
                          ├── Mark isPaid = true (using copyWith)
                          ├── saveBills() via PreferencesService
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
                                │     note: 'Automatic or manual payment for bill'
                                │   )
                                └── txController.addTransaction(newTx)
                                      └── Also updates wallet balance!
```

---

# PART 11: NAVIGATION & ROUTING

## Route Map

```
Route definitions in: lib/routes/routes.dart + lib/routes/pages.dart
Bindings attached to routes for lazy controller loading:

  /splash       → SplashScreen          (no binding — local controller)
  /onboarding   → OnboardingScreen       (OnboardingBinding)
  /signin       → SignInScreen           (no binding — uses global AuthController)
  /dashboard    → DashboardScreen        (DashboardBinding)
  /bills        → BillsScreen            (BillsBinding)

Navigating between screens:
  Get.to(() => AddTransactionScreen())         ← push new screen
  Get.toNamed(Routes.signin)                   ← go to named route
  Get.offAllNamed(Routes.dashboard)            ← clear all & go to dashboard
  Get.back()                                   ← go back
```

## Screen Hierarchy (Which screens can you reach from where?)

```
SPLASH
  │
  ├──→ ONBOARDING
  │      │
  │      └──→ SIGN IN
  │             │
  │             └──→ DASHBOARD ──────────────────→ /BILLS ─────────
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
│                    │     ├── "Message center" → snackbar       │
│                    │     ├── "Login and security" → sheet      │
│                    │     ├── "Data and privacy" → sheet       │
│                    │     ├── "Bills" → /bills → BILLS SCREEN  │
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
│  Files: pages/splash/splash_view.dart, home_tab.dart,           │
│         statistics_tab.dart, wallet_tab.dart,                   │
│         profile_tab.dart, add_transaction_view.dart,            │
│         bills_view.dart, etc.                                   │
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
│         ProfileController, OnboardingController,                │
│         NavigationController                                    │
│                                                                  │
│  Job: Hold data in Rx variables, provide functions,             │
│       persist data to phone storage via PreferencesService      │
│  Pattern: Get.lazyPut (with fenix) in bindings                  │
│           Get.put for AuthController + NavigationController      │
│           Get.find() everywhere else                            │
└──────────────────────┬──────────────────────────────────────────┘
                       │  Reads/Writes via PreferencesService
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  (Storage and models)                                           │
│                                                                  │
│  Models: TransactionModel, WalletModel, BillModel               │
│           ├── toJson() → for saving                              │
│           └── fromJson() → for loading                          │
│                                                                  │
│  Gateway: PreferencesService (GetxService)                      │
│           ├── init() → SharedPreferences + FlutterSecureStorage │
│           └── Migration from plain to encrypted storage         │
│                                                                  │
│  Storage:                                                        │
│    FlutterSecureStorage (encrypted):                             │
│      ├── 'transactions' → JSON string                           │
│      ├── 'wallets' → JSON string                                │
│      ├── 'bills' → JSON string                                  │
│      ├── 'profile_name', 'profile_email', 'profile_phone'       │
│      └── 'biometrics_enabled'                                   │
│                                                                  │
│    SharedPreferences (plain):                                   │
│      ├── 'is_dark_theme' (bool)                                 │
│      ├── 'receive_notifications' (bool)                         │
│      └── 'onboarding_completed' (bool)                          │
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
| **GetX** | State management + routing + dependency injection |
| **SharedPreferences** | Plain settings storage (theme, notifs, onboarding flag) |
| **FlutterSecureStorage** | Encrypted storage for sensitive data (transactions, wallets, bills, profile) |
| **PreferencesService** | GetxService wrapper around both storage backends, handles migration |
| **Firebase Auth** | Google login service |
| **Google Sign-In** | Opens Google login popup |
| **fl_chart** | Draws the line chart in Statistics |
| **mobile_scanner** | Opens camera for QR scanning |
| **Google Fonts** | Outfit font throughout app |
| **uuid** | Generates unique IDs for transactions/bills/wallets |
| **intl** | Formats dates and currency ($1,234.56) |
