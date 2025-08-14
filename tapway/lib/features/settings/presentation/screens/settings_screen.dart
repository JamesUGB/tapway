// C:\Users\Zino\Documents\tapway\lib\features\settings\presentation\screens\settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/core/themes/app_colors.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/features/profile/presentation/screens/edit_profile.dart';
import 'package:tapway/routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository _userRepository = Get.find<UserRepository>();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  // Settings toggles
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await _userRepository.getCurrentUserData();

      if (userDoc == null || !userDoc.exists) {
        Get.offAllNamed(Routes.login);
        return;
      }

      setState(() {
        userData = userDoc.data();
        isLoading = false;
      });
    } catch (e) {
      LoggerConfig.logger.severe('Error fetching user data', e);
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      LoggerConfig.logger.severe('Error during logout', e);
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToEditProfile() {
    if (userData != null) {
      Get.to(() => const EditProfileScreen(), arguments: userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                      '${userData?['firstName']} ${userData?['lastName']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(userData?['email'] ?? 'N/A'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _navigateToEditProfile,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: Text(userData?['phone'] ?? 'Not provided'),
                    onTap: _navigateToEditProfile,
                  ),
                ],
              ),
            ),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable/disable app notifications'),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    value: darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        darkModeEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showLanguageSelectionDialog();
                    },
                  ),
                ],
              ),
            ),

            // Account Section
            _buildSectionHeader('Account'),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Change Password'),
                    onTap: () {
                      Get.toNamed(Routes.forgotPassword);
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
            ),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _logout,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    final languages = ['English', 'Spanish', 'French', 'German'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(languages[index]),
                value: languages[index],
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value.toString();
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}