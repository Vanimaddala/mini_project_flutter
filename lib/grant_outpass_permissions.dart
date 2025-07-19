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
  final TextEditingController rollNumberController = TextEditingController();
  bool isFetchingDetails = false;
  Map<String, dynamic> details = {};

  // ✅ Twilio Configuration (Replace with secure secrets in production)
  final String twilioSid = 'ACb5d54883acd4c519e05d5223b1657b90';
  final String twilioAuthToken = '2b7de5f630eedffbb6bb6e483a88eb14';
  final String twilioFromNumber = '+16184486068';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grant Outpass Permissions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: rollNumberController,
              decoration: const InputDecoration(
                labelText: 'Enter Roll Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isFetchingDetails ? null : fetchDetails,
              child: isFetchingDetails
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Grant Permission'),
            ),
            const SizedBox(height: 20),
            if (details.isNotEmpty) ...[
              const Text(
                'Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(details.toString()),
            ],
          ],
        ),
      ),
    );
  }

  // 🔍 Fetch details and grant permission
  Future<void> fetchDetails() async {
    final rollNumber = rollNumberController.text.trim();

    if (rollNumber.isEmpty) {
      showErrorDialog('Please enter a roll number.');
      return;
    }

    setState(() => isFetchingDetails = true);

    final url = 'http://10.0.2.2:5000/api/v1/outpass/grant';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    final body = jsonEncode({'rollNo': rollNumber});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      setState(() => isFetchingDetails = false);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          details = jsonData['permission'] ?? {};
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission Granted'),
            content: Text('Permission granted for roll number: $rollNumber'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('OK'),
                  ],
                ),
              ),
            ],
          ),
        );

        sendSmsNotifications(rollNumber);
      } else if (response.statusCode == 404) {
        showErrorDialog('Student not found.');
      } else if (response.statusCode == 400) {
        showErrorDialog('Invalid input: roll number is required.');
      } else {
        print('Error: ${response.body}');
        showSnackBar('Failed to grant permission. Try again.');
      }
    } catch (error) {
      setState(() => isFetchingDetails = false);
      print('Error: $error');
      showSnackBar('Something went wrong. Please try again later.');
    }
  }

  // 📲 Send SMS notifications via Twilio
  Future<void> sendSmsNotifications(String rollNumber) async {
    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$twilioSid/Messages.json');
    final auth = base64Encode(utf8.encode('$twilioSid:$twilioAuthToken'));

    final messages = [
      {
        'phone': '+918125601586',
        'message':
            'Security Alert: Permission granted to $rollNumber for today.',
      },
      {
        'phone': '+919347759421',
        'message':
            'Dear Parent, your ward $rollNumber is permitted to leave college today.',
      },
    ];

    for (var msg in messages) {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioFromNumber,
          'To': msg['phone']!,
          'Body': msg['message']!,
        },
      );

      if (response.statusCode == 201) {
        showSnackBar('SMS sent to ${msg['phone']}');
      } else {
        print('SMS send failed to ${msg['phone']}: ${response.body}');
        showSnackBar('Failed to send SMS to ${msg['phone']}');
      }
    }
  }

  // 🔔 Snackbar for quick messages
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ❌ Error dialog for user-friendly feedback
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('OK'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
