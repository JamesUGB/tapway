import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapway/data/services/auth_service.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart'; // <-- Add this
import 'package:tapway/routes/app_routes.dart';

class VerifyEmailNoticeScreen extends StatefulWidget {
  const VerifyEmailNoticeScreen({super.key});

  @override
  State<VerifyEmailNoticeScreen> createState() => _VerifyEmailNoticeScreenState();
}

class _VerifyEmailNoticeScreenState extends State<VerifyEmailNoticeScreen> {
  final AuthService _authService = Get.find();
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      await Get.find<AuthController>().checkAndUpdateEmailVerifiedStatus();
      final isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (isVerified && mounted) {
        Get.offAllNamed(Routes.root);
      } else {
        Get.snackbar('Not Verified', 'Please verify your email first');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check verification status');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Verification Email Sent',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkVerification,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('I\'ve Verified My Email'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _isLoading ? null : _authService.sendEmailVerification,
              child: const Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
