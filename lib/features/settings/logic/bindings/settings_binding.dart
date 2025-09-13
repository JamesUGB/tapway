import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:tapway/features/settings/data/repositories/settings_repository.dart';
import 'package:tapway/features/settings/logic/controllers/settings_controller.dart';
import 'package:tapway/features/settings/logic/orchestrators/settings_orchestrator.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsRepository(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ));
    Get.lazyPut(() => SettingsOrchestrator(Get.find<SettingsRepository>()));
    Get.lazyPut(() => SettingsController(
          Get.find<SettingsOrchestrator>(),
          Get.find<AuthController>(),
          Get.find<AuthService>(),
        ));
  }
}