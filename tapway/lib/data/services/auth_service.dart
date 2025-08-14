import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/data/repositories/user_repository.dart';
import 'package:tapway/routes/app_routes.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = Get.find();
  final Logger _logger = LoggerConfig.logger;

  Stream<User?> get user => _auth.authStateChanges();

  Future<bool> isEmailAvailable(String email) async {
    try {
      _logger.fine('Checking email availability for $email');
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'dummy_password',
      );
      _logger.info('Email is available: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _logger.info('Email already in use: $email');
        return false;
      }
      _logger.severe('Email check failed for $email', e);
      rethrow;
    } catch (e) {
      _logger.severe('Unexpected error checking email: $email', e);
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        _logger.fine('Sending email verification to ${user.email}');
        await user.sendEmailVerification();
        await _userRepo.updateEmailVerificationStatus(user.uid, false);
        _logger.info('Verification email sent to ${user.email}');
      } catch (e) {
        _logger.severe('Failed to send verification email to ${user.email}', e);
        rethrow;
      }
    }
  }

  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _logger.fine('Checking email verification status for ${user.email}');
        await user.reload();
        final updatedUser = _auth.currentUser;
        
        if (updatedUser != null && updatedUser.emailVerified) {
          await _userRepo.updateEmailVerificationStatus(user.uid, true);
          _logger.info('Email verified successfully for ${user.email}');
          return true;
        }
        return false;
      } catch (e) {
        _logger.severe('Failed to check verification status for ${user.email}', e);
        rethrow;
      }
    }
    return false;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
  }) async {
    try {
      _logger.info('Initiating phone number verification for $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: (e) {
          _logger.severe('Phone verification failed for $phoneNumber', e);
          verificationFailed(e);
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.warning('Verification code timeout for $phoneNumber');
        },
      );
    } catch (e) {
      _logger.severe('Phone verification error for $phoneNumber', e);
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _logger.fine('Attempting email/password sign-in for $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        if (!result.user!.emailVerified) {
          _logger.warning('Email not verified for ${result.user!.email}');
          await sendEmailVerification();
          Get.toNamed(Routes.verifyEmail);
          return null;
        }
        
        _logger.info('Sign-in successful for ${result.user!.email}');
        return result.user;
      }
      
      _logger.warning('Sign-in returned null user for $email');
      return null;
    } on FirebaseAuthException catch (e) {
      _logger.severe('Auth exception during sign-in for $email', e);
      rethrow;
    } catch (e) {
      _logger.severe('Unexpected error during sign-in for $email', e);
      rethrow;
    }
  }
  
  Future<User?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      _logger.fine('Attempting phone credential sign-in');
      final result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        _logger.info('Phone sign-in successful for ${result.user!.uid}');
        return result.user;
      }
      
      _logger.warning('Phone sign-in returned null user');
      return null;
    } catch (e) {
      _logger.severe('Phone sign-in failed', e);
      rethrow;
    }
  }

// Update the signUpWithEmailAndPassword method signature
Future<User?> signUpWithEmailAndPassword(
  String email,
  String password, {
  String? firstName,
  String? lastName,
  String? birthday,
  String? sex,
  String? phone,
  String? idNumber,
  String? idImagePath,
}) async {
  try {
    _logger.info('Attempting user registration for $email');
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user == null) {
      _logger.severe('Registration returned null user for $email');
      throw Exception('User creation failed - no user returned');
    }

    _logger.info('Sending verification email to $email');
    await result.user?.sendEmailVerification();
    
    _logger.info('User registered successfully: ${result.user!.uid}');
    return result.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      _logger.warning('Email already in use: $email', e);
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account',
      );
    }
    
    _logger.severe('Auth exception during registration for $email', e);
    rethrow;
  } catch (e) {
    _logger.severe('Unexpected error during registration for $email', e);
    rethrow;
  }
}

// Add this method if you need it (or use the existing checkEmailVerification)
Future<bool> checkEmailVerificationStatus() async {
  return await checkEmailVerification();
}

Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Sending password reset email to $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent to $email');
    } catch (e) {
      _logger.severe('Failed to send password reset email to $email', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      _logger.info('Signing out user ${user?.uid}');
      await _auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.severe('Failed to sign out', e);
      rethrow;
    }
  }
}