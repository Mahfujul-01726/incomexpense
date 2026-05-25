import 'package:get/get.dart';
import '../../services/preferences_service.dart';

class ProfileController extends GetxController {
  final PreferencesService _prefsService = Get.find<PreferencesService>();

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
      name.value = await _prefsService.loadProfileName();
      email.value = await _prefsService.loadProfileEmail();
      phone.value = await _prefsService.loadProfilePhone();
      receiveNotifications.value = await _prefsService.loadReceiveNotifications();
      biometricsEnabled.value = await _prefsService.loadBiometricsEnabled();
    } catch (e) {
      Get.log("Error loading profile settings: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      await _prefsService.saveProfile(name.value, email.value, phone.value);
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

  Future<void> toggleNotifications() async {
    receiveNotifications.value = !receiveNotifications.value;
    await _prefsService.setReceiveNotifications(receiveNotifications.value);
  }

  Future<void> toggleBiometrics() async {
    biometricsEnabled.value = !biometricsEnabled.value;
    await _prefsService.setBiometricsEnabled(biometricsEnabled.value);
  }
}
