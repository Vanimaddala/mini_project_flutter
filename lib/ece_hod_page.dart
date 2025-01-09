import 'package:flutter/material.dart';
import 'login.dart'; // Import your login screen widget

class EceHodPage extends StatelessWidget {
  final String? name;
  final String? role;
  final String? branch;

  const EceHodPage({Key? key, this.name, this.role, this.branch})
      : super(key: key);

  // Function to handle logout
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECE HOD'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Department of Electronics and Communication Engineering',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Transform and Triumph!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Welcome, $name!',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 10),
          Text(
            'Role: $role',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 10),
          Text(
            'Branch: $branch',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          Spacer(),
          // Buttons go here
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Department of Electronics and Communication Engineering',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Transform and Triumph!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Name: $name', style: TextStyle(color: Colors.black)),
              subtitle: Text('Role: $role\nBranch: $branch',
                  style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                _logout(context); // Call the logout function
              },
            ),
          ],
        ),
      ),
    );
  }
}
