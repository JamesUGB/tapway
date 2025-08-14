import 'package:flutter/material.dart';
import '../../data/models/emergency_type.dart';

class EmergencyButton extends StatelessWidget {
  final EmergencyType type;
  final IconData icon;
  final String label;
  final Color color;
  final bool isPriority; // Add this new parameter
  final VoidCallback onPressed;

  const EmergencyButton({
    super.key,
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
     this.isPriority = false, // Default to false
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: isPriority 
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
            : const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isPriority ? 18 : 16,
              fontWeight: isPriority ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}