import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_php/loading_component.dart';
import 'package:http/http.dart' as http;

import 'add_user_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLoading = false;
  List<dynamic> _headers = [];
  final Map<int, dynamic> _users = {};

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  // scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // navigator key
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  String error = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.http('localhost', 'api_example/backend/get_users.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // parse json
        setState(() {
          var data = jsonDecode(response.body);

          _headers = data['headers'];
          for (var i = 0; i < data['data'].length; i++) {
            _users[i] = data['data'][i];
          }
        });
      }
    } on Exception catch (e) {
      setState(() {
        error = e.toString();
      });
      _showSnackbar();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackbar() {
    BuildContext? scaffoldContext = _scaffoldKey.currentContext;

    if (scaffoldContext != null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Users'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AddUserPage(
                      callback: fetchUsers, navigator: _navigatorKey),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: isLoading
              ? LoadingComponent()
              : Center(
                  child: Column(
                    children: [
                      // Expanded(
                      //   child: ListView.builder(
                      //     itemCount: _users.length,
                      //     shrinkWrap: true,
                      //     itemBuilder: (context, index) {
                      //       return ListTile(
                      //         leading: Text(_users[index]['id'].toString()),
                      //         title: Text(_users[index]['username']),
                      //         subtitle: Text(_users[index]['email']),
                      //       );
                      //     },
                      //   ),
                      // ),
                      if (_headers.isNotEmpty)
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            controller: _verticalScrollController,
                            child: Scrollbar(
                              thumbVisibility: true,
                              trackVisibility: true,
                              controller: _horizontalScrollController,
                              notificationPredicate: (notif) =>
                                  notif.depth == 1,
                              child: SingleChildScrollView(
                                controller: _verticalScrollController,
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  controller: _horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    border: TableBorder.all(color: Colors.grey),
                                    columns: [
                                      for (var i = 0; i < _headers.length; i++)
                                        DataColumn(
                                          label: Text(_headers[i]),
                                        )
                                    ],
                                    rows: [
                                      for (var i = 0; i < _users.length; i++)
                                        DataRow(
                                          cells: [
                                            for (var j = 0;
                                                j < _headers.length;
                                                j++)
                                              DataCell(
                                                Text(_users[i][_headers[j]]
                                                    .toString()),
                                              )
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
