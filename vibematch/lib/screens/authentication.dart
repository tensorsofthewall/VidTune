import 'package:flutter/material.dart';
import 'package:vibematch/functions/auth.dart' as auth_functions;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:vibematch/screens/overview.dart'; // Import the OverviewPage

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<AuthenticationPage> {
  // State variables
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    _checkCurrentUser();
  }

// Function to check if user is already signed in
  void _checkCurrentUser() {
    Future.microtask(() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _user = user;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OverviewPage()),
        );
      } 
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sign out the current user if any
      await FirebaseAuth.instance.signOut();

      // Sign in with Google
      User? user = await auth_functions.signInWithGoogle();
      if (user != null) {
        setState(() {
          _user = user;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OverviewPage()),
        );
      } else {
        setState(() {
          _errorMessage = "Google Sign-In cancelled.";
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        setState(() {
          _errorMessage =
              "The account already exists with a different credential.";
        });
      } else if (e.code == 'invalid-credential') {
        setState(() {
          _errorMessage = "The credential is invalid.";
        });
      } else {
        setState(() {
          _errorMessage = "Error during Google Sign-In: ${e.message}";
        });
      }
      developer.log('FirebaseAuthException during Google Sign-In: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = "Error during Google Sign-In: $e";
      });
      developer.log('Error during Google Sign-In: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Page'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: const Text('Sign in with Google'),
                  ),
                ],
              ),
      ),
    );
  }
}
