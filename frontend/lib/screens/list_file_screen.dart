import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/upload_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../backend_requests/delete_upload.dart';
import '../backend_requests/list_files.dart';
import '../constants.dart';
import '../models/upload_model.dart';
import 'enter_password.dart';
import 'login_screen.dart';

class ListFileScreen extends StatefulWidget {
  static const String routeName = '/list-files';
  String? _callingUrl;

  ListFileScreen(this._callingUrl);

  @override
  _ListFileScreenState createState() => _ListFileScreenState();
}

class _ListFileScreenState extends State<ListFileScreen> {
  Map? _responsePayload;
  List<Upload> _uploads = [];
  String? previousUrl;
  String? nextUrl;

  void listFiles() async {
    List<Upload> uploads = [];
    print('widget._callingUrl: ${widget._callingUrl}');
    Response response = await getList(widget._callingUrl);
    _responsePayload = Map.from(response.data);
    _responsePayload!['results'].forEach((uploadResponseInstance) {
      uploads.add(Upload(
        uploadResponseInstance['file'],
        uploadResponseInstance['password'],
        uploadResponseInstance['max_downloads'],
        uploadResponseInstance['expire_date'],
        uploadResponseInstance['download_url'],
        uploadResponseInstance['delete_url'],
        uploadResponseInstance['original_name'],
      ));
    });
    print('_uploads.length: ${uploads.length}');
    setState(() {
      _uploads = uploads;
      previousUrl = _responsePayload!['previous'];
      nextUrl = _responsePayload!['next'];
    });
  }

  void _launchURLBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Widget> renderUploadList() {
    List<Widget> widgetHolders = [];
    for (int i = 0; i < _uploads.length; i++) {
      widgetHolders.add(
        Row(
          children: [
            Text(_uploads[i].originalName),
            Column(
              children: [
                SelectableText(
                    backendUrl + '/api/downloads/${_uploads[i].downloadUrl}'),
                SelectableText(
                    backendUrl + '/api/deletes/${_uploads[i].deleteUrl}'),
              ],
            ),
            ElevatedButton(
              child: _uploads[i].password != null
                  ? Text("Enter Password to download")
                  : Text("Download"),
              onPressed: () {
                if (_uploads[i].password != null) {
                  Navigator.of(context).pushNamed(EnterPasswordScreen.routeName,
                      arguments: FilePassword(
                          _uploads[i].file, _uploads[i].password!));
                } else {
                  _launchURLBrowser(
                      backendUrl + '/api/downloads/' + _uploads[i].downloadUrl);
                  print(_uploads[i].downloadUrl);
                }
              },
            ),
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
                            Response response =
                                await deleteUpload(_uploads[i].deleteUrl);
                            print(response.statusCode);
                            Navigator.of(context)
                                .pushNamed(ListFileScreen.routeName);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }
    print('widgetHolders.length: ${widgetHolders.length}');
    return widgetHolders;
  }

  List<TableRow> listTableRows() {
    List<TableRow> tableRowHolders = [];
    for (int i = 0; i < _uploads.length; i++) {
      tableRowHolders.add(TableRow(children: [
        Text(_uploads[i].originalName),
        SelectableText(
            backendUrl + '/api/downloads/${_uploads[i].downloadUrl}'),
        ElevatedButton(
          child: _uploads[i].password != null
              ? Text("Enter Password to download")
              : Text("Download"),
          onPressed: () {
            if (_uploads[i].password != null) {
              Navigator.of(context).pushNamed(EnterPasswordScreen.routeName,
                  arguments:
                      FilePassword(_uploads[i].file, _uploads[i].password!));
            } else {
              _launchURLBrowser(
                  backendUrl + '/api/downloads/' + _uploads[i].downloadUrl);
              print(_uploads[i].downloadUrl);
            }
          },
        ),
        TextButton(
          child: Text("Delete"),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("CONFIRM"),
                  content: Text("You are going to delete ${_uploads[i].file}"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("OK"),
                      onPressed: () async {
                        Response response =
                            await deleteUpload(_uploads[i].deleteUrl);
                        print(response.statusCode);
                        Navigator.of(context)
                            .pushNamed(ListFileScreen.routeName);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ]));
    }
    return tableRowHolders;
  }

  @override
  void initState() {
    super.initState();
    listFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                  3: IntrinsicColumnWidth(),
                  // 3: FixedColumnWidth(300),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: listTableRows()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Previous'),
                  onPressed: previousUrl == null
                      ? null
                      : () => Navigator.of(context).pushNamed(
                          ListFileScreen.routeName,
                          arguments: previousUrl),
                ),
                TextButton(
                    onPressed: nextUrl == null
                        ? null
                        : () => Navigator.of(context).pushNamed(
                            ListFileScreen.routeName,
                            arguments: nextUrl),
                    child: Text('Next'))
              ],
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                Navigator.of(context).pushNamed(UploadScreen.routeName);
              },
            ),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('jwt');
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
