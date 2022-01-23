import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

Future<Response> getList() async {
  final prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString('jwt');
  print('token from disk: $value');
  var dio = Dio();
  var response = await dio.get(
    backendUrl + '/api/lists/',
    options: Options(
      headers: {
        'Authorization': 'token $value'
      }
    )
  );
  return response;
}
