// lib/features/emergency/data/models/emergency_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'emergency_type.dart'; // Import the enum definition

enum EmergencyStatus {
  active,
  resolved,
  pending,
}

class EmergencyRequest {
  final String id;
  final String userId;
  final EmergencyType type;
  final GeoPoint location;
  final String? department;
  final EmergencyStatus status;
  final DateTime createdAt;
  final String? reportedBy;
  final DateTime timestamp;
  final String? additionalInfo;

  EmergencyRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.location,
    required this.status,
    required this.createdAt,
    this.reportedBy,
    this.department,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'department': department,
      'location': location,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'reportedBy': reportedBy,
      'additionalInfo': additionalInfo,
    };
  }

  factory EmergencyRequest.fromMap(Map<String, dynamic> map) {
    return EmergencyRequest(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: EmergencyType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => EmergencyType.other,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      location: map['location'] as GeoPoint,
      department: map['department'] as String?,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EmergencyStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reportedBy: map['reportedBy'] as String?,
      additionalInfo: map['additionalInfo'] as String?,
    );
  }
}