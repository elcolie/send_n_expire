import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../backend_requests/post_file.dart';
import 'list_file_screen.dart';

class UploadScreen extends StatefulWidget {
  static const String routeName = '/upload';

  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  FilePickerResult? _picked;
  String _currentMaxDownload = "100 downloads"; //Initial value
  int _currentExpiryOption = 7 * 24 * 60 * 60; //Initial value
  String? _password;
  bool _isEnable = false;
  String? _selectedFileName;

  final Map<String, int> __downloadOptions = {
    "1 download": 1,
    "2 downloads": 2,
    "3 downloads": 3,
    "4 downloads": 4,
    "5 downloads": 5,
    "20 downloads": 20,
    "50 downloads": 50,
    "100 downloads": 100,
  };

  final Map<String, int> __expiryOptions = {
    "5 minutes": 5 * 60,
    "1 hour": 60 * 60,
    "1 day": 24 * 60 * 60,
    "7 days": 7 * 24 * 60 * 60,
  };

  void submitFile(BuildContext context) async {
    var utcNow = DateTime.now().toUtc();
    print('UTC Now: $utcNow');
    var now = DateTime.now();
    print('Local Now: $now');
    try{
      var response = await uploadFile(
          _picked!,
          __downloadOptions[_currentMaxDownload]!,
          _currentExpiryOption,
          _password);
      print(response.statusCode);
    } on DioError catch (err){
      if(err.response!.statusCode == 400){
        Widget ok = ElevatedButton(
          child: Text("Okay"),
          onPressed: () {Navigator.of(context).pop();},
        );
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Ouch!"),
                content: Text(err.response!.data['file'][0]),
                actions: [
                  ok,
                ],
                elevation: 5,
              );
            }
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _downloadOptionsText = __downloadOptions.keys.toList();
    final _expiryOptionsText = __expiryOptions.keys.toList();
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () async {
                  FilePickerResult? picked =
                      await FilePicker.platform.pickFiles();
                  if (picked != null) {
                    print(picked.files.first.name);
                    setState(() {
                      _picked = picked;
                      _isEnable = true;
                      _selectedFileName = picked.files.first.name;
                    });
                  }
                },
                child: (_selectedFileName == null) ? Text('PLEASE SELECT FILE') : Text(_selectedFileName!),
            ),
            Text("Max Downloads"),
            DropdownButton<String>(
              onChanged: (String? newValue) {
                int downloadTimes = __downloadOptions[newValue]!;
                print('downloadTimes: ${downloadTimes}');
                setState(() {
                  _currentMaxDownload = newValue!;
                });
              },
              // value: _downloadOptionsText.last,
              value: _currentMaxDownload,
              items: _downloadOptionsText.map((String _downloadOption) {
                return DropdownMenuItem(
                  value: _downloadOption,
                  child: Text(_downloadOption),
                );
              }).toList(),
            ),
            Text("Expiry date"),
            DropdownButton<String>(
              onChanged: (String? newValue) {
                int expiryOption = __expiryOptions[newValue]!;
                print('expiryOption: ${expiryOption}');
                setState(() {
                  _currentExpiryOption = expiryOption;
                });
              },
              value: _expiryOptionsText.last,
              items: _expiryOptionsText.map((String _expiryOption) {
                return DropdownMenuItem(
                  value: _expiryOption,
                  child: Text(_expiryOption),
                );
              }).toList(),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                  print(_password);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  // Not allow to post if file is not selected yet
                  onPressed: () {
                    if (_isEnable) {
                      submitFile(context);
                    } else {
                      return null;
                    }
                  },
                  child: Text("Submit"),
                ),
                ElevatedButton(
                  child: Text("Back"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
