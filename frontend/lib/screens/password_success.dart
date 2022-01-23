import 'package:flutter/material.dart';

class PasswordSuccessScreen extends StatelessWidget {
  static const String routeName = '/password-success';
  const PasswordSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Download will start shortly"),
      ),
    );
  }
}
