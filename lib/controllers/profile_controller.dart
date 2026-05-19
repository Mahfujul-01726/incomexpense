import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  var name = 'Enjelin Morgeana'.obs;
  var email = 'enjelin@community.com'.obs;
  var phone = '+1 (555) 019-2834'.obs;
  var isDarkTheme = false.obs;
  var receiveNotifications = true.obs;
  var biometricsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileSettings();
  }

  Future<void> loadProfileSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name.value = prefs.getString('profile_name') ?? 'Enjelin Morgeana';
      email.value = prefs.getString('profile_email') ?? 'enjelin@community.com';
      phone.value = prefs.getString('profile_phone') ?? '+1 (555) 019-2834';
      isDarkTheme.value = prefs.getBool('is_dark_theme') ?? false;
      receiveNotifications.value = prefs.getBool('receive_notifications') ?? true;
      biometricsEnabled.value = prefs.getBool('biometrics_enabled') ?? false;

      // Set initial theme
      if (isDarkTheme.value) {
        Get.changeThemeMode(ThemeMode.dark);
      } else {
        Get.changeThemeMode(ThemeMode.light);
      }
    } catch (e) {
      Get.log("Error loading profile settings: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name.value);
      await prefs.setString('profile_email', email.value);
      await prefs.setString('profile_phone', phone.value);
    } catch (e) {
      Get.log("Error saving profile: $e");
    }
  }

  void updateProfile(String newName, String newEmail, String newPhone) {
    name.value = newName;
    email.value = newEmail;
    phone.value = newPhone;
    saveProfile();
  }

  void toggleTheme() async {
    isDarkTheme.value = !isDarkTheme.value;
    Get.changeThemeMode(isDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', isDarkTheme.value);
  }

  void toggleNotifications() async {
    receiveNotifications.value = !receiveNotifications.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receive_notifications', receiveNotifications.value);
  }

  void toggleBiometrics() async {
    biometricsEnabled.value = !biometricsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', biometricsEnabled.value);
  }
}
