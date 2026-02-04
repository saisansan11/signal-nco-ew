// Authentication Service for Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web sign in
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        // Save user data to Firestore
        await _saveUserToFirestore(userCredential.user);

        return userCredential;
      } else {
        // Mobile sign in
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Save user data to Firestore
        await _saveUserToFirestore(userCredential.user);

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // New user - create document
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'role': 'student', // Default role
        'progress': {
          'completedModules': [],
          'completedLessons': [],
          'quizScores': {},
          'totalXP': 0,
          'currentStreak': 0,
          'lastActiveDate': null,
        },
      });
    } else {
      // Existing user - update last login
      await userDoc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Update user progress
  Future<void> updateProgress({
    String? completedModule,
    String? completedLesson,
    String? quizId,
    int? quizScore,
    int? xpEarned,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final updates = <String, dynamic>{
      'progress.lastActiveDate': FieldValue.serverTimestamp(),
    };

    if (completedModule != null) {
      updates['progress.completedModules'] = FieldValue.arrayUnion([completedModule]);
    }

    if (completedLesson != null) {
      updates['progress.completedLessons'] = FieldValue.arrayUnion([completedLesson]);
    }

    if (quizId != null && quizScore != null) {
      updates['progress.quizScores.$quizId'] = quizScore;
    }

    if (xpEarned != null) {
      updates['progress.totalXP'] = FieldValue.increment(xpEarned);
    }

    await userDoc.update(updates);
  }

  // Record activity (for teacher dashboard)
  Future<void> recordActivity({
    required String activityType,
    required String activityId,
    Map<String, dynamic>? details,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('activities').add({
      'userId': user.uid,
      'userEmail': user.email,
      'userName': user.displayName,
      'activityType': activityType,
      'activityId': activityId,
      'details': details ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
