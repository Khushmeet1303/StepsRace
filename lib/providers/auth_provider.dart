// Bridges Firebase Auth stream with the app's state tree
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  User? _user;
  bool _isLoading = true;
  bool _permissionGranted = false;
  String? _error;

  StreamSubscription<User?>? _authSub;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get permissionGranted => _permissionGranted;
  String? get error => _error;

  AuthProvider() {
    _authSub = _authService.authStateChanges.listen(_onAuthChange);
    _loadPermissionFlag();
  }

  Future<void> _onAuthChange(User? user) async {
    _user = user;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _loadPermissionFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _permissionGranted = prefs.getBool(kPrefPermissionGranted) ?? false;
    notifyListeners();
  }

  Future<void> setPermissionGranted(bool value) async {
    _permissionGranted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefPermissionGranted, value);
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _error = null;
      notifyListeners();
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    try {
      _error = null;
      notifyListeners();
      final cred = await _authService.registerWithEmail(email, password);
      if (cred.user != null) {
        await _firestoreService.saveProfile(cred.user!.uid, name, 'coral', kDefaultGoal);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _error = null;
      notifyListeners();
      final cred = await _authService.signInWithGoogle();
      if (cred?.user != null) {
        // Create profile doc if first sign-in
        final existing = await _firestoreService.getProfile(cred!.user!.uid);
        if (existing == null) {
          final displayName = cred.user!.displayName ?? 'Racer';
          await _firestoreService.saveProfile(cred.user!.uid, displayName, 'coral', kDefaultGoal);
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
