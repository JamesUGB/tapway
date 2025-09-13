// lib/features/emergency/data/models/emergency_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tapway/features/emergency/data/models/emergency_type.dart';

class LocationData {
  final GeoPoint coordinates;
  final double accuracy;
  final String? street;
  final String? barangay;
  final String? city;
  final String? province;
  final String? landmark;
  final String? formattedAddress;

  LocationData({
    required this.coordinates,
    required this.accuracy,
    this.street,
    this.barangay,
    this.city,
    this.province,
    this.landmark,
    this.formattedAddress,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      coordinates: GeoPoint(map['coordinates']['lat'], map['coordinates']['lng']),
      accuracy: map['accuracy'] ?? 0.0,
      street: map['street'],
      barangay: map['barangay'],
      city: map['city'],
      province: map['province'],
      landmark: map['landmark'],
      formattedAddress: map['formattedAddress'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
      'accuracy': accuracy,
      'street': street,
      'barangay': barangay,
      'city': city,
      'province': province,
      'landmark': landmark,
      'formattedAddress': formattedAddress,
    };
  }
}

class Emergency {
  final String id;
  final String userId;
  final EmergencyType type;
  final String department;
  final EmergencyStatus status;
  final LocationData location;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? imageUrls;
  final List<Map<String, dynamic>> statusHistory;
  final List<Map<String, dynamic>> assignedResponders;
  final List<Map<String, dynamic>> responseNotes;
  final Map<String, dynamic> verification;

  Emergency({
    required this.id,
    required this.userId,
    required this.type,
    required this.department,
    required this.status,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.imageUrls,
    required this.statusHistory,
    required this.assignedResponders,
    required this.responseNotes,
    required this.verification,
  });

  factory Emergency.fromMap(Map<String, dynamic> map) {
    return Emergency(
      id: map['id'],
      userId: map['userId'],
      type: EmergencyType.values.firstWhere(
        (e) => e.toString().split('.').last == map['emergencyType'],
        orElse: () => EmergencyType.other,
      ),
      department: map['department'],
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EmergencyStatus.pending,
      ),
      location: LocationData.fromMap(map['location']),
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      imageUrls: List<String>.from(map['media']['images'] ?? []),
      statusHistory: List<Map<String, dynamic>>.from(map['statusHistory'] ?? []),
      assignedResponders: List<Map<String, dynamic>>.from(map['assignedResponders'] ?? []),
      responseNotes: List<Map<String, dynamic>>.from(map['responseNotes'] ?? []),
      verification: Map<String, dynamic>.from(map['verification'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'emergencyType': type.toString().split('.').last,
      'department': department,
      'status': status.toString().split('.').last,
      'location': location.toMap(),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'media': {
        'images': imageUrls ?? [],
      },
      'statusHistory': statusHistory,
      'assignedResponders': assignedResponders,
      'responseNotes': responseNotes,
      'verification': verification,
    };
  }
}