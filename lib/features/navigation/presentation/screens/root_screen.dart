// C:\Users\Zino\Documents\tapway\lib\features\navigation\presentation\screens\root_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/shared/widgets/custom_app_bar.dart';
import 'package:tapway/shared/widgets/custom_bottom_navbar.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/data/services/location_service.dart';

// Import your tab screens
import 'package:tapway/features/messages/presentation/screens/messages_screen.dart';
import 'package:tapway/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:tapway/features/settings/presentation/screens/settings_screen.dart';

// Import controllers and their dependencies
import 'package:tapway/features/messages/logic/controllers/message_controller.dart';
import 'package:tapway/features/messages/data/repositories/message_repository.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/features/emergency/logic/emergency_controller.dart';
import 'package:tapway/features/settings/logic/controllers/settings_controller.dart';
import 'package:tapway/features/settings/logic/orchestrators/settings_orchestrator.dart';
import 'package:tapway/features/settings/data/repositories/settings_repository.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootScreen extends StatefulWidget {
  final int initialIndex;
  
  const RootScreen({super.key, this.initialIndex = 1});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with AutomaticKeepAliveClientMixin {
  late int _currentIndex;
  final PageStorageBucket _bucket = PageStorageBucket();
  bool _controllersInitialized = false;

  final List<Widget> _pages = [
    const MessagesScreen(key: PageStorageKey('messages')),
    const EmergencyScreen(key: PageStorageKey('emergency')),
    const SettingsScreen(key: PageStorageKey('settings')),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeControllers();
  }

  void _initializeControllers() {
    // Check if controllers are already initialized
    if (_controllersInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Initialize core services if not already registered
        if (!Get.isRegistered<FirestoreService>()) {
          Get.put(FirestoreService());
        }
        
        if (!Get.isRegistered<AuthService>()) {
          Get.put(AuthService());
        }
        
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController(
            Get.find<AuthService>(),
            Get.find<UserRepository>(),
          ));
        }

        // Initialize Messages Controller
        if (!Get.isRegistered<MessageController>()) {
          final messageRepository = MessageRepository(Get.find<FirestoreService>());
          Get.put(MessageController(messageRepository), permanent: true);
        }

        // Initialize Emergency Controller
        if (!Get.isRegistered<EmergencyController>()) {
          Get.put(EmergencyController(
            Get.find<FirestoreService>(),
            Get.find<LocationService>(),
          ), permanent: true);
        }

        // Initialize Settings Controller and its dependencies
        if (!Get.isRegistered<SettingsController>()) {
          // First initialize SettingsRepository
          if (!Get.isRegistered<SettingsRepository>()) {
            final settingsRepository = SettingsRepository(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            );
            Get.put(settingsRepository, permanent: true);
          }

          // Then initialize SettingsOrchestrator
          if (!Get.isRegistered<SettingsOrchestrator>()) {
            final settingsOrchestrator = SettingsOrchestrator(Get.find<SettingsRepository>());
            Get.put(settingsOrchestrator, permanent: true);
          }

          // Finally initialize SettingsController
          final settingsController = SettingsController(
            Get.find<SettingsOrchestrator>(),
            Get.find<AuthController>(),
            Get.find<AuthService>(),
          );
          Get.put(settingsController, permanent: true);
        }

        _controllersInitialized = true;
        if (mounted) {
          setState(() {}); // Rebuild to show content instead of loading
        }
      } catch (e) {
        // Handle initialization errors
        print('Error initializing controllers: $e');
      }
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Show loading indicator until controllers are initialized
    if (!_controllersInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(currentIndex: _currentIndex),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}