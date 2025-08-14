// C:\Users\Zino\Documents\tapway\lib\features\auth\presentation\screens\register.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tapway/core/utils/validator.dart';
import 'package:tapway/features/auth/logic/auth_controller.dart';
import 'package:tapway/features/auth/presentation/widgets/custom_input_field.dart';
import 'package:tapway/features/auth/presentation/widgets/otp_input.dart';
import 'package:tapway/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tapway/data/repositories/user_repository.dart';


class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Obx(() {
      return Stepper(
        currentStep: _authController.currentStep.value,
        onStepContinue: _authController.nextStep,
        onStepCancel: _authController.previousStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                if (_authController.currentStep.value > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                const SizedBox(width: 12),
                if (_authController.currentStep.value < 3)
                  Obx(() => ElevatedButton(
                    onPressed: (_authController.isLoading.value || 
                              (_authController.currentStep.value == 1 && 
                                (!_authController.isEmailAvailable.value ||
                                _authController.emailController.text.isEmpty)))
                        ? null
                        : () {
                            switch (_authController.currentStep.value) {
                              case 0:
                                if (_authController.validatePersonalInfo()) {
                                  details.onStepContinue!();
                                }
                                break;
                              case 1:
                                if (_authController.validateAccountCredentials()) {
                                  details.onStepContinue!();
                                  _authController.sendOTP();
                                }
                                break;
                              case 2:
                                _authController.verifyOTP();
                                break;
                            }
                          },
                    child: _authController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Next'),
                  )),
                if (_authController.currentStep.value == 3)
                  ElevatedButton(
                    onPressed: _authController.completeRegistration,
                    child: _authController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Complete Registration'),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Information
            Step(
              title: const Text('Personal Information'),
              content: Form(
                key: _authController.personalInfoFormKey,
                child: Column(
                  children: [
                    CustomInputField(
                      controller: _authController.firstNameController,
                      labelText: 'First Name',
                      validator: Validator.validateName,
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _authController.lastNameController,
                      labelText: 'Last Name',
                      validator: Validator.validateName,
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _authController.birthdayController,
                      labelText: 'Birthday (MM/DD/YYYY)',
                      validator: Validator.validateBirthday,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _authController.birthdayController.text =
                              DateFormat('MM/dd/yyyy').format(date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _authController.sexController.text.isEmpty
                          ? null
                          : _authController.sexController.text,
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        _authController.sexController.text = value ?? '';
                      },
                      validator: (value) =>
                          value == null ? 'Please select your sex' : null,
                    ),
                    const SizedBox(height: 16),
                    // Add this new dropdown for admin registration
                    DropdownButtonFormField<String>(
                      value: _authController.roleController.text.isEmpty
                          ? null
                          : _authController.roleController.text,
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: UserRepository.citizenRole,
                          child: Text('Citizen (Regular User)'),
                        ),
                        DropdownMenuItem(
                          value: UserRepository.fireAdminRole,
                          child: Text('Fire Department Admin'),
                        ),
                        DropdownMenuItem(
                          value: UserRepository.policeAdminRole,
                          child: Text('Police Department Admin'),
                        ),
                        DropdownMenuItem(
                          value: UserRepository.paramedicAdminRole,
                          child: Text('Paramedic Department Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        _authController.roleController.text = value ?? UserRepository.citizenRole;
                      },
                      validator: (value) =>
                          value == null ? 'Please select account type' : null,
                    ),
                  ],
                ),
              ),
            ),

            // Step 2: Government ID (optional) and Account Credentials
            Step(
              title: const Text('Account Credentials'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ExpansionTile(
                      title: const Text('Government/School ID (Optional)'),
                      children: [
                        const Text(
                            'Useful for identity verification in critical cases'),
                        const SizedBox(height: 16),
                        Obx(() => _authController.idImagePath.value.isEmpty
                            ? OutlinedButton(
                                onPressed: _pickImage,
                                child: const Text('Upload ID Image'),
                              )
                            : Column(
                                children: [
                                  Image.file(
                                    File(_authController.idImagePath.value),
                                    height: 100,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _authController.idImagePath.value = '',
                                    child: const Text('Remove Image'),
                                  ),
                                ],
                              )),
                        const SizedBox(height: 16),
                        CustomInputField(
                          controller: _authController.idNumberController,
                          labelText: 'ID Number',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _authController.accountCredentialsFormKey,
                      child: Column(
                        children: [
                          Obx(() => _authController.isEmailAvailable.value
                              ? const SizedBox()
                              : const Text(
                                  'This email is already registered',
                                  style: TextStyle(color: Colors.red),
                                )),
                          const SizedBox(height: 8),
                          CustomInputField(
                            controller: _authController.emailController,
                            labelText: 'Email',
                            validator: (value) {
                              if (value!.isEmpty &&
                                  _authController.phoneController.text.isEmpty) {
                                return 'Please provide email or phone';
                              }
                              if (value.isNotEmpty) {
                                return Validator.validateEmail(value);
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email,
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  Validator.validateEmail(value) == null) {
                                _authController.checkEmailAvailability();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _authController.phoneController,
                            labelText: 'Phone Number',
                            validator: (value) {
                              if (value!.isEmpty &&
                                  _authController.emailController.text.isEmpty) {
                                return 'Please provide email or phone';
                              }
                              if (value.isNotEmpty) {
                                return Validator.validatePhone(value);
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone,
                          ),
                          const SizedBox(height: 16),
                          Obx(() => CustomInputField(
                                controller: _authController.passwordController,
                                labelText: 'Password',
                                validator: Validator.validatePassword,
                                obscureText:
                                    !_authController.isPasswordVisible.value,
                                prefixIcon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _authController.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      _authController.togglePasswordVisibility,
                                ),
                              )),
                          const SizedBox(height: 16),
                          Obx(() => CustomInputField(
                                controller:
                                    _authController.confirmPasswordController,
                                labelText: 'Confirm Password',
                                validator: (value) =>
                                    Validator.validateConfirmPassword(
                                  value,
                                  _authController.passwordController.text,
                                ),
                                obscureText: !_authController
                                    .isConfirmPasswordVisible.value,
                                prefixIcon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _authController.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: _authController
                                      .toggleConfirmPasswordVisibility,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Step 3: OTP Verification
            Step(
              title: const Text('Verification'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We sent a verification code to your '
                    '${_authController.isEmailVerification.value ? 'email' : 'phone number'}\n'
                    '${_authController.isEmailVerification.value ? _maskEmail(_authController.emailController.text) : _maskPhone(_authController.phoneController.text)}',
                  ),
                  const SizedBox(height: 24),
                  OTPInput(
                    controller: _authController.otpController,
                    length: 6,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _authController.otpCountdown.value > 0
                      ? Text(
                          'Resend code in ${_authController.otpCountdown.value ~/ 60}:${(_authController.otpCountdown.value % 60).toString().padLeft(2, '0')}')
                      : TextButton(
                          onPressed: _authController.resendOTP,
                          child: const Text("Didn't receive the code? Send again"),
                        )),
                ],
              ),
            ),

            // Step 4: Privacy & Consent
            Step(
              title: const Text('Privacy & Consent'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please review your information:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoPreview(
                        'First Name', _authController.firstNameController.text),
                    _buildInfoPreview(
                        'Last Name', _authController.lastNameController.text),
                    _buildInfoPreview('Birthday',
                        _authController.birthdayController.text),
                    _buildInfoPreview('Sex', _authController.sexController.text),
                    if (_authController.idNumberController.text.isNotEmpty) ...[
                      _buildInfoPreview('ID Number',
                          _authController.idNumberController.text),
                    ],
                    _buildInfoPreview(
                      'Email/Phone',
                      _authController.emailController.text.isNotEmpty
                          ? _authController.emailController.text
                          : _authController.phoneController.text,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Data Usage Agreement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy. '
                      'We may use your personal information to provide and improve our services, '
                      'communicate with you, and for security purposes.',
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Obx(() => Checkbox(
                              value: _authController.consentAccepted.value,
                              onChanged: (value) {
                                _authController.consentAccepted.value =
                                    value ?? false;
                              },
                            )),
                        const Expanded(
                          child: Text(
                            'I agree to the terms and conditions and consent to the processing of my personal data',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () => Get.toNamed(Routes.login),
          child: const Text('Already have an account? Login'),
        ),
      ),
    );
  }

  Widget _buildInfoPreview(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(Get.context!).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final atIndex = email.indexOf('@');
    if (atIndex <= 3) return email;
    return email.replaceRange(3, atIndex, '******');
  }

  String _maskPhone(String phone) {
    if (phone.isEmpty || phone.length <= 6) return phone;
    return phone.replaceRange(3, phone.length - 3, '*** ***');
  }
  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    Get.find<AuthController>().idImagePath.value = pickedFile.path;
  }
}

}