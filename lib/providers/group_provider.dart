// Manages current group, member profiles, and real-time step streams
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/group.dart';
import '../models/user_profile.dart';

class GroupProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();

  Group? _group;
  List<UserProfile> _members = [];
  bool _loading = false;
  String? _error;

  StreamSubscription<Group?>? _groupSub;
  final Map<String, StreamSubscription<int>> _stepSubs = {};

  Group? get group => _group;
  List<UserProfile> get members => _members;
  bool get loading => _loading;
  bool get inGroup => _group != null;
  String? get error => _error;

  // Called by ProxyProvider when auth user changes
  void onAuthChange(String? uid) {
    if (uid == null) {
      _clearGroup();
      return;
    }
    _loadGroup(uid);
  }

  Future<void> _loadGroup(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      final group = await _firestoreService.getGroupForUser(uid);
      if (group != null) _subscribeToGroup(group);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _subscribeToGroup(Group group) {
    _groupSub?.cancel();
    _groupSub = _firestoreService.groupStream(group.id).listen((g) async {
      _group = g;
      if (g != null) await _refreshMembers(g);
      notifyListeners();
    });
  }

  Future<void> _refreshMembers(Group group) async {
    // Cancel stale step subscriptions for members who left
    final currentIds = group.memberIds.toSet();
    _stepSubs.keys.where((id) => !currentIds.contains(id)).toList().forEach((id) {
      _stepSubs[id]?.cancel();
      _stepSubs.remove(id);
    });

    final profiles = <UserProfile>[];
    for (final uid in group.memberIds) {
      final profile = await _firestoreService.getProfile(uid);
      if (profile != null) {
        final today = await _firestoreService.fetchTodaySteps(uid);
        profile.steps = today;
        profiles.add(profile);

        // Subscribe to live step updates for each member
        if (!_stepSubs.containsKey(uid)) {
          _stepSubs[uid] = _firestoreService.todayStepsStream(uid).listen((steps) {
            final idx = _members.indexWhere((m) => m.uid == uid);
            if (idx != -1) {
              _members[idx] = _members[idx].copyWith(steps: steps);
              notifyListeners();
            }
          });
        }
      }
    }
    _members = profiles;
  }

  Future<void> createGroup(String name, String uid) async {
    try {
      _error = null;
      _loading = true;
      notifyListeners();
      final group = await _firestoreService.createGroup(name, uid);
      _subscribeToGroup(group);
    } catch (e) {
      _error = 'Failed to create group: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroup(String code, String uid) async {
    try {
      _error = null;
      _loading = true;
      notifyListeners();
      final group = await _firestoreService.joinGroupByCode(code, uid);
      if (group == null) {
        _error = 'No group found with that code.';
        return false;
      }
      _subscribeToGroup(group);
      return true;
    } catch (e) {
      _error = 'Failed to join group: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGroup(String uid) async {
    if (_group == null) return;
    try {
      await _firestoreService.leaveGroup(_group!.id, uid);
      _clearGroup();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _clearGroup() {
    _groupSub?.cancel();
    for (final sub in _stepSubs.values) sub.cancel();
    _stepSubs.clear();
    _group = null;
    _members = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _clearGroup();
    super.dispose();
  }
}
