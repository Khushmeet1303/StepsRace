// Handles pedometer subscription, midnight reset, and local step caching.
// Android: uses TYPE_STEP_COUNTER (accumulates since reboot).
// iOS: uses CMPedometer cached data (no true background; reads on foreground).
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/utils.dart';

class StepService extends ChangeNotifier {
  int _todaySteps = 0;
  int _baseline = 0; // raw sensor total at start of today
  String _lastResetDate = '';
  StreamSubscription<StepCount>? _stepSub;
  Timer? _midnightTimer;
  bool _isAvailable = false;

  int get todaySteps => _todaySteps;
  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseline = prefs.getInt(kPrefStepBaseline) ?? 0;
    _todaySteps = prefs.getInt(kPrefTodaySteps) ?? 0;
    _lastResetDate = prefs.getString(kPrefLastResetDate) ?? todayKey();

    _startPedometer();
    _scheduleMidnightReset();
  }

  void _startPedometer() {
    try {
      _stepSub = Pedometer.stepCountStream.listen(
        _onStep,
        onError: (_) => _isAvailable = false,
        cancelOnError: false,
      );
      _isAvailable = true;
    } catch (_) {
      _isAvailable = false;
    }
  }

  Future<void> _onStep(StepCount event) async {
    final today = todayKey();
    // New day detected — roll over baseline before computing today's steps
    if (_lastResetDate != today) {
      await _resetForNewDay(event.steps);
      return;
    }

    final raw = event.steps;
    // Guard against sensor reset (reboot on Android)
    if (raw < _baseline) _baseline = raw;

    _todaySteps = raw - _baseline;
    await _persist();
    notifyListeners();
  }

  Future<void> _resetForNewDay(int rawSensorTotal) async {
    _baseline = rawSensorTotal;
    _todaySteps = 0;
    _lastResetDate = todayKey();
    await _persist();
    notifyListeners();
  }

  // Schedules a Timer that fires exactly at the next local midnight
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);
    _midnightTimer = Timer(diff, () {
      // Will be triggered by the next step event; reschedule for the day after
      _scheduleMidnightReset();
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kPrefStepBaseline, _baseline);
    await prefs.setInt(kPrefTodaySteps, _todaySteps);
    await prefs.setString(kPrefLastResetDate, _lastResetDate);
  }

  // Manually add steps — used for demo / testing
  void addSteps(int count) {
    _todaySteps += count;
    notifyListeners();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }
}
