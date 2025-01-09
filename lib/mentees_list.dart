import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MenteesPermissionListPage extends StatelessWidget {
  final String token;

  const MenteesPermissionListPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchMenteesList() async {
    final response = await http.get(
      Uri.parse('https://easehub-1.onrender.com/api/faculty/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assuming the API returns a list of mentees as a JSON array
      List<Map<String, dynamic>> mentees =
          List<Map<String, dynamic>>.from(data);
      return mentees;
    } else {
      throw Exception('Failed to load mentees list');
    }
  }

  Future<void> grantPermission(BuildContext context, String rollNumber) async {
    final response = await http.post(
      Uri.parse(
          'https://easehub-1.onrender.com/api/students/$rollNumber/outpass'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final String message;
    if (response.statusCode == 200) {
      message = 'Permission has been granted for roll number $rollNumber.';
    } else {
      message = 'Failed to grant permission for roll number $rollNumber.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(response.statusCode == 200 ? 'Permission Granted' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentees Permission List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMenteesList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No mentees found'));
          } else {
            return ListView(
              padding: EdgeInsets.all(8.0),
              children: snapshot.data!.map((mentee) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(mentee['name']),
                    subtitle: Text(
                      'Roll No: ${mentee['rollNo']}\nBranch: ${mentee['branch']}\nYear: ${mentee['year']}\nPhone: ${mentee['phone']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone),
                      onPressed: () {
                        launch('tel:${mentee['phone']}');
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Grant Permission'),
                          content: Text(
                              'Do you want to grant permission for ${mentee['name']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await grantPermission(
                                    context, mentee['rollNo']);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
