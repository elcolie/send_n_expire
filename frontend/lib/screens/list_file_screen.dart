import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/upload_screen.dart';

import '../backend_requests/delete_upload.dart';
import '../backend_requests/list_files.dart';
import '../models/upload_model.dart';

class ListFileScreen extends StatefulWidget {
  static const String routeName = '/list-files';

  const ListFileScreen({Key? key}) : super(key: key);

  @override
  _ListFileScreenState createState() => _ListFileScreenState();
}

class _ListFileScreenState extends State<ListFileScreen> {
  Map? _responsePayload;
  List<Upload> _uploads = [];

  void listFiles() async {
    List<Upload> uploads = [];
    Response response = await getList();
    _responsePayload = Map.from(response.data);
    // print(_responsePayload!["count"]);
    // print(_responsePayload!["results"]);
    _responsePayload!['results'].forEach((uploadResponseInstance) {
      uploads.add(Upload(
        uploadResponseInstance['file'],
        uploadResponseInstance['password'],
        uploadResponseInstance['max_downloads'],
        uploadResponseInstance['expire_date'],
        uploadResponseInstance['download_url'],
        uploadResponseInstance['delete_url'],
      ));
    });
    print('_uploads.length: ${uploads.length}');
    setState(() {
      _uploads = uploads;
    });
  }

  List<Widget> renderUploadList() {
    List<Widget> widgetHolders = [];
    for (int i = 0; i < _uploads.length; i++) {
      widgetHolders.add(Row(
        children: [
          Text(_uploads[i].file),
          SizedBox(
            width: 20.0,
          ),
          TextButton(onPressed: null, child: Text("Download")),
          SizedBox(width: 40.0),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("CONFIRM"),
                    content:
                        Text("You are going to delete ${_uploads[i].file}"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("OK"),
                        onPressed: () async {
                          Response response = await deleteUpload(_uploads[i].deleteUrl);
                          print(response.statusCode);
                          Navigator.pushNamed(
                              context, ListFileScreen.routeName);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ));
    }
    print('widgetHolders.length: ${widgetHolders.length}');
    return widgetHolders;
  }

  @override
  void initState() {
    super.initState();
    listFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: renderUploadList(),
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: (){
              Navigator.pushNamed(
                context, UploadScreen.routeName);
            },
          )
        ],
      ),
    );
  }
}