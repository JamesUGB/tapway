import 'package:flutter/material.dart';

/// A customizable input field with various options for form inputs.
///
/// - [controller] - Text editing controller for the input field.
/// - [labelText] - Label text displayed above the field.
/// - [validator] - Optional validation function for form submission.
/// - [obscureText] - Whether to obscure the input text (e.g. for passwords).
/// - [keyboardType] - The keyboard type to use (e.g. email, number).
/// - [prefixIcon] - Optional icon displayed at the start of the input field.
/// - [suffixIcon] - Optional widget displayed at the end of the input field.
/// - [readOnly] - Whether the input is read-only (e.g. for date pickers).
/// - [onTap] - Callback function triggered when the field is tapped.

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged; // Add this

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged, // Add this
    );
  }
}
