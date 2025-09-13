import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapway/features/settings/data/models/settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SettingsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  Future<SettingsModel> getSettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (doc.exists) {
        return SettingsModel.fromMap(doc.data()!);
      }
      return SettingsModel(
        notificationsEnabled: true,
        darkModeEnabled: false,
        language: 'English',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .set(settings.toMap());
    } catch (e) {
      rethrow;
    }
  }
}