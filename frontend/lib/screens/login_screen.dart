import 'package:flutter/material.dart';
import 'package:frontend/screens/upload_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend_requests/login_request.dart';
import 'error_screen.dart';
import 'list_file_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 400,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Welcome to Send and Expire sytem',
                    style: TextStyle(fontSize: 20.0)),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                  onChanged: (String value) {
                    _username = value;
                  },
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  onChanged: (String value) {
                    _password = value;
                  },
                ),
                TextButton(
                    onPressed: () async {
                      http.Response response =
                      await sendReqLogin(_username, _password);
                      if (response.statusCode == 200) {
                        final prefs = await SharedPreferences.getInstance();
                        Map<String, dynamic> cleanedToken = json.decode(response.body);
                        print("cleaned token: " + cleanedToken["token"]);
                        prefs.setString('jwt', cleanedToken["token"]);
                        print("Write jwt token to disk");
                        Navigator.of(context).pushNamed(ListFileScreen.routeName);
                      } else {
                        Navigator.of(context).pushNamed(ErrorScreen.routeName);
                      }
                    },
                    child: Text('Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
