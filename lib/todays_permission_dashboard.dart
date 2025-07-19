import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventPermissionsPage extends StatefulWidget {
  final String token;

  const EventPermissionsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<EventPermissionsPage> createState() => _EventPermissionsPageState();
}

class _EventPermissionsPageState extends State<EventPermissionsPage> {
  List<dynamic> studentPermissions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url =
        Uri.parse('http://10.0.2.2:5000/api/v1/faculty/event-permissions');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);

        final List<dynamic> permissions = res['eventPermissions'];

        setState(() {
          studentPermissions = permissions;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    // Optional: Format ISO date to YYYY-MM-DD
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Permissions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Permissions')),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Event Permissions')),
      body: ListView.builder(
        itemCount: studentPermissions.length,
        itemBuilder: (context, index) {
          final item = studentPermissions[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Roll No: ${item['rollNo']}'),
              subtitle: Text('Granted by: ${item['grantedBy']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('From:\n${formatDate(item['startDate'])}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('To:\n${formatDate(item['endDate'])}',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
