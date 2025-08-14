// C:\Users\Zino\Documents\tapway\lib\features\auth\presentation\widgets\login_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:tapway/core/utils/validator.dart';
import 'package:tapway/features/auth/presentation/widgets/custom_input_field.dart';

class LoginForm extends StatelessWidget {
  final AuthController authController;

  const LoginForm({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: authController.loginFormKey, // Use the specific login form key
      child: Column(
        children: [
          CustomInputField(
            controller: authController.emailController,
            labelText: 'Email',
            validator: Validator.validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: 20),
          Obx(() => CustomInputField(
            controller: authController.passwordController,
            labelText: 'Password',
            validator: Validator.validatePassword,
            obscureText: !authController.isPasswordVisible.value,
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                authController.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
          )),
          const SizedBox(height: 30),
          Obx(() => ElevatedButton(
            onPressed: authController.isLoading.value
                ? null
                : () => authController.login(), // Call login method
            child: authController.isLoading.value
                ? const CircularProgressIndicator()
                : const Text('Login'),
          )),
        ],
      ),
    );
  }
}