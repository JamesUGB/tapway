// lib/data/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/data/services/firestore_service.dart';


class UserRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestore = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Role constants
  static const String citizenRole = 'citizen';
  static const String fireAdminRole = 'fire_admin';
  static const String policeAdminRole = 'police_admin';
  static const String paramedicAdminRole = 'paramedic_admin';
  static const String fireResponderRole = 'fire_responder';
  static const String policeResponderRole = 'police_responder';
  static const String paramedicResponderRole = 'paramedic_responder';
  static const String superAdminRole = 'super_admin'; // Added super admin role

  // Department constants
  static const String fireDepartment = 'fire';
  static const String policeDepartment = 'police';
  static const String paramedicDepartment = 'paramedic';

  User? get currentUser => _auth.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.users.doc(user.uid).get();
      return doc as DocumentSnapshot<Map<String, dynamic>>;
    } catch (e) {
      LoggerConfig.logger.severe('Error fetching user data', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.users.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      LoggerConfig.logger.severe('Error fetching user profile', e);
      return null;
    }
  }

  Future<void> createUserProfile({
    required String uid,
    String? email,
    String? phone,
    required String firstName,
    required String lastName,
    required String birthday,
    required String sex,
    String? idNumber,
    String? idImagePath,
    required String role,
  }) async {
    try {
      final validRoles = [
        citizenRole,
        fireAdminRole,
        policeAdminRole,
        paramedicAdminRole,
        fireResponderRole,
        policeResponderRole,
        paramedicResponderRole,
        superAdminRole, // Added super admin
      ];
      
      if (!validRoles.contains(role)) {
        throw ArgumentError('Invalid role specified: $role');
      }

      String? idImageUrl;
      
      if (idImagePath != null && idImagePath.isNotEmpty) {
        idImageUrl = await _firestore.uploadIdImage(uid, idImagePath);
      }

      final userData = {
        'email': email,
        'phone': phone,
        'firstName': firstName,
        'lastName': lastName,
        'birthday': birthday,
        'sex': sex,
        'idNumber': idNumber,
        'idImageUrl': idImageUrl,
        'isEmailVerified': false,
        'role': role,
        'department': _getDepartmentFromRole(role),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.users.doc(uid).set(userData);
      
      LoggerConfig.logger.info('User profile created successfully for $uid with role $role');
    } catch (e) {
      LoggerConfig.logger.severe('Error creating user profile for $uid', e);
      rethrow;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _firestore.users.doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerConfig.logger.severe('Error updating user data', e);
      rethrow;
    }
  }

  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore.users.doc(uid).update({
        'isEmailVerified': isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerConfig.logger.severe('Error updating email verification status', e);
      rethrow;
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.users.doc(uid).update({
        'role': role,
        'department': _getDepartmentFromRole(role),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerConfig.logger.severe('Error updating user role', e);
      rethrow;
    }
  }

  String? _getDepartmentFromRole(String role) {
    if (role == fireAdminRole || role == fireResponderRole) return fireDepartment;
    if (role == policeAdminRole || role == policeResponderRole) return policeDepartment;
    if (role == paramedicAdminRole || role == paramedicResponderRole) return paramedicDepartment;
    return null; // For super_admin and citizen
  }

  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.users.doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      final role = data?['role'] as String?;
      return role != null && (role.endsWith('_admin') || role == superAdminRole);
    } catch (e) {
      LoggerConfig.logger.severe('Error checking admin status', e);
      return false;
    }
  }

  Future<bool> isSuperAdmin(String uid) async {
    try {
      final doc = await _firestore.users.doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      final role = data?['role'] as String?;
      return role == superAdminRole;
    } catch (e) {
      LoggerConfig.logger.severe('Error checking super admin status', e);
      return false;
    }
  }

  Future<bool> isResponder(String uid) async {
    try {
      final doc = await _firestore.users.doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      final role = data?['role'] as String?;
      return role != null && role.endsWith('_responder');
    } catch (e) {
      LoggerConfig.logger.severe('Error checking responder status', e);
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getDepartmentResponders(String department) {
    final responderRole = '${department}_responder';
    return _firestore.users
        .where('role', isEqualTo: responderRole)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList())
        .handleError((e) {
          LoggerConfig.logger.severe('Error fetching responders', e);
          return [];
        });
  }

  // New methods for admin functionality
  Stream<List<Map<String, dynamic>>> getAllAdmins() {
    return _firestore.users
        .where('role', whereIn: [fireAdminRole, policeAdminRole, paramedicAdminRole, superAdminRole])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.users
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}