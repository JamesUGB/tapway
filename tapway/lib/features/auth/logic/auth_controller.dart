//C:\Users\Zino\Documents\tapway\lib\features\auth\logic\auth_controller.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/routes/app_routes.dart';
import 'package:tapway/core/utils/validator.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final UserRepository _userRepo;

  // Form keys
  final personalInfoFormKey = GlobalKey<FormState>();
  final accountCredentialsFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final sexController = TextEditingController();
  final idNumberController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final roleController = TextEditingController(text: UserRepository.citizenRole);

  // Observables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final currentStep = 0.obs;
  final isEmailVerification = true.obs;
  final consentAccepted = false.obs;
  final otpSent = false.obs;
  final otpCountdown = 300.obs;
  final isEmailAvailable = true.obs;
  final idImagePath = ''.obs;

  String? _verificationId;
  Timer? _otpTimer;

  AuthController(this._authService, this._userRepo);

  // Step navigation
  void nextStep() => currentStep.value < 3 ? currentStep.value++ : null;
  void previousStep() => currentStep.value > 0 ? currentStep.value-- : null;

  // Toggle visibility
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // Validation
  bool validatePersonalInfo() {
    if (!personalInfoFormKey.currentState!.validate()) return false;
    
    try {
      final birthday = DateFormat('MM/dd/yyyy').parse(birthdayController.text);
      final age = DateTime.now().difference(birthday).inDays ~/ 365;
      if (age < 16) {
        Get.snackbar('Error', 'You must be at least 16 years old to register');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid date format');
      return false;
    }
    
    return true;
  }

  bool validateAccountCredentials() {
    if (!accountCredentialsFormKey.currentState!.validate()) return false;
    
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }
    
    if (emailController.text.isEmpty && phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please provide either email or phone number');
      return false;
    }
    
    return true;
  }

  Future<void> checkEmailAvailability() async {
    final email = emailController.text.trim();
    if (email.isEmpty || Validator.validateEmail(email) != null) return;
    
    isLoading.value = true;
    try {
      isEmailAvailable.value = await _authService.isEmailAvailable(email);
      if (!isEmailAvailable.value) {
        Get.snackbar('Error', 'This email is already registered');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check email availability');
    } finally {
      isLoading.value = false;
    }
  }

// OTP Operations
Future<void> sendOTP() async {
  isLoading.value = true;
  try {
    if (emailController.text.isNotEmpty) {
      isEmailVerification.value = true;
      
      // First create the user (this will include verification inside signUpWithEmailAndPassword)
      await _authService.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        birthday: birthdayController.text,
        sex: sexController.text,
        phone: phoneController.text,
        idNumber: idNumberController.text,
        idImagePath: idImagePath.value,
      );
      
      otpSent.value = true;
      startOTPTimer();
    } else if (phoneController.text.isNotEmpty) {
      isEmailVerification.value = false;
      await _authService.verifyPhoneNumber(
        phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _authService.signInWithPhoneCredential(credential);
          otpSent.value = true;
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          otpSent.value = true;
          startOTPTimer();
        },
      );
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}');
  } finally {
    isLoading.value = false;
  }
}
  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      if (isEmailVerification.value) {
        // For email verification, we might want to verify the OTP with the backend
        // Currently just proceeding to next step as placeholder
        nextStep();
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpController.text,
        );
        await _authService.signInWithPhoneCredential(credential);
        nextStep();
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP. Please try again');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> checkAndUpdateEmailVerifiedStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Refresh user info
    final updatedUser = FirebaseAuth.instance.currentUser;

    if (updatedUser != null && updatedUser.emailVerified) {
      await _userRepo.updateEmailVerificationStatus(updatedUser.uid, true);
    }
  }

  // Registration
  Future<void> completeRegistration() async {
    if (!consentAccepted.value) {
      Get.snackbar('Error', 'You must accept the terms and conditions');
      return;
    }

    isLoading.value = true;
    try {
      User? user;
      if (emailController.text.isNotEmpty) {
        user = await _authService.signUpWithEmailAndPassword(
          emailController.text,
          passwordController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          birthday: birthdayController.text,
          sex: sexController.text,
          phone: phoneController.text,
          idNumber: idNumberController.text,
          idImagePath: idImagePath.value,
        );

        if (user != null) {
          await _userRepo.createUserProfile(
            uid: user.uid,
            email: emailController.text,
            phone: phoneController.text,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            birthday: birthdayController.text,
            sex: sexController.text,
            idNumber: idNumberController.text,
            idImagePath: idImagePath.value,
            role: roleController.text,
          );
          
          // Redirect to verification screen
          Get.offAllNamed(Routes.verifyEmail);
        }
      } else {
        throw Exception('Phone-only registration not implemented');
      }
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Authentication
Future<void> login() async {
  if (!loginFormKey.currentState!.validate()) return;

  isLoading.value = true;
  try {
    final user = await _authService.signInWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      final isVerified = await _authService.checkEmailVerificationStatus();
      if (!isVerified) {
        Get.offAllNamed(Routes.verifyEmail);
      } else {
        // Skip role check, redirect all users to emergency page
        Get.offAllNamed(Routes.emergency);
      }
    }
  } on FirebaseAuthException catch (e) {
    Get.snackbar('Login Failed', e.message ?? 'An error occurred');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> resetPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    if (Validator.validateEmail(email) != null) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset email sent');
      Get.offAllNamed(Routes.resetPasswordSuccess);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to send reset email');
    } finally {
      isLoading.value = false;
    }
  }

  // Timer Management
  void startOTPTimer() {
    _otpTimer?.cancel();
    otpCountdown.value = 300;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCountdown.value > 0) {
        otpCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void resendOTP() {
    otpCountdown.value = 300;
    otpController.clear();
    sendOTP();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthdayController.dispose();
    sexController.dispose();
    idNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    _otpTimer?.cancel();
    roleController.dispose();
    super.onClose();
  }
}