import 'package:get/get.dart';
import 'package:tapway/features/emergency/logic/emergency_controller.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/data/services/location_service.dart';

class EmergencyBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily inject dependencies only when EmergencyScreen is navigated to
    Get.lazyPut<EmergencyController>(() => 
      EmergencyController(
        Get.find<FirestoreService>(), 
        Get.find<LocationService>(),
      )
    );
  }
}
