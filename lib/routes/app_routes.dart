// C:\Users\Zino\Documents\tapway\lib\routes\app_routes.dart
import 'package:get/get.dart';
import 'package:tapway/features/auth/presentation/screens/forgot_password.dart';
import 'package:tapway/features/auth/presentation/screens/login.dart';
import 'package:tapway/features/auth/presentation/screens/register.dart';
import 'package:tapway/features/auth/presentation/screens/reset_password_success.dart';
import 'package:tapway/features/auth/presentation/screens/verify_email_notice.dart';
// import 'package:tapway/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:tapway/features/emergency/presentation/screens/location_screen.dart'; 
import 'package:tapway/features/emergency/logic/bindings/emergency_binding.dart';
// import 'package:tapway/features/settings/presentation/screens/settings_screen.dart';
import 'package:tapway/features/settings/logic/bindings/settings_binding.dart';
import 'package:tapway/routes/auth_middleware.dart';

// Import the RootScreen
import 'package:tapway/features/navigation/presentation/screens/root_screen.dart';

abstract class Routes {
  // Public routes
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordSuccess = '/reset-password-success';
  
  // Root navigation route (main app screen with tabs)
  static const root = '/';
  
  // Individual tab routes for deep linking
  static const emergency = '/emergency';
  static const location = '/location';
  static const settings = '/settings';
  static const messages = '/messages';
}

abstract class AppPages {
  static final pages = [
    // Public pages
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: Routes.verifyEmail,
      page: () => VerifyEmailNoticeScreen(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.resetPasswordSuccess,
      page: () => ResetPasswordSuccessScreen(),
    ),
    
    // Root navigation screen (main app with tabs) - set as home
    GetPage(
      name: Routes.root,
      page: () => const RootScreen(),
      middlewares: [AuthMiddleware()],
    ),
    
    // Individual tab routes for deep linking
    GetPage(
      name: Routes.emergency,
      page: () => const RootScreen(initialIndex: 1),
      middlewares: [AuthMiddleware()],
      binding: EmergencyBinding(),
    ),
    GetPage(
      name: Routes.messages,
      page: () => const RootScreen(initialIndex: 0),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const RootScreen(initialIndex: 2),
      middlewares: [AuthMiddleware()],
      binding: SettingsBinding(),
    ),
    
    // Other individual pages
    GetPage(
      name: Routes.location,
      page: () => const LocationScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}