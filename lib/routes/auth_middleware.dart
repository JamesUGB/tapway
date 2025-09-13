// C:\Users\Zino\Documents\tapway\lib\routes\auth_middleware.dart
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}