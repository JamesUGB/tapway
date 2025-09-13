import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:tapway/firebase_options.dart';
import 'package:tapway/routes/app_routes.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/data/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  

  // Global service injections
  Get.put(FirestoreService());
  Get.put(UserRepository());
  Get.put(AuthService());
  Get.put(LocationService());
  Get.put(AuthController(Get.find(), Get.find()));
  
  LoggerConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tapway',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.login,
      getPages: AppPages.pages,
    );
  }
}