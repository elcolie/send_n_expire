import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../backend_requests/post_file.dart';
import 'list_file_screen.dart';

class TimeValue {
  final int _key;
  final String _value;
  TimeValue(this._key, this._value);
}

class UploadScreen extends StatefulWidget {
  static const String routeName = '/upload';

  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  FilePickerResult? _picked;
  int _currentMaxDownload = 100;
  int _currentExpiryOption = 7 * 24 * 60 * 60;
  String? _password;
  bool _isEnable = false;

  final _buttonOptions = [
    TimeValue(1, "1 download"),
    TimeValue(2, "2 downloads"),
    TimeValue(3, "3 downloads"),
    TimeValue(4, "4 downloads"),
    TimeValue(5, "5 downloads"),
    TimeValue(20, "20 downloads"),
    TimeValue(50, "50 downloads"),
    TimeValue(100, "100 downloads"),
  ];

  final _expiryOptions = [
    TimeValue(5 * 60, "5 minutes"),
    TimeValue(60 * 60, "1 hour"),
    TimeValue(24 * 60 * 60, "1 day"),
    TimeValue(7 * 24 * 60 * 60, "7 days"),
  ];

  void submitFile(BuildContext context) async {
    var utcNow = DateTime.now().toUtc();
    print('UTC Now: $utcNow');
    var now = DateTime.now();
    print('Local Now: $now');

    var sixDaysFromNow = utcNow.add(const Duration(days: 6));
    print('sixDaysFromNow: $sixDaysFromNow');
    var response = await uploadFile(
      _picked!,
      _currentMaxDownload,
      _currentExpiryOption,
      _password
    );
    print(response.statusCode);
    Navigator.pushNamed(
        context, ListFileScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async{
                FilePickerResult? picked = await FilePicker.platform.pickFiles();
                if (picked != null) {
                  print(picked.files.first.name);
                  setState(() {
                    _picked = picked;
                    _isEnable = true;
                  });
                }
              },
              child: Text('SELECT FILE')
            ),
            Text("Max Downloads"),
            Column(
              children: _buttonOptions.map((timeValue) => RadioListTile(
                groupValue: _currentMaxDownload,
                title: Text(timeValue._value),
                value: timeValue._key,
                onChanged: (value){
                  print(value);
                  setState(() {
                    _currentMaxDownload = value as int;
                  });
                },
              )).toList(),
            ),
            Text("Expiry date"),
            Column(
              children: _expiryOptions.map((expiryOption) => RadioListTile(
                title: Text(expiryOption._value),
                groupValue: _currentExpiryOption,
                value: expiryOption._key,
                onChanged: (value){
                  print(value);
                  setState(() {
                    _currentExpiryOption = value as int;
                  });
                },
              )).toList(),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              onChanged: (value){
                setState(() {
                  _password = value;
                });
                print(_password);
              },
            ),
            ElevatedButton(
              // Not allow to post if file is not selected yet
              onPressed: (){
                if (_isEnable){
                  submitFile(context);
                }else{
                  return null;
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
