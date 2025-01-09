import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Add const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: SplashScreen(), // Set SplashScreen as home
      theme: ThemeData(
        primaryColor:
            Color.fromARGB(255, 252, 252, 252), // Dark blue primary color
        scaffoldBackgroundColor: Colors.white, // White background color
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
    startTime();
  }

  startTime() async {
    var duration = Duration(seconds: 4);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // Set background color to dark blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 100, // Adjust the width as needed
                height: 100, // Adjust the height as needed
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 87, 163),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 255, 251, 251).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'EH',
                    style: TextStyle(
                      fontSize: 40, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900], // Set the color of the text
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "EaseHub",
              style: TextStyle(
                color: Color.fromARGB(255, 1, 73, 129),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(104, 8, 176, 248)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
