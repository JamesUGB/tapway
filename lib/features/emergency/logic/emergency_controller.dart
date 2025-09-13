// lib/features/emergency/logic/emergency_controller.dart
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/data/services/location_service.dart';
import 'package:tapway/features/emergency/data/models/emergency.dart';

class EmergencyController {
  final FirestoreService _firestoreService;
  final LocationService _locationService;
  final Random _random = Random();

  EmergencyController(this._firestoreService, this._locationService);

Future<Emergency> createEmergency({
  required EmergencyType type,
  String? description,
  List<File>? mediaFiles,
}) async {
  final user = FirebaseAuth.instance.currentUser!;
  final position = await _locationService.getCurrentLocation();
  
  final address = await _locationService.getAddressFromCoordinates(
    position.latitude,
    position.longitude,
  );

  List<String> mediaUrls = [];
  if (mediaFiles != null && mediaFiles.isNotEmpty) {
    mediaUrls = await _firestoreService.uploadEmergencyMedia(
      emergencyId: _generateEmergencyId(),
      files: mediaFiles,
    );
  }

  final emergency = Emergency(
    id: _generateEmergencyId(),
    userId: user.uid,
    type: type,
    department: _getDepartmentForEmergencyType(type),
    status: EmergencyStatus.pending,
    location: LocationData(
      coordinates: GeoPoint(position.latitude, position.longitude),
      accuracy: position.accuracy,
      street: address['street'],
      barangay: address['barangay'],
      city: address['city'],
      province: address['province'],
      landmark: address['landmark'],
      formattedAddress: address['formattedAddress'],
    ),
    description: description,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrls: mediaUrls,
    statusHistory: [
      {
        'status': 'pending',
        'timestamp': DateTime.now(),
        'changedBy': 'system',
      }
    ],
    assignedResponders: [],
    responseNotes: [],
    verification: {
      'userVerified': true,
      'deviceVerified': true,
      'locationVerified': position.accuracy < 50,
      'prankScore': 0,
    },
  );

  await _firestoreService.createEmergency(emergency);
  return emergency;
}

  String _generateEmergencyId() {
    return 'emg-${DateTime.now().millisecondsSinceEpoch}-${_randomString(6)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
    ));
  }

  String _getDepartmentForEmergencyType(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'MDDRMO';
      case EmergencyType.fire:
        return 'BFP';
      case EmergencyType.police:
        return 'PNP';
      case EmergencyType.naturalDisaster:
        return 'OCD';
      default:
        return 'MDRRMO';
    }
  }

  Future<void> updateEmergencyStatus({
    required String emergencyId,
    required EmergencyStatus status,
    String? changedBy,
    String? notes,
  }) async {
    await _firestoreService.updateEmergencyStatus(
      emergencyId: emergencyId,
      status: status,
      changedBy: changedBy,
      notes: notes,
    );
  }

  Future<void> assignResponder({
    required String emergencyId,
    required String responderId,
    required String department,
  }) async {
    await _firestoreService.assignResponder(
      emergencyId: emergencyId,
      responderId: responderId,
      department: department,
    );
  }

  Future<void> addResponseNote({
    required String emergencyId,
    required String note,
    required String addedBy,
    required String noteType,
  }) async {
    await _firestoreService.addResponseNote(
      emergencyId: emergencyId,
      note: note,
      addedBy: addedBy,
      noteType: noteType,
    );
  }

  Stream<List<Emergency>> getActiveEmergencies() {
    return _firestoreService.getEmergenciesByStatus(EmergencyStatus.pending);
  }

  Stream<List<Emergency>> getDepartmentEmergencies(String department) {
    return _firestoreService.getEmergenciesByDepartment(department);
  }

  Stream<Emergency?> getEmergencyDetails(String emergencyId) {
    return _firestoreService.getEmergencyById(emergencyId);
  }
}