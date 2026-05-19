import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Card Info
            _buildProfileCard(context),
            const SizedBox(height: 32),

            // Settings Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // Settings List
            _buildSettingsList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with edit pen
          Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('Income & Expense Tracker App (Community)/Profile6.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Phone
          Obx(() => Text(
                profileController.name.value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                profileController.email.value,
                style: TextStyle(
                  fontSize: 13,
                  color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              )),
          const SizedBox(height: 20),

          // Profile edit info button
          ElevatedButton(
            onPressed: () => _showEditProfileDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit Profile', style: TextStyle(fontSize: 14)),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Theme selection item
          Obx(() => _buildSwitchRow(
                context,
                title: 'Dark Theme',
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.purple,
                value: profileController.isDarkTheme.value,
                onChanged: (val) => profileController.toggleTheme(),
              )),
          _buildDivider(),

          // Notification settings item
          Obx(() => _buildSwitchRow(
                context,
                title: 'Receive Notifications',
                icon: Icons.notifications_active_outlined,
                iconColor: Colors.blue,
                value: profileController.receiveNotifications.value,
                onChanged: (val) => profileController.toggleNotifications(),
              )),
          _buildDivider(),

          // Biometrics settings item
          Obx(() => _buildSwitchRow(
                context,
                title: 'Fingerprint Lock',
                icon: Icons.fingerprint_rounded,
                iconColor: Colors.green,
                value: profileController.biometricsEnabled.value,
                onChanged: (val) => profileController.toggleBiometrics(),
              )),
          _buildDivider(),

          // Export files
          _buildActionRow(
            context,
            title: 'Export Transactions',
            desc: 'Export records to PDF/Excel format',
            icon: Icons.cloud_download_outlined,
            iconColor: Colors.orange,
            onTap: () {
              Get.snackbar(
                'Exporting',
                'Your transaction history has been exported as a PDF file.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.incomeColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
          _buildDivider(),

          // Support community
          _buildActionRow(
            context,
            title: 'Community Help',
            desc: 'Get support or contact our core team',
            icon: Icons.people_outline_rounded,
            iconColor: Colors.indigo,
            onTap: () {
              Get.snackbar('Support', 'Connecting you with the community forum...');
            },
          ),
          _buildDivider(),

          // Sign out
          _buildActionRow(
            context,
            title: 'Sign Out',
            icon: Icons.logout_rounded,
            iconColor: AppTheme.expenseColor,
            onTap: () {
              // Sign out logic (goes to onboarding)
              Get.offAllNamed('/onboarding');
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context,
      {required String title,
      required IconData icon,
      required Color iconColor,
      required bool value,
      required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context,
      {required String title,
      String? desc,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap,
      bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDestructive ? AppTheme.expenseColor : null,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    )
                  ]
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Get.isDarkMode ? Colors.white10 : Colors.black12,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameField = TextEditingController(text: profileController.name.value);
    final emailField = TextEditingController(text: profileController.email.value);
    final phoneField = TextEditingController(text: profileController.phone.value);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Personal Profile'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameField,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailField,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneField,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              profileController.updateProfile(
                nameField.text.trim(),
                emailField.text.trim(),
                phoneField.text.trim(),
              );
              Get.back();
              Get.snackbar(
                'Success',
                'Profile updated successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.incomeColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
