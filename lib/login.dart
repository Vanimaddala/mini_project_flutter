import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cse_hod_page.dart';
import 'sec.dart';
import 'cse_faculty_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _token;
  String? _photoUrl;
  bool _isLoading = false;
  bool _loginFailed = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Step 1

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login(String username, String password) async {
    setState(() {
      _isLoading = true;
      _loginFailed = false;
    });

    try {
      final url = 'https://easehub-1.onrender.com/api/v1/auth/authenticate';
      final map = {
        'username': username,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(url),
        body: json.encode(map),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        _token = jsonResponse['accessToken'];
        _photoUrl = jsonResponse['photo'];
        _loginSuccess(jsonResponse);
        print('Login successful');
      } else if (response.statusCode == 403) {
        setState(() {
          _loginFailed = true;
          _isLoading = false;
        });
        print('Authorization failed: ${response.statusCode}');
      } else {
        setState(() {
          _loginFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        _loginFailed = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loginSuccess(Map<String, dynamic> jsonResponse) {
    final role = jsonResponse['role'] as String?;
    final branch = jsonResponse['branch'] as String?;
    final name = jsonResponse['name'] as String?;

    print('Name: $name, Role: $role, Branch: $branch, Photo: $_photoUrl');

    if (_token != null) {
      if (role == 'Security') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Sec(token: _token!),
          ),
        );
      } else if (role == 'HOD') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CseHodPage(
              name: name,
              role: role,
              branch: branch,
              token: _token,
              photo: _photoUrl,
            ),
          ),
        );
      } else if (role != 'HOD' && role != 'SECURITY') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CseFacultyPage(
              name: name!,
              role: role!,
              branch: branch!,
              token: _token!,
              photo: _photoUrl!,
            ),
          ),
        );
      }
    } else {
      print('Token not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Login',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  // Step 2: Wrap with Form widget and assign _formKey
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/back.svg',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          // Step 3: Use TextFormField for username
                          controller: _usernameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.person, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue[900]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue[900]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          // Step 3: Use TextFormField for password
                          controller: _passwordController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue[900]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue[900]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[900]!,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Step 4: Validate on button press
                                  _login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue[900]!,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      if (_loginFailed)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'There was an error logging in!',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
