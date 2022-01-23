import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants.dart';


Future<Response> uploadFile(
    FilePickerResult? picked,
    int currentMaxDownload,
    int currentExpiryOption,
    String? password
) async {
  print('Input Expire date in seconds from now: ${currentExpiryOption}');
  var utcNow = DateTime.now().toUtc();
  print('UTC Now: $utcNow');
  var trueExpiryDate = utcNow.add(Duration(seconds: currentExpiryOption));
  print('True expiry date: $trueExpiryDate');
  FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromBytes(
      picked!.files.first.bytes as List<int>, filename: picked.files.first.name
    ),
    "max_downloads": currentMaxDownload,
    "expire_date": trueExpiryDate,
    "password": password
  });

  final prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString('jwt');
  print('toekn from disk: $value');

  var dio = Dio();
  var response = await dio.post(
      '$backendUrl/api/uploads/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'token $value'
        }
      )
  );
  return response;
}
