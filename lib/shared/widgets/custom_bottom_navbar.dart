// lib/features/emergency/presentation/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: FontAwesomeIcons.message,
                label: 'Messages',
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: FontAwesomeIcons.house,
                label: 'Emergency',
                isSelected: currentIndex == 1,
                isEmergency: true,
              ),
              _buildNavItem(
                index: 2,
                icon: FontAwesomeIcons.bars,
                label: 'Settings',
                isSelected: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isEmergency = false,
  }) {
    // Colors similar to Facebook Messenger
    final primaryBlue = Color(0xFF0084FF);
    final emergencyRed = Color(0xFFFF3040);
    final inactiveGray = Color(0xFF65676B);

    // Use filled/solid icons for active state, outline for inactive
    IconData displayIcon;
    switch (icon) {
      case FontAwesomeIcons.message:
        displayIcon = isSelected ? FontAwesomeIcons.solidMessage : FontAwesomeIcons.message;
        break;
      case FontAwesomeIcons.house:
        displayIcon = isSelected ? FontAwesomeIcons.house : FontAwesomeIcons.house;
        break;
      case FontAwesomeIcons.bars:
        displayIcon = isSelected ? FontAwesomeIcons.bars : FontAwesomeIcons.bars;
        break;
      default:
        displayIcon = icon;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon without background - just the filled/outline state
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: FaIcon(
                    displayIcon,
                    size: 24,
                    color: isSelected 
                        ? (isEmergency ? emergencyRed : primaryBlue)
                        : inactiveGray,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? (isEmergency ? emergencyRed : primaryBlue)
                      : inactiveGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}