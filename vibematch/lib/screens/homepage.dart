// Main packages required for Home Screen
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';



// Home Screen implementation

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen")
      ),
      body: Center(
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                "Home Screen opened"
              )
            ),
            Expanded(child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (kDebugMode) {
                  developer.log("go back to overview");
                }
              },
              child: const Text("go back heathen")
            ),)
          ]
          
        )
      )
    );
  }
}