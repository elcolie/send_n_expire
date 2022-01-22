import 'package:flutter/material.dart';
import 'package:frontend/screens/error_screen.dart';
import 'package:frontend/screens/finish_signup.dart';
import 'package:frontend/screens/greeting.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/signup.dart';
import 'package:frontend/screens/upload_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routes',
      initialRoute: GreetingScreen.routeName,
      routes: {
        SignupScreen.routeName: (context) => const SignupScreen(),
        GreetingScreen.routeName: (context) => const GreetingScreen(),
        UploadScreen.routeName: (context) => const UploadScreen(),
        FinishSignupScreen.routeName: (context) => const FinishSignupScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        ErrorScreen.routeName: (context) => const ErrorScreen(),
      }
    );
  }
}
