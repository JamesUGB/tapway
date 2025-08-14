// lib/features/profile/logic/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/core/utils/logger_config.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      await _userRepository.updateUserData(updatedData);
      LoggerConfig.logger.info('User profile updated successfully.'); // optional success log
    } catch (e, stackTrace) {
      LoggerConfig.logger.severe(
        'Error updating profile',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
