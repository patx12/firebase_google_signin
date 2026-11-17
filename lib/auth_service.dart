import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _googleInitialized = false;

  Future<void> _initGoogle() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  // GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        await _initGoogle();
        final googleUser = await GoogleSignIn.instance.authenticate();

        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        return (await _auth.signInWithCredential(credential)).user;
      }
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      return null;
    }
  }

  // EMAIL/PASSWORD REGISTER
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint("Registration error: $e");
      return null;
    }
  }

  // EMAIL/PASSWORD LOGIN
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint("Login error: $e");
      return null;
    }
  }

  // FORGOT PASSWORD
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      debugPrint("Password reset error: $e");
      return false;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _initGoogle();
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}