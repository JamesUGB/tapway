//C:\Users\Zino\Documents\tapway\lib\data\services\firestore_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tapway/features/emergency/data/models/emergency_model.dart';
import 'package:tapway/features/emergency/data/models/emergency_type.dart';
import 'package:tapway/core/utils/logger_config.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get users => _firestore.collection('users');
  CollectionReference get emergencies => _firestore.collection('emergencies');
  CollectionReference get responders => _firestore.collection('responders');
  CollectionReference get conversations => _firestore.collection('conversations');

Future<String?> uploadIdImage(String uid, String imagePath) async {
    try {
      final ref = _storage.ref().child('id_images/$uid.jpg');
      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      LoggerConfig.logger.severe('Error uploading ID image for user $uid', e);
      return null;
    }
  }
  // Emergency Operations
  Future<void> createEmergency(Emergency emergency) async {
    await emergencies.doc(emergency.id).set(emergency.toMap());
  }

  Future<void> updateEmergencyStatus({
    required String emergencyId,
    required EmergencyStatus status,
    String? changedBy,
    String? notes,
  }) async {
    final updateData = {
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (changedBy != null) {
      updateData['statusHistory'] = FieldValue.arrayUnion([
        {
          'status': status.toString().split('.').last,
          'timestamp': FieldValue.serverTimestamp(),
          'changedBy': changedBy,
        },
      ]);
    }

    await emergencies.doc(emergencyId).update(updateData);
  }

  Future<void> assignResponder({
    required String emergencyId,
    required String responderId,
    required String department,
  }) async {
    final assignmentData = {
      'assignedResponders': FieldValue.arrayUnion([
        {
          'responderId': responderId,
          'assignedAt': FieldValue.serverTimestamp(),
          'status': 'en_route',
          'department': department,
        },
      ]),
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': 'assigned',
          'timestamp': FieldValue.serverTimestamp(),
          'changedBy': responderId,
        },
      ]),
    };

    await emergencies.doc(emergencyId).update(assignmentData);
  }

  Future<void> addResponseNote({
    required String emergencyId,
    required String note,
    required String addedBy,
    required String noteType,
  }) async {
    final noteData = {
      'responseNotes': FieldValue.arrayUnion([
        {
          'note': note,
          'timestamp': FieldValue.serverTimestamp(),
          'addedBy': addedBy,
          'type': noteType,
        },
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await emergencies.doc(emergencyId).update(noteData);
  }

  Stream<List<Emergency>> getEmergenciesByStatus(EmergencyStatus status) {
    return emergencies
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Emergency.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Stream<List<Emergency>> getEmergenciesByDepartment(String department) {
    return emergencies
        .where('department', isEqualTo: department)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Emergency.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Stream<Emergency?> getEmergencyById(String emergencyId) {
    return emergencies
        .doc(emergencyId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? Emergency.fromMap(snapshot.data()! as Map<String, dynamic>)
              : null,
        );
  }

  // Media Upload
  Future<List<String>> uploadEmergencyMedia({
    required String emergencyId,
    required List<File> files,
  }) async {
    final List<String> urls = [];

    for (final file in files) {
      final ref = _storage.ref(
        'emergencies/$emergencyId/media/${DateTime.now().millisecondsSinceEpoch}',
      );
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }
  // Subcollection helper: conversations/{conversationId}/messages
  CollectionReference<Map<String, dynamic>> messages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? {},
          toFirestore: (data, _) => data,
        );
  }
  /// Deterministic conversation id (no extra reads): sorted "A_B"
  String conversationIdFor(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}';
  }

  /// Create conversation doc if missing (id is deterministic)
  Future<void> ensureConversation({
    required String conversationId,
    required List<String> participants, // [userId, responderId]
    Map<String, dynamic>? extra,
  }) async {
    final doc = conversations.doc(conversationId);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        ...?extra,
      });
    }
  }

  /// Append one message + bump conversation metadata
  Future<void> sendConversationMessage({
    required String conversationId,
    required Map<String, dynamic> messageData, // text, senderId, receiverId, etc
  }) async {
    final batch = _firestore.batch();
    final msgRef = conversations.doc(conversationId).collection('messages').doc();

    batch.set(msgRef, {
      ...messageData,
      'id': msgRef.id,
      'sentAt': FieldValue.serverTimestamp(),
    });

    batch.update(conversations.doc(conversationId), {
      'lastMessage': {
        'text': messageData['text'],
        'senderId': messageData['senderId'],
        'receiverId': messageData['receiverId'],
        'sentAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Real-time stream of messages (ascending by sentAt)
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String conversationId) {
    return messages(conversationId)
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  /// Real-time stream of a user's conversations list
  Stream<QuerySnapshot<Map<String, dynamic>>> userConversations(String userId) {
    return conversations
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }
}
