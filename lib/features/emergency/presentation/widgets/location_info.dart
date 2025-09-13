// lib/features/emergency/presentation/widgets/location_info.dart
import 'package:flutter/material.dart';

class LocationInfoWidget extends StatelessWidget {
  final String currentLocation;
  final String? userImageUrl;

  const LocationInfoWidget({
    super.key,
    required this.currentLocation,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF6C757D),
            child: userImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      userImageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          // Location Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your current Location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentLocation,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF212529),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}