// lib/routes/app_routes.dart
import 'package:get/get.dart';
// import 'package:tapway/features/admin/presentation/screens/admin_dashboard.dart';
// import 'package:tapway/features/admin/presentation/screens/admin_login.dart';
// import 'package:tapway/features/admin/presentation/screens/admin_user_management.dart';
import 'package:tapway/features/auth/presentation/screens/forgot_password.dart';
import 'package:tapway/features/auth/presentation/screens/login.dart';
import 'package:tapway/features/auth/presentation/screens/register.dart';
import 'package:tapway/features/auth/presentation/screens/reset_password_success.dart';
import 'package:tapway/features/auth/presentation/screens/verify_email_notice.dart';
import 'package:tapway/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:tapway/features/emergency/logic/bindings/emergency_binding.dart';
import 'package:tapway/features/settings/presentation/screens/settings_screen.dart';
import 'package:tapway/routes/auth_middleware.dart';
// import 'package:tapway/routes/admin_middleware.dart';
// import 'package:tapway/features/admin/logic/bindings/admin_binding.dart';

abstract class Routes {
  // Public routes
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordSuccess = '/reset-password-success';
  
  // User routes
  static const home = '/home';
  static const emergency = '/emergency';
  static const settings = '/settings';
  
  // // Admin routes
  // static const adminLogin = '/admin/login';
  // static const adminDashboard = '/admin/dashboard';
  // static const adminUserManagement = '/admin/users';
  // static const adminEmergencies = '/admin/emergencies';
  // static const adminReports = '/admin/reports';
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
    
    // User pages
    GetPage(
      name: Routes.emergency,
      page: () => const EmergencyScreen(),
      transition: Transition.fadeIn,
      binding: EmergencyBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    
    // // Admin pages
    // GetPage(
    //   name: Routes.adminLogin,
    //   page: () => AdminLoginScreen(),
    // ),
    // GetPage(
    //   name: Routes.adminDashboard,
    //   page: () => AdminDashboard(),
    //   binding: AdminBinding(),
    //   middlewares: [AdminMiddleware()],
    //   transition: Transition.fade,
    // ),
    // GetPage(
    //   name: Routes.adminUserManagement,
    //   page: () => AdminUserManagement(),
    //   middlewares: [AdminMiddleware()],
    // ),
    // GetPage(
    //   name: Routes.adminEmergencies,
    //   page: () => AdminEmergenciesView(),
    //   binding: AdminBinding(),
    //   middlewares: [AdminMiddleware()],
    // ),
    // GetPage(
    //   name: Routes.adminReports,
    //   page: () => AdminReportsView(),
    //   binding: AdminBinding(),
    //   middlewares: [AdminMiddleware()],
    // ),
  ];
}