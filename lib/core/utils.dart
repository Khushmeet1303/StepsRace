// Pure utility functions — no dependencies on Flutter widgets
import 'package:intl/intl.dart';

String formatSteps(int steps) => NumberFormat('#,###').format(steps);

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  return parts.take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
}

String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String friendlyDate(DateTime date) => DateFormat('EEE, MMM d').format(date);

double clampPct(int steps, int goal) {
  if (goal <= 0) return 0;
  return (steps / goal).clamp(0.0, 1.0);
}

// Generates a 6-char invite code
String generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rand = DateTime.now().millisecondsSinceEpoch;
  return List.generate(6, (i) => chars[(rand >> (i * 5)) % chars.length]).join();
}
