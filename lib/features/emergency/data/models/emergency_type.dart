// lib/features/emergency/data/models/emergency_type.dart
enum EmergencyType {
  fire,
  medical,
  police, 
  naturalDisaster,
  other
}

enum EmergencyStatus {
  pending,
  assigned,
  inProgress,
  resolved,
  cancelled
}
