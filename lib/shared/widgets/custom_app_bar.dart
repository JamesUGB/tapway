// lib/shared/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  
  const CustomAppBar({super.key, required this.currentIndex});

  String _getTitle() {
    switch (currentIndex) {
      case 0:
        return 'Messages';
      case 1:
        return 'Tapway';
      case 2:
        return 'Settings';
      default:
        return 'Tapway';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove default back button
      elevation: 0,
      backgroundColor: const Color(0xFFF5F5F5),
      foregroundColor: const Color(0xFF212529),
      flexibleSpace: SafeArea(
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title on the left
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF212529),
                ),
              ),
              // Icon button on the right
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 20,
                ),
                tooltip: 'Location',
                onPressed: () {
                  Get.toNamed(Routes.location);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}