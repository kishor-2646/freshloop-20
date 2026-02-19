import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // Create a new pantry group
  Future<void> createGroup(String name) async {
    String inviteCode = (Random().nextInt(900000) + 100000).toString();
    await _db.collection('groups').add({
      'name': name,
      'inviteCode': inviteCode,
      'adminId': _uid,
      'members': [_uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Join an existing group using a code
  Future<bool> joinGroup(String code) async {
    var snapshot = await _db
        .collection('groups')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'members': FieldValue.arrayUnion([_uid])
      });
      return true;
    }
    return false;
  }
}
