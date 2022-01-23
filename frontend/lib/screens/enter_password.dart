import 'package:flutter/material.dart';
import 'package:frontend/models/upload_model.dart';
import 'package:frontend/screens/password_success.dart';
import 'package:url_launcher/url_launcher.dart';

class EnterPasswordScreen extends StatefulWidget {
  static const String routeName = '/enter-password';
  final FilePassword _filePassword;

  EnterPasswordScreen(this._filePassword);

  @override
  _EnterPasswordScreenState createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends State<EnterPasswordScreen> {
  String _truePassword = '';
  bool _isPasswordCorrect = false;

  @override
  void initState(){
    super.initState();
  }

  void _launchURLBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    _truePassword = widget._filePassword.password;

    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    hintText: "Enter password"
                ),
                onChanged: (value){
                  print(value);
                  _isPasswordCorrect = value == _truePassword;
                  print('_isPasswordCorrect: $_isPasswordCorrect');
                },
              ),
              ElevatedButton(onPressed: (){
                if(_isPasswordCorrect){
                  _launchURLBrowser(widget._filePassword.file);
                }else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("CONFIRM"),
                        content: Text("Wrong password"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }, child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
