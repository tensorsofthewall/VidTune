// Google Authentication requires SHA-1 release fingerprint for each app. We should probably do authentication last.
import 'package:flutter/material.dart';
import 'package:vibematch/functions/auth.dart' as auth_functions;
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;


class AuthenticationPage extends StatefulWidget{  
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<AuthenticationPage> {
  // TODO: add State variables

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}