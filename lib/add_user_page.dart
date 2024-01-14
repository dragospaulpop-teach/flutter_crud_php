import 'package:flutter/material.dart';
import 'package:flutter_php/loading_component.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key, this.callback, this.navigator});

  final Function? callback;
  final GlobalKey<NavigatorState>? navigator;

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  bool isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // form key
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String error = '';

  Future<void> addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });
        var url = Uri.http('localhost', 'api_example/backend/add_user.php');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json', // Specify JSON content type
          },
          body: jsonEncode({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            _showSnackbar('User added successfully');
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            widget.callback?.call();
            // navigate back to main page
            widget.navigator?.currentState?.pop();
          } else {
            setState(() {
              error = jsonResponse['message'] ?? 'Failed to add user';
            });
            _showSnackbar(null);
          }
        }
      } catch (e) {
        setState(() {
          error = e.toString();
        });
        _showSnackbar(null);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String? message) {
    BuildContext? scaffoldContext = _scaffoldKey.currentContext;

    if (scaffoldContext != null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(message ?? error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Add User'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: isLoading
              ? LoadingComponent()
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            hintText: 'Enter username',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          }),
                      SizedBox(height: 16.0),
                      TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: 'Enter email',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter email';
                            }
                            return null;
                          }),
                      SizedBox(height: 16.0),
                      TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Enter password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          }),
                      SizedBox(height: 16.0),
                      TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirm Password',
                            hintText: 'Enter confirm password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Confirm password not match';
                            }
                            return null;
                          }),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: addUser,
                        child: Text('Add User'),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
