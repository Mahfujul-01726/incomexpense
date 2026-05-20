<div align="center">
  <img src="assets/cropped/app_icon.png" alt="Income & Expense Tracker" width="100" height="100" />

  # Income & Expense Tracker

  **A cross-platform Flutter application for personal finance management**

  [![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart)](https://dart.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

  <p>
    Track income & expenses · Manage wallets & cards · Visualize spending statistics · Pay bills
  </p>
</div>

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup](#firebase-setup)
  - [Running the App](#running-the-app)
  - [Building for Release](#building-for-release)
- [Project Structure](#project-structure)
- [Available Scripts](#available-scripts)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### Authentication & Onboarding

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/1.png" alt="Onboarding Screen" width="200"/>
  <figcaption>Splash & Onboarding flow</figcaption>
</figure>

- Splash screen with fade-in animation and automatic auth state resolution
- 3-step onboarding carousel introducing core app capabilities
- Google Sign-In via Firebase Authentication
- Guest mode for users who prefer to explore without signing in

### Dashboard

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Homepage3.png" alt="Home Dashboard" width="200"/>
  <figcaption>Home tab — balance card & recent transactions</figcaption>
</figure>

- **Home** — Total balance card with income/expense breakdown, recent transaction feed, and quick-send contact avatars

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Statistic4.png" alt="Statistics" width="200"/>
  <figcaption>Statistics tab — interactive charts</figcaption>
</figure>

- **Statistics** — Period filters (Day / Week / Month / Year) with interactive line charts powered by `fl_chart`, income/expense type segmentation, and top spending breakdown

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Wallet7.png" alt="Wallets" width="200"/>
  <figcaption>Wallet tab — balance & actions</figcaption>
</figure>

- **Wallets** — Multi-wallet management, balance overview, segmented transaction/upcoming bills view, QR-code-based payments via `mobile_scanner`

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Profile6.png" alt="Profile" width="200"/>
  <figcaption>Profile tab — settings & sign-out</figcaption>
</figure>

- **Profile** — User profile management, dark theme toggle, biometric lock, data export, and sign-out

### Transaction Management

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Add%20Expense5.png" alt="Add Transaction" width="200"/>
  <figcaption>Add transaction form</figcaption>
</figure>

- Add transactions with merchant selection (Netflix, YouTube, PayPal, Upwork, etc.), categorized tags, date picker, wallet source, optional notes and invoice attachments
- Income/expense type toggle on every transaction

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Transaction%20Details%20(Income)11.png" alt="Transaction Details Income" width="200"/>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Transaction%20Details%20(Expense)12.png" alt="Transaction Details Expense" width="200"/>
  <figcaption>Receipt-style transaction details (income & expense)</figcaption>
</figure>

- Receipt-style transaction details with copyable transaction ID, status badges, and delete with automatic balance reversal

### Wallets & Cards

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Connect%20Wallet10.png" alt="Connect Wallet" width="200"/>
  <figcaption>Connect wallet — cards & accounts</figcaption>
</figure>

- Add debit cards with form fields for card number, expiry, CVC, and ZIP code
- Connect bank accounts via bank link, microdeposits, or PayPal
- QR scanner for wallet-to-wallet payments

### Bills & Payments

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Bill%20Details13.png" alt="Bill Details" width="200"/>
  <figcaption>Bill detail — invoice layout & auto-pay</figcaption>
</figure>

- Upcoming/due bills with overdue, due-today, and due-in-X-days status indicators
- Bill details with invoice-style layout and auto-pay toggle

<figure>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Bill%20Payment14.png" alt="Bill Payment Step 1" width="200"/>
  <img src="Income%20%26%20Expense%20Tracker%20App%20(Community)/Bill%20Payment15.png" alt="Bill Payment Step 3" width="200"/>
  <figcaption>3-step payment wizard: review → confirm → receipt</figcaption>
</figure>

- 3-step payment wizard: review → confirm → success with receipt

### Personalization
- Light & dark themes with teal-based color palette
- Profile customization (avatar, name, notification preferences)
- Biometric authentication toggle for app security

---

## Screenshots

| Homepage | Statistics | Wallets |
|:--------:|:----------:|:-------:|
| ![Home](Income%20%26%20Expense%20Tracker%20App%20(Community)/Homepage3.png) | ![Statistics](Income%20%26%20Expense%20Tracker%20App%20(Community)/Statistic4.png) | ![Wallet](Income%20%26%20Expense%20Tracker%20App%20(Community)/Wallet7.png) |

> **Note:** Full design mockups and a PDF spec are available in the `Income & Expense Tracker App (Community)/` directory.

---

## Tech Stack

| Layer           | Technology                                                                 |
|----------------|----------------------------------------------------------------------------|
| **Language**   | Dart 3.12+                                                                 |
| **Framework**  | Flutter (stable channel)                                                   |
| **State Mgmt** | [GetX](https://pub.dev/packages/get) — reactive state, DI, routing         |
| **Auth**       | Firebase Authentication + Google Sign-In                                   |
| **Storage**    | SharedPreferences (local JSON persistence)                                 |
| **Charts**     | [fl_chart](https://pub.dev/packages/fl_chart)                              |
| **QR Scanner** | [mobile_scanner](https://pub.dev/packages/mobile_scanner)                  |
| **Icons**      | flutter_launcher_icons                                                     |
| **Fonts**      | Google Fonts (Outfit)                                                      |
| **Linting**    | flutter_lints                                                              |

---

## Architecture

### Layer Diagram

```mermaid
graph TB
    subgraph UI_Layer["Presentation Layer"]
        Views["Views / Screens"]
        Themes["App Theme<br/>Light / Dark"]
    end

    subgraph Logic_Layer["Controller Layer (GetX)"]
        AuthCtrl["AuthController"]
        TxnCtrl["TransactionController"]
        WalletCtrl["WalletController"]
        BillCtrl["BillController"]
        ProfileCtrl["ProfileController"]
        OnboardCtrl["OnboardingController"]
    end

    subgraph Data_Layer["Data Layer"]
        Models["Models<br/>TransactionModel<br/>WalletModel<br/>BillModel"]
        SP["SharedPreferences<br/>JSON Persistence"]
    end

    subgraph Service_Layer["Service Layer"]
        AuthSvc["AuthService<br/>Firebase Auth + Google Sign-In"]
    end

    subgraph External["External Services"]
        Firebase["Firebase Auth"]
    end

    Views -->|"Obx / GetBuilder"| AuthCtrl
    Views -->|"Obx / GetBuilder"| TxnCtrl
    Views -->|"Obx / GetBuilder"| WalletCtrl
    Views -->|"Obx / GetBuilder"| BillCtrl
    Views -->|"Obx / GetBuilder"| ProfileCtrl
    Views -->|"Obx / GetBuilder"| OnboardCtrl

    AuthCtrl --> AuthSvc
    AuthSvc --> Firebase

    TxnCtrl --> Models
    WalletCtrl --> Models
    BillCtrl --> Models

    TxnCtrl -->|"json encode/decode"| SP
    WalletCtrl -->|"json encode/decode"| SP
    BillCtrl -->|"json encode/decode"| SP
    ProfileCtrl -->|"json encode/decode"| SP
```

### App Navigation Map

```mermaid
flowchart LR
    Splash["/splash<br/>Splash Screen"] --> AuthCheck{"Signed In?"}
    AuthCheck -->|"No"| Onboard{"/onboarding<br/>Onboarding?"}
    AuthCheck -->|"Yes"| Dash["/dashboard<br/>Dashboard (4 Tabs)"]

    Onboard -->|"First Launch"| Carousel["3-Step Carousel"]
    Onboard -->|"Returning"| SignIn["/signin<br/>Sign In Screen"]

    Carousel --> SignIn
    SignIn -->|"Google Sign-In"| Dash
    SignIn -->|"Guest"| Dash

    Dash --> Home["Home Tab<br/>Balance + Recent"]
    Dash --> Stats["Statistics Tab<br/>Chart + Filters"]
    Dash --> Wallet["Wallet Tab<br/>Cards + Actions"]
    Dash --> Profile["Profile Tab<br/>Settings + Sign Out"]

    Home --> AddTxn["/add_transaction<br/>Add Transaction"]
    Home --> TxnDetail["/transaction_details<br/>Transaction Detail"]

    Wallet --> ConnectWallet["/connect_wallet<br/>Add Card / Bank"]
    Wallet --> QRScan["/qr_scanner<br/>QR Payment"]

    Stats --> AddTxn

    Profile --> Bills["/bills<br/>Bills List"]
    Bills --> BillDetail["/bill_details<br/>Bill Detail"]
    BillDetail --> BillPay["/bill_payment<br/>3-Step Payment"]

    TxnDetail --> AddTxn
    ConnectWallet --> QRScan
```

### Data Model Relationships

```mermaid
erDiagram
    Transaction {
        string id PK
        string title
        double amount
        string type "income | expense"
        string category
        string merchant
        string walletId FK
        string note
        DateTime date
    }

    Wallet {
        string id PK
        string name
        string type "card | bank | paypal"
        double balance
        string cardNumber
        string expiryDate
        string cardHolderName
    }

    Bill {
        string id PK
        string name
        double amount
        string provider
        string category
        bool autoPay
        string status "upcoming | paid | overdue"
        DateTime dueDate
        string walletId FK
    }

    Transaction ||--o{ Wallet : "belongs to"
    Bill ||--o{ Wallet : "paid from"
```

**Key Architectural Decisions:**

- **GetX State Management** — Controllers are global singletons registered via `Get.put()` in `main.dart`, accessed via `Get.find()` throughout the app. Screens observe reactive state with `Obx`.
- **Local-First Storage** — All CRUD operations use `SharedPreferences` with JSON serialization. There is no remote database — data never leaves the device.
- **Firebase Auth Only** — Firebase is used solely for Google Sign-In authentication. No Firestore, Realtime Database, or cloud functions.
- **Mock Data Seeding** — On first launch, the app seeds sample transactions, wallets, and bills so the UI is never empty.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, `>=3.12.0`)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- A [Firebase project](https://console.firebase.google.com/) with **Authentication** and **Google Sign-In** enabled
- Android device / emulator (API 21+)

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/incomexpense.git
cd incomexpense

# Install dependencies
flutter pub get
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Google Sign-In** in Authentication → Sign-in method
3. Register your Android app in Project settings → General → Your apps
4. Download `google-services.json` and place it in:

   ```
   android/app/google-services.json
   ```

5. (Optional) For iOS, download `GoogleService-Info.plist` and add it to the Xcode project

> **Security:** `google-services.json` and `GoogleService-Info.plist` are gitignored. Never commit them.

### Running the App

```bash
# Run on a connected device or emulator
flutter run

# Run with a specific device
flutter devices          # List available devices
flutter run -d <device-id>
```

### Building for Release

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle
```

> For a signed release build, configure `android/key.properties` and a keystore file (see [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app)).

---

## Project Structure

```
lib/
├── main.dart                        # Entry point, DI, route config
├── theme/
│   └── app_theme.dart               # Light + dark theme definitions
├── controllers/                     # GetX business logic + reactive state
│   ├── auth_controller.dart
│   ├── bill_controller.dart
│   ├── onboarding_controller.dart
│   ├── profile_controller.dart
│   ├── transaction_controller.dart
│   └── wallet_controller.dart
├── models/                          # JSON-serializable data classes
│   ├── bill_model.dart
│   ├── transaction_model.dart
│   └── wallet_model.dart
├── services/                        # External service abstractions
│   └── auth_service.dart
└── views/                           # UI screens by feature
    ├── splash_screen.dart
    ├── dashboard_screen.dart
    ├── onboarding/
    │   └── onboarding_screen.dart
    ├── auth/
    │   └── signin_screen.dart
    ├── home/
    │   ├── home_tab.dart
    │   └── transaction_details_screen.dart
    ├── statistics/
    │   └── statistics_tab.dart
    ├── wallet/
    │   ├── wallet_tab.dart
    │   ├── connect_wallet_screen.dart
    │   └── qr_scanner_screen.dart
    ├── profile/
    │   └── profile_tab.dart
    ├── bills/
    │   ├── bills_screen.dart
    │   ├── bill_details_screen.dart
    │   └── bill_payment_screen.dart
    └── add_transaction/
        └── add_transaction_screen.dart
```

---

## Available Scripts

| Command                            | Description                        |
|------------------------------------|------------------------------------|
| `flutter pub get`                  | Install dependencies               |
| `flutter run`                      | Run in debug mode                  |
| `flutter build apk`               | Build Android APK                  |
| `flutter build appbundle`         | Build Android App Bundle           |
| `flutter test`                     | Run tests                          |
| `flutter analyze`                  | Run static analysis                |
| `flutter pub run flutter_launcher_icons` | Regenerate app launcher icons |

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push to the branch: `git push origin feat/my-feature`
5. Open a pull request

Please ensure your code passes `flutter analyze` and existing tests before submitting.

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/mdmafjujulkarim">MD MAFJUJUL KARIM SHEIKH</a></sub>
</div>
