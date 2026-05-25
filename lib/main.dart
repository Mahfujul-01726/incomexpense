import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Services & DI
import 'services/preferences_service.dart';
import 'pages/auth/auth_controller.dart';

// Routes & Theme
import 'routes/routes.dart';
import 'routes/pages.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Eagerly pre-initialize core services during startup
  await Get.putAsync(() => PreferencesService().init());
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Income & Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: Pages.pages,
    );
  }
}
