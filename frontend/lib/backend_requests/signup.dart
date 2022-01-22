import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';

Future<http.Response> postSignup (Map<String, String> input) async {
  var headers = {
    'Content-Type': 'application/json'
  };
  var request = http.Request('POST', Uri.parse(backendUrl + '/api/signup/'));
  request.body = json.encode({
    "username": input['username'],
    "email": input['email'],
    "name": input['name'],
    "password": input['password']
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  var resp = await http.Response.fromStream(response);
  return resp;

}
