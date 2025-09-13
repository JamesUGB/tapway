// otp_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatelessWidget {
  final TextEditingController controller;
  final int length;

  const OTPInput({
    super.key,
    required this.controller,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(length),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          counterText: '',
          hintText: '0 0 0 0 0 0',
          hintStyle: const TextStyle(
            letterSpacing: 24,
            fontSize: 24,
          ),
        ),
        style: const TextStyle(
          letterSpacing: 24,
          fontSize: 24,
        ),
        maxLength: length,
        onChanged: (value) {
          if (value.length == length) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }
}