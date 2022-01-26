import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

Future<Response> getList(String? callingUrl) async {
  print(callingUrl);
  final prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString('jwt');
  print('token from disk: $value');
  var dio = Dio();
  var response = await dio.get(
    callingUrl == null ? listUploadUrl : callingUrl,
    options: Options(
      headers: {
        'Authorization': 'token $value'
      }
    )
  );
  return response;
}
