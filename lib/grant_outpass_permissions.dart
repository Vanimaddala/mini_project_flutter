import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GrantOutpassPermissions extends StatefulWidget {
  final String? hodDepartment;
  final String token;

  const GrantOutpassPermissions({
    Key? key,
    required this.hodDepartment,
    required this.token,
  }) : super(key: key);

  @override
  _GrantOutpassPermissionsState createState() =>
      _GrantOutpassPermissionsState();
}

class _GrantOutpassPermissionsState extends State<GrantOutpassPermissions> {
  TextEditingController rollNumberController = TextEditingController();
  bool isFetchingDetails = false;
  Map<String, dynamic> details = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grant Outpass Permissions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: rollNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Roll Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: isFetchingDetails ? null : fetchDetails,
              child: isFetchingDetails
                  ? CircularProgressIndicator()
                  : Text('Grant Permission'),
            ),
            SizedBox(height: 20),
            if (details.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(details.toString()), // Display details
                ],
              ),
          ],
        ),
      ),
    );
  }

  void fetchDetails() {
    final rollNumber = rollNumberController.text.trim();
    final token = widget.token;

    if (rollNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a roll number.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing.'),
        ),
      );
      return;
    }

    setState(() {
      isFetchingDetails = true;
    });

    final url =
        'https://easehub-1.onrender.com/api/students/$rollNumber/outpass';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http
        .post(
      Uri.parse(url),
      headers: headers,
    )
        .then((response) {
      setState(() {
        isFetchingDetails = false;
      });
      if (response.statusCode == 200) {
        // Handle empty response body appropriately
        setState(() {
          details = {}; // Assuming the details will be updated accordingly
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Granted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permission granted for roll number: $rollNumber'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('OK'),
                  ],
                ),
              ),
            ],
          ),
        );

        // Determine phone number and send SMS via Twilio API
        sendSmsNotifications(rollNumber);
      } else if (response.statusCode == 403) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invalid roll number. Please enter a valid roll number.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('OK'),
                  ],
                ),
              ),
            ],
          ),
        );
        setState(() {
          details.clear(); // Clear details if roll number is invalid
        });
      } else {
        print('Failed to fetch details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch details. Please try again later.'),
          ),
        );
      }
    }).catchError((error) {
      setState(() {
        isFetchingDetails = false;
      });
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    });
  }

  void sendSmsNotifications(String rollNumber) async {
    final twilioUrl =
        'https://api.twilio.com/2010-04-01/Accounts/ACb5d54883acd4c519e05d5223b1657b90/Messages.json';
    final twilioAuth = 'API KEY';
    final encodedAuth = base64Encode(utf8.encode(twilioAuth));

    final securityMessage =
        'Permission granted to roll number $rollNumber for today.';
    final parentMessage =
        'Permission granted for your ward to leave college for today.';

    // List of phone numbers and corresponding messages
    final messages = [
      {'phone': '+918106841586', 'message': securityMessage},
      {'phone': '+917981054363', 'message': parentMessage},
    ];

    // Send SMS to each number
    for (var entry in messages) {
      final response = await http.post(
        Uri.parse(twilioUrl),
        headers: {
          'Authorization': 'Basic $encodedAuth',
        },
        body: {
          'Body': entry['message'],
          'From': '+13099280812',
          'To': entry['phone'],
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS sent successfully!'),
          ),
        );
      } else {
        print(
            'Failed to send SMS to ${entry['phone']}. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS to ${entry['phone']}.'),
          ),
        );
      }
    }
  }
}
