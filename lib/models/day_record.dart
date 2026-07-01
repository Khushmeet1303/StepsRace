// Snapshot of a single user's steps on a single calendar day
import 'package:cloud_firestore/cloud_firestore.dart';

class DayRecord {
  final String uid;
  final DateTime date;
  final int steps;
  final bool goalHit;

  DayRecord({
    required this.uid,
    required this.date,
    required this.steps,
    required this.goalHit,
  });

  factory DayRecord.fromFirestore(String uid, DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DayRecord(
      uid: uid,
      date: DateTime.parse(doc.id),
      steps: d['steps'] ?? 0,
      goalHit: d['goalHit'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'steps': steps,
    'goalHit': goalHit,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
