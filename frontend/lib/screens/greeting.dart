import 'package:flutter/material.dart';
import 'package:frontend/screens/upload_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/signup.dart';

import 'list_file_screen.dart';
import 'login_screen.dart';

class GreetingScreen extends StatelessWidget {
  static const String routeName = '/';

  const GreetingScreen({Key? key}) : super(key: key);

  void checkToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('jwt');
    if (value == null) {
      print("token is empty");
    } else {
      print("jwt toekn: " + value);
      print("Ready to go ${ListFileScreen.routeName}");
      Navigator.of(context).pushNamed(ListFileScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkToken(context);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(SignupScreen.routeName);
                },
                child: Text("Signup"),
              ),
              SizedBox(
                width: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
                child: Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
