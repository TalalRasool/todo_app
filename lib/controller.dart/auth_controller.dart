import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/utils/app_snackbar.dart';

class AuthController extends GetxController {
  /// Set only by a successful sign-in or sign-up. The main screen consumes it once.
  static bool pendingWelcomeNotification = false;
  static String? pendingWelcomeName;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> signUp(String name, String email, String password) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        AppSnackbar.error('Error', 'Account could not be created.');
        return;
      }

      final trimmedName = name.trim();
      final createdUser = userCredential.user;
      if (createdUser != null) {
        unawaited(createdUser.updateDisplayName(trimmedName));
      }
      _saveUserProfile(uid, {
        'name': trimmedName,
        'email': email.trim(),
        'uid': uid,
        'createdAt': Timestamp.now(),
      });

      pendingWelcomeNotification = true;
      pendingWelcomeName = trimmedName;
      Get.offAllNamed(RouteNames.mainscreen);
      AppSnackbar.success('Success', 'Account created successfully.');
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up failed: ${e.code}');
      AppSnackbar.error('Sign up failed', _authErrorMessage(e));
    } catch (e) {
      debugPrint('Sign up failed: $e');
      AppSnackbar.error('Sign up failed', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final signedInUser = credential.user;
      if (signedInUser != null) {
        unawaited(_saveNameIfMissing(signedInUser));
      }
      pendingWelcomeNotification = true;
      pendingWelcomeName = null;
      Get.offAllNamed(RouteNames.mainscreen);
      AppSnackbar.success('Success', 'Signed in successfully.');
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in failed: ${e.code}');
      AppSnackbar.error('Login failed', _authErrorMessage(e));
    } catch (e) {
      debugPrint('Sign in failed: $e');
      AppSnackbar.error('Login failed', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgetPassword(String email) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.back();
      AppSnackbar.success(
        'Link sent',
        'Password reset link has been sent to your email.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset failed: ${e.code}');
      AppSnackbar.error('Error', _authErrorMessage(e));
    } catch (e) {
      debugPrint('Password reset failed: $e');
      AppSnackbar.error('Error', 'Could not send the reset link.');
    } finally {
      isLoading.value = false;
    }
  }

  void _saveUserProfile(String uid, Map<String, dynamic> data) {
    unawaited(
      _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true)).then<void>(
        (_) {},
        onError: (Object e, StackTrace _) {
          debugPrint('Could not save profile: $e');
        },
      ),
    );
  }

  /// Copies a Google account name, or an existing display name, when the
  /// profile document does not already have a name.
  Future<void> _saveNameIfMissing(User user) async {
    final uid = user.uid;
    try {
      final cached = await _firestore.collection('users').doc(uid).get(
        const GetOptions(source: Source.cache),
      );
      final existing = (cached.data()?['name'] as String?)?.trim() ?? '';
      if (existing.isNotEmpty) return;
    } catch (e) {
      debugPrint('No cached profile: $e');
    }

    var name = '';
    for (final info in user.providerData) {
      if (info.providerId != 'google.com') continue;
      final value = info.displayName?.trim() ?? '';
      if (value.isNotEmpty) {
        name = value;
        break;
      }
    }
    if (name.isEmpty) {
      name = user.displayName?.trim() ?? '';
    }
    if (name.isEmpty) return;

    unawaited(user.updateDisplayName(name));
    _saveUserProfile(uid, {
      'name': name,
      'uid': uid,
      'email': user.email,
    });
    if (Get.isRegistered<TodoController>() &&
        Get.find<TodoController>().userName.value.trim().isEmpty) {
      Get.find<TodoController>().userName.value = name;
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
