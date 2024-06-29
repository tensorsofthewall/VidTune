// Main imports for auth-related functions
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import'package:flutter/foundation.dart';


// Single method for handling sign-in / registering with Google Account
Future<User?> signInWithGoogle() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  // Web application
  if (kIsWeb) {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();

    try {
      final UserCredential credential = await auth.signInWithPopup(googleAuthProvider);

      user = credential.user;
    } catch (e) {
      // Error occured in Signup try again
      if (kDebugMode) {
        developer.log(e.toString());
      }
    }
  }
  // Mobile Application
  else {
    // Trigger authentication
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

    // Complete sign-up
    if (googleSignInAccount != null) {
      // Get auth details
      final GoogleSignInAuthentication googleSignInAuth = await googleSignInAccount.authentication;

      // Get credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuth.accessToken,
        idToken: googleSignInAuth.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // Account was already created with different sign-in option
          if (kDebugMode) {
            developer.log('The account already exists. Try signing in with the previously used credentials');
          }
        } else if (e.code == 'invalid-credential') {
          // Incorrect credentials or expired credentials
          if (kDebugMode) {
            developer.log('Error occurred while accessing credentials. Try again.');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          developer.log("Error occurred with Google Sign-In. Try again: ${e.toString()}");
        }
      }
    }
  }
  return user;
}

// Method to handle sign-out
Future<void> signOut() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
    await auth.signOut();
  } catch (e) {
    if (kDebugMode) {
      developer.log("Error signing out. Try again: ${e.toString()}");
    }
  }
}
