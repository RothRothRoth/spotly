// AuthService implementation using Firebase Auth with fallback mock and AppUser model
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';

/// Simple in‑memory mock user used when Firebase operations fail.
class _MockUser {
  final String username;
  final String email;
  String password;
  bool isVerified;
  String? verificationCode;

  _MockUser({
    required this.username,
    required this.email,
    required this.password,
    this.isVerified = false,
    this.verificationCode,
  });
}

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Lazy getter for FirebaseAuth
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // A static flag to force mock mode (e.g. during testing)
  static bool forceMock = false;

  // In‑memory mock storage
  final Map<String, _MockUser> _mockUsers = {};
  _MockUser? _mockCurrentUser;
  _MockUser? _mockPendingUser;

  bool get _isFirebaseAvailable {
    if (forceMock) return false;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get _shouldUseMock => forceMock || !_isFirebaseAvailable;

  // Helper to locate a mock user by either email or username, returns null if not found.
  _MockUser? _findMockUser(String identifier) {
    // Try email first.
    if (_mockUsers.containsKey(identifier)) return _mockUsers[identifier];
    // Then try username.
    try {
      return _mockUsers.values.firstWhere((u) => u.username == identifier);
    } catch (_) {
      return null;
    }
  }

  String _generateCode() => (Random().nextInt(900000) + 100000).toString();

  // Registration
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final code = _generateCode();
    if (_shouldUseMock) {
      if (_mockUsers.containsKey(email) ||
          _mockUsers.values.any((u) => u.username == username)) {
        return {'success': false, 'message': 'User already exists'};
      }
      final mock = _MockUser(
        username: username,
        email: email,
        password: password,
        verificationCode: code,
      );
      _mockUsers[email] = mock;
      _mockPendingUser = mock;
      return {
        'success': true,
        'code': code,
        'email': email,
        'message': 'Registration successful (mock mode). Code: $code',
      };
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(username);
      await cred.user?.sendEmailVerification();
      
      // Save user to Firestore to support login by username
      try {
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'email': email,
        });
      } catch (e) {
        print('Firestore user write failed: $e');
      }

      return {
        'success': true,
        'code': code,
        'email': email,
        'message': 'Registration successful! A verification email has been sent.',
      };
    } catch (e) {
      String message = 'Registration failed';
      if (e is FirebaseAuthException) {
        message = e.message ?? e.code;
      } else {
        message = e.toString();
      }
      return {'success': false, 'message': message};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (_shouldUseMock) {
      final _MockUser? user = _findMockUser(usernameOrEmail);
      if (user == null || user.password != password) {
        return {'success': false, 'message': 'Invalid credentials'};
      }
      if (!user.isVerified) {
        return {
          'success': false,
          'unverified': true,
          'message': 'Please verify email.',
          'email': user.email,
        };
      }
      _mockCurrentUser = user;
      return {
        'success': true,
        'username': user.username,
        'email': user.email,
        'isVerified': user.isVerified,
        'message': 'Login successful (mock mode).',
      };
    }

    try {
      String email = usernameOrEmail;
      if (!usernameOrEmail.contains('@')) {
        try {
          final query = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: usernameOrEmail)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            email = query.docs.first.get('email') as String;
          } else {
            return {'success': false, 'message': 'Username not found.'};
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Username lookup failed. Please log in with your email address instead.'
          };
        }
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      if (!user.emailVerified) {
        return {
          'success': false,
          'unverified': true,
          'message': 'Please verify your email first. A new link has been sent.',
          'email': user.email,
        };
      }
      return {
        'success': true,
        'username': user.displayName ?? '',
        'email': user.email ?? '',
        'isVerified': user.emailVerified,
        'message': 'Login successful!',
      };
    } catch (e) {
      String message = 'Login failed';
      if (e is FirebaseAuthException) {
        message = e.message ?? e.code;
      } else {
        message = e.toString();
      }
      return {'success': false, 'message': message};
    }
  }

  // Stub for Google Sign‑In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    return {'success': false, 'message': 'Google sign‑in not configured'};
  }

  // Email verification
  Future<bool> verifyRegistrationCode(String code) async {
    if (_shouldUseMock) {
      final pending = _mockPendingUser;
      if (pending != null && pending.verificationCode == code) {
        pending.isVerified = true;
        _mockPendingUser = null;
        _mockCurrentUser = pending;
        return true;
      }
      return false;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.reload();
      return user.emailVerified;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> resendEmailVerification() async {
    if (_shouldUseMock) {
      if (_mockPendingUser != null) {
        return {'success': true, 'message': 'Verification email resent (mock)'};
      }
      return {'success': false, 'message': 'No pending user'};
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return {'success': false, 'message': 'No logged‑in user'};
      await user.sendEmailVerification();
      return {'success': true, 'message': 'Verification email resent'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==============================
  // PASSWORD RESET (FIREBASE FLOW)
  // ==============================

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    if (_shouldUseMock) {
      return {
        'success': true,
        'message': 'Password reset email sent (mock mode).',
      };
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent.',
      };
    } catch (e) {
      String message = 'Failed to send password reset email';
      if (e is FirebaseAuthException) {
        message = e.message ?? e.code;
      } else {
        message = e.toString();
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  // Sign out
  Future<void> logout() async {
    if (!_shouldUseMock) {
      try {
        await _auth.signOut();
      } catch (_) {}
    }
    _mockCurrentUser = null;
    _mockPendingUser = null;
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({String? newUsername, String? photoUrl}) async {
    if (_shouldUseMock) {
      return {'success': true, 'message': 'Profile updated (mock mode).'};
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      if (newUsername != null) {
        await user.updateDisplayName(newUsername);
      }
      if (photoUrl != null && !photoUrl.startsWith('data:image/')) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload(); // Refresh the user object

      // Update in Firestore
      final updates = <String, dynamic>{};
      if (newUsername != null) updates['username'] = newUsername;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));
      }

      return {'success': true, 'message': 'Profile updated'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Helper getters for UI & tests
  AppUser? get currentUser {
    if (_shouldUseMock) {
      final u = _mockCurrentUser;
      return u == null
          ? null
          : AppUser(
              username: u.username,
              email: u.email,
              isVerified: u.isVerified,
              verificationCode: u.verificationCode,
            );
    }
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return AppUser(
      username: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      isVerified: fbUser.emailVerified,
    );
  }

  AppUser? get pendingUser {
    if (_shouldUseMock && _mockPendingUser != null) {
      final u = _mockPendingUser!;
      return AppUser(
        username: u.username,
        email: u.email,
        isVerified: u.isVerified,
        verificationCode: u.verificationCode,
      );
    }
    return null;
  }

  List<AppUser> get debugUsersList => _shouldUseMock
      ? _mockUsers.values
          .map((u) => AppUser(
                username: u.username,
                email: u.email,
                isVerified: u.isVerified,
              ))
          .toList()
      : [];
}