// Data model for a racer in a group
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class UserProfile {
  final String uid;
  final String name;
  final String color; // key into kAvatarColors
  final int goal;
  int steps; // mutable: updated from Firestore stream

  UserProfile({
    required this.uid,
    required this.name,
    required this.color,
    required this.goal,
    this.steps = 0,
  });

  double get pct => (steps / goal).clamp(0.0, 1.0);
  bool get goalHit => steps >= goal;

  factory UserProfile.fromFirestore(DocumentSnapshot doc, {int todaySteps = 0}) {
    final d = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: d['name'] ?? 'Racer',
      color: d['color'] ?? 'coral',
      goal: d['goal'] ?? kDefaultGoal,
      steps: todaySteps,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'color': color,
    'goal': goal,
  };

  UserProfile copyWith({String? name, String? color, int? goal, int? steps}) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      color: color ?? this.color,
      goal: goal ?? this.goal,
      steps: steps ?? this.steps,
    );
  }
}
