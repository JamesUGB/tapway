// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:tapway/core/themes/app_colors.dart';
import 'package:tapway/features/profile/presentation/screens/edit_profile.dart';
import 'package:tapway/features/settings/logic/controllers/settings_controller.dart';
import 'package:tapway/features/settings/presentation/widgets/language_dialog.dart';
import 'package:tapway/features/settings/presentation/widgets/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> 
    with AutomaticKeepAliveClientMixin {
  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final userData = controller.userData;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildSectionHeader('User Profile'),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      '${userData['firstName']} ${userData['lastName']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(userData['email'] ?? 'N/A'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _navigateToEditProfile,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: Text(userData['phone'] ?? 'Not provided'),
                    onTap: _navigateToEditProfile,
                  ),
                ],
              ),
            ),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            SettingsSection(
              children: [
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Enable/disable app notifications'),
                  value: controller.settings.value.notificationsEnabled,
                  onChanged: controller.updateNotificationSetting,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  value: controller.settings.value.darkModeEnabled,
                  onChanged: controller.updateDarkModeSetting,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(controller.settings.value.language),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageSelectionDialog(context),
                ),
              ],
            ),

            // Account Section
            _buildSectionHeader('Account'),
            SettingsSection(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Change Password'),
                  onTap: () {
                    Get.toNamed('/forgot-password');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
              ],
            ),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: controller.logout,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212529),
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LanguageDialog(
        currentLanguage: controller.settings.value.language,
        onLanguageSelected: controller.updateLanguageSetting,
      ),
    );
  }

  void _navigateToEditProfile() {
    final userData = controller.userData;
    if (userData.isNotEmpty) {
      Get.to(() => const EditProfileScreen(), arguments: userData);
    }
  }

  @override
  bool get wantKeepAlive => true;
}