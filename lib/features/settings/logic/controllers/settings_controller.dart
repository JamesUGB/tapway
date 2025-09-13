import 'package:get/get.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:tapway/features/settings/data/models/settings_model.dart';
import 'package:tapway/features/settings/logic/orchestrators/settings_orchestrator.dart';
import 'package:tapway/routes/app_routes.dart';

class SettingsController extends GetxController {
  final SettingsOrchestrator _orchestrator;
  final AuthController _authController;
  final AuthService _authService;

  SettingsController(
    this._orchestrator,
    this._authController,
    this._authService,
  );

  // Reactive state for settings only
  var settings = SettingsModel(
    notificationsEnabled: true,
    darkModeEnabled: false,
    language: 'English',
  ).obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final loadedSettings = await _orchestrator.loadSettings();
      settings.value = loadedSettings;
    } catch (e) {
      LoggerConfig.logger.severe('Error loading settings', e);
      Get.snackbar('Error', 'Failed to load settings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNotificationSetting(bool value) async {
    try {
      final newSettings = settings.value.copyWith(notificationsEnabled: value);
      await _orchestrator.updateSettings(newSettings);
      settings.value = newSettings;
    } catch (e) {
      LoggerConfig.logger.severe('Error updating notification setting', e);
      Get.snackbar('Error', 'Failed to update notification setting');
      settings.refresh();
    }
  }

  Future<void> updateDarkModeSetting(bool value) async {
    try {
      final newSettings = settings.value.copyWith(darkModeEnabled: value);
      await _orchestrator.updateSettings(newSettings);
      settings.value = newSettings;
    } catch (e) {
      LoggerConfig.logger.severe('Error updating dark mode setting', e);
      Get.snackbar('Error', 'Failed to update dark mode setting');
      settings.refresh();
    }
  }

  Future<void> updateLanguageSetting(String language) async {
    try {
      final newSettings = settings.value.copyWith(language: language);
      await _orchestrator.updateSettings(newSettings);
      settings.value = newSettings;
    } catch (e) {
      LoggerConfig.logger.severe('Error updating language setting', e);
      Get.snackbar('Error', 'Failed to update language setting');
      settings.refresh();
    }
  }

  // Get user data from AuthController's text controllers
  Map<String, dynamic> get userData {
    return {
      'firstName': _authController.firstNameController.text,
      'lastName': _authController.lastNameController.text,
      'email': _authController.emailController.text,
      'phone': _authController.phoneController.text,
      // Add other fields as needed
    };
  }

  // Use AuthService's signOut method
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.red,
        // colorText: Colors.white,
      );
    }
  }
}