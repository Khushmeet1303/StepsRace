// All Firestore reads and writes: user profiles, groups, daily step sync, history
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/user_profile.dart';
import '../models/group.dart';
import '../models/day_record.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── USER PROFILE ────────────────────────────────────────────────────────────

  Future<void> saveProfile(String uid, String name, String color, int goal) async {
    await _db.collection(kColUsers).doc(uid).set(
      {'name': name, 'color': color, 'goal': goal},
      SetOptions(merge: true),
    );
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(kColUsers).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ── DAILY STEPS ─────────────────────────────────────────────────────────────

  // Writes today's step count — called every ~60s by StepProvider
  Future<void> syncTodaySteps(String uid, int steps, int goal) async {
    final key = todayKey();
    await _db
        .collection(kColUsers)
        .doc(uid)
        .collection(kColDailySteps)
        .doc(key)
        .set({
      'steps': steps,
      'goalHit': steps >= goal,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Reads today's step count for a specific user (used when loading group members)
  Future<int> fetchTodaySteps(String uid) async {
    final doc = await _db
        .collection(kColUsers)
        .doc(uid)
        .collection(kColDailySteps)
        .doc(todayKey())
        .get();
    if (!doc.exists) return 0;
    return (doc.data()?['steps'] ?? 0) as int;
  }

  // Real-time stream of today's step doc for a user — drives live track updates
  Stream<int> todayStepsStream(String uid) {
    return _db
        .collection(kColUsers)
        .doc(uid)
        .collection(kColDailySteps)
        .doc(todayKey())
        .snapshots()
        .map((snap) => snap.exists ? ((snap.data()?['steps'] ?? 0) as int) : 0);
  }

  // ── GROUPS ──────────────────────────────────────────────────────────────────

  Future<Group> createGroup(String name, String creatorUid) async {
    final code = generateInviteCode();
    final ref = await _db.collection(kColGroups).add({
      'name': name,
      'inviteCode': code,
      'memberIds': [creatorUid],
    });
    final doc = await ref.get();
    return Group.fromFirestore(doc);
  }

  Future<Group?> joinGroupByCode(String code, String uid) async {
    final query = await _db
        .collection(kColGroups)
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    await doc.reference.update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
    return Group.fromFirestore(await doc.reference.get());
  }

  Future<Group?> getGroupForUser(String uid) async {
    final query = await _db
        .collection(kColGroups)
        .where('memberIds', arrayContains: uid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return Group.fromFirestore(query.docs.first);
  }

  Stream<Group?> groupStream(String groupId) {
    return _db
        .collection(kColGroups)
        .doc(groupId)
        .snapshots()
        .map((doc) => doc.exists ? Group.fromFirestore(doc) : null);
  }

  Future<void> leaveGroup(String groupId, String uid) async {
    await _db.collection(kColGroups).doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([uid]),
    });
  }

  // ── HISTORY ─────────────────────────────────────────────────────────────────

  Future<List<DayRecord>> getHistory(String uid, {int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffKey = dateKey(cutoff);

    final query = await _db
        .collection(kColUsers)
        .doc(uid)
        .collection(kColDailySteps)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffKey)
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    return query.docs.map((doc) => DayRecord.fromFirestore(uid, doc)).toList();
  }
}
