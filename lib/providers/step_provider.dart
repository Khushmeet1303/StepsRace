// Manages today's step count and syncs to Firestore on a timer
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/step_service.dart';
import '../services/firestore_service.dart';
import '../core/constants.dart';
import '../core/utils.dart';

class StepProvider extends ChangeNotifier {
  final _stepService = StepService();
  final _firestoreService = FirestoreService();

  int _goal = kDefaultGoal;
  Timer? _syncTimer;
  String? _uid;
  bool _initialized = false;

  int get todaySteps => _stepService.todaySteps;
  int get goal => _goal;
  double get pct => clampPct(todaySteps, _goal);
  bool get goalHit => todaySteps >= _goal;
  bool get isAvailable => _stepService.isAvailable;

  Future<void> init(String uid) async {
    if (_initialized && _uid == uid) return;
    _uid = uid;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _goal = prefs.getInt(kPrefUserGoal) ?? kDefaultGoal;

    _stepService.addListener(_onStepUpdate);
    await _stepService.init();

    // Sync to Firestore every kSyncIntervalSeconds
    _syncTimer = Timer.periodic(
      const Duration(seconds: kSyncIntervalSeconds),
      (_) => _syncToCloud(),
    );
    notifyListeners();
  }

  void _onStepUpdate() {
    notifyListeners();
  }

  Future<void> _syncToCloud() async {
    if (_uid == null) return;
    try {
      await _firestoreService.syncTodaySteps(_uid!, todaySteps, _goal);
    } catch (e) {
      debugPrint('Step sync error: $e');
    }
  }

  Future<void> updateGoal(int newGoal) async {
    _goal = newGoal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kPrefUserGoal, newGoal);
    await _syncToCloud();
    notifyListeners();
  }

  // Used in dev/demo — adds simulated steps
  void simulateSteps(int count) {
    _stepService.addSteps(count);
    notifyListeners();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _stepService.removeListener(_onStepUpdate);
    _stepService.dispose();
    super.dispose();
  }
}
