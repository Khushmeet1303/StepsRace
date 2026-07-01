// Data model for a race group
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String inviteCode;
  final List<String> memberIds;

  Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberIds,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: d['name'] ?? 'My Group',
      inviteCode: d['inviteCode'] ?? '',
      memberIds: List<String>.from(d['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'inviteCode': inviteCode,
    'memberIds': memberIds,
  };
}
