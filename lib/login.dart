import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cse_hod_page.dart';
import 'security.dart';
import 'cse_faculty_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _loginFailed = false;
  String? _errorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(String username, String password) async {
    setState(() {
      _isLoading = true;
      _loginFailed = false;
      _errorMessage = null;
    });

    try {
      final url = 'http://10.0.2.2:5000/api/v1/auth/authenticate';
      final body = json.encode({
        'username': username,
        'password': password,
      });

      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final token = jsonResponse['accessToken'] as String?;
        final role = (jsonResponse['role'] as String?)?.toLowerCase();
        final branch = jsonResponse['branch'] as String?;
        final name = jsonResponse['name'] as String? ?? '';
        final photo = jsonResponse['photo'] as String? ?? '';

        if (token == null || role == null) {
          setState(() {
            _loginFailed = true;
            _errorMessage = 'Invalid response from server.';
          });
          return;
        }

        if (role == 'security') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SecurityPage(
                token: token,
                name: name,
                photoUrl: photo,
              ),
            ),
          );
        } else if (role == 'hod') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CseHodPage(
                name: name,
                role: role,
                branch: branch,
                token: token,
                photo: photo,
              ),
            ),
          );
        } else if (role == 'faculty') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CseFacultyPage(),
            ),
          );
        } else {
          setState(() {
            _loginFailed = true;
            _errorMessage = 'Unknown role: $role';
          });
        }
      } else {
        String errorMsg = 'Login failed with status: ${response.statusCode}';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
        setState(() {
          _loginFailed = true;
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _loginFailed = true;
        _errorMessage = 'Failed to connect to server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    decoration: _inputDecoration('Username'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    decoration: _inputDecoration('Password'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_loginFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _errorMessage ?? 'Login failed!',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login(
                                  _usernameController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
