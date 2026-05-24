import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_theme.dart';
import '../home/home_tab.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed top section (header wave + avatar + name/handle)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Curved Header Background
              ClipPath(
                clipper: ProfileHeaderWaveClipper(),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative rings
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        top: -10,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 16,
                            ),
                          ),
                        ),
                      ),
                      // App Bar row
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          statusBarHeight + 10,
                          16,
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                try {
                                  Get.find<NavigationController>().changeTab(0);
                                } catch (e) {
                                  Get.back();
                                }
                              },
                            ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Notification Icon inside translucent box
                            GestureDetector(
                              onTap: () {
                                Get.snackbar(
                                  'Notifications',
                                  'No new notifications.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_none_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    Positioned(
                                      right: 11,
                                      top: 11,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFC33A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Overlapping Avatar
              Positioned(
                bottom: -20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: Image.asset(
                        'assets/cropped/profile_icon.png',
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Name and Handle
          Obx(() {
            final nameVal = profileController.name.value;
            final handle = '@${nameVal.toLowerCase().replaceAll(' ', '_')}';
            return Column(
              children: [
                Text(
                  nameVal,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  handle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2F7E79),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 4),

          // Scrollable bottom section (menu options)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Menu Options Container
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Invite Friends
                          _buildInviteFriendsRow(context),

                          _buildDivider(),

                          // Account info
                          _buildMenuRow(
                            context,
                            title: 'Account info',
                            icon: Icons.person_outline_rounded,
                            onTap: () => _showEditProfileDialog(context),
                          ),

                          // Personal profile
                          _buildMenuRow(
                            context,
                            title: 'Personal profile',
                            icon: Icons.people_outline_rounded,
                            onTap: () => _showPersonalProfileSheet(context),
                          ),

                          // Message center
                          _buildMenuRow(
                            context,
                            title: 'Message center',
                            icon: Icons.mail_outline_rounded,
                            onTap: () {
                              Get.snackbar(
                                'Message Center',
                                'Inbox is currently empty.',
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                            },
                          ),

                          // Login and security
                          _buildMenuRow(
                            context,
                            title: 'Login and security',
                            icon: Icons.shield_outlined,
                            onTap: () => _showSecuritySheet(context),
                          ),

                          // Data and privacy
                          _buildMenuRow(
                            context,
                            title: 'Data and privacy',
                            icon: Icons.lock_outline_rounded,
                            onTap: () => _showDataPrivacySheet(context),
                          ),

                          // Sign Out
                          _buildMenuRow(
                            context,
                            title: 'Sign Out',
                            icon: Icons.logout_rounded,
                            iconColor: AppTheme.expenseColor,
                            textColor: AppTheme.expenseColor,
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to sign out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.find<AuthController>().signOut();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.expenseColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // safety spacing
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsRow(BuildContext context) {
    final isDark = Get.isDarkMode;
    return InkWell(
      onTap: () {
        Get.snackbar(
          'Invite Friends',
          'Referral link copied to clipboard!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2F7E79),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      },
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2F1), // light green-teal background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond_rounded,
                color: Color(0xFF2F7E79), // teal gem icon
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Invite Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF222222),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDark = Get.isDarkMode;
    final defaultIconColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final defaultTextColor = isDark ? Colors.white : const Color(0xFF222222);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? defaultIconColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? defaultTextColor,
                ),
              ),
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

  void _showPersonalProfileSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildSwitchRow(
                context,
                title: 'Dark Theme',
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.purple,
                value: profileController.isDarkTheme.value,
                onChanged: (val) => profileController.toggleTheme(),
              ),
            ),
            _buildDivider(),
            Obx(
              () => _buildSwitchRow(
                context,
                title: 'Receive Notifications',
                icon: Icons.notifications_active_outlined,
                iconColor: Colors.blue,
                value: profileController.receiveNotifications.value,
                onChanged: (val) => profileController.toggleNotifications(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSecuritySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildSwitchRow(
                context,
                title: 'Fingerprint Lock',
                icon: Icons.fingerprint_rounded,
                iconColor: Colors.green,
                value: profileController.biometricsEnabled.value,
                onChanged: (val) => profileController.toggleBiometrics(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDataPrivacySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data & Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionRow(
              context,
              title: 'Export Transactions',
              desc: 'Export records to PDF/Excel format',
              icon: Icons.cloud_download_outlined,
              iconColor: Colors.orange,
              onTap: () {
                Get.back(); // close sheet
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF222222),
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
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
                      color: isDark ? Colors.white : const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameField = TextEditingController(text: profileController.name.value);
    final emailField = TextEditingController(
      text: profileController.email.value,
    );
    final phoneField = TextEditingController(
      text: profileController.phone.value,
    );
    final isDark = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Edit Account Info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF222222),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameField,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailField,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneField,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.expenseColor),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width / 2, size.height + 15);
    final firstEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
