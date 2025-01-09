import 'package:flutter/material.dart';

class EceFacultyPage extends StatelessWidget {
  final String name;
  final String role;
  final String branch;

  const EceFacultyPage(
      {Key? key, required this.name, required this.role, required this.branch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECE Faculty Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, $name',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Role: $role',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Branch: $branch',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
