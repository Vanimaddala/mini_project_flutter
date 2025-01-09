import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class GrantEventPermissions extends StatefulWidget {
  final String token;

  GrantEventPermissions({
    required this.token,
  });

  @override
  _GrantEventPermissionsState createState() => _GrantEventPermissionsState();
}

class _GrantEventPermissionsState extends State<GrantEventPermissions>
    with WidgetsBindingObserver {
  Set<String> rollNumbers = {};
  List<String> selectedStudents = [];
  Map<String, Color> studentColors = {};
  TextEditingController searchController = TextEditingController();
  String selectedYear = '3';
  String selectedBranch = 'CSE';
  String event = '';
  late DateTime selectedDate;
  bool permissionsGranted = false;
  late List<dynamic> responseData;
  bool callInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedDate = DateTime.now();
    fetchDataFromServer(selectedYear, selectedBranch);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && callInProgress) {
      setState(() {
        callInProgress = false;
      });
      // Navigate to desired screen or perform any necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back to the app!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void fetchDataFromServer(String year, String branch) async {
    String apiUrl =
        'https://easehub-1.onrender.com/api/students/event/permission/$selectedYear/$selectedBranch';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      responseData = json.decode(response.body);
      setState(() {
        rollNumbers = responseData
            .map<String>((student) => student['rollNo'] ?? '')
            .toSet();
        studentColors = Map.fromIterable(rollNumbers,
            key: (rollNumber) => rollNumber, value: (_) => Colors.white);
      });
    } else {
      throw Exception('Failed to fetch students');
    }
  }

  void grantPermissions() async {
    if (!validateFields()) return;

    try {
      Map<String, dynamic> requestBody = {
        "ids": selectedStudents,
        "start": selectedDate.toIso8601String().substring(0, 10) + 'T00:00:00',
        "end": selectedDate.toIso8601String().substring(0, 10) + 'T00:00:00',
        "reason": event,
      };

      String apiUrl =
          'https://easehub-1.onrender.com/api/students/event/permissions';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Permissions granted successfully!');
        setState(() {
          permissionsGranted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissions granted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        selectedStudents.clear();
        setState(() {
          event = '';
        });
      } else {
        print(
            'Failed to grant permissions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error granting permissions: $e');
    }
  }

  bool validateFields() {
    if (event.isEmpty) {
      showSnackBar('Event name cannot be empty');
      return false;
    }
    if (selectedStudents.isEmpty) {
      showSnackBar('No students selected');
      return false;
    }
    return true;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grant Event Permissions'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Year:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                      });
                      fetchDataFromServer(selectedYear, selectedBranch);
                    }
                  },
                  items: <String>['1', '2', '3', '4']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Branch:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedBranch,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedBranch = newValue;
                      });
                      fetchDataFromServer(selectedYear, selectedBranch);
                    }
                  },
                  items: <String>['CSE', 'ECE']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Event Name'),
              onChanged: (value) {
                setState(() {
                  event = value;
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Date:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rollNumbers.length,
                itemBuilder: (context, index) {
                  final rollNumber = rollNumbers.elementAt(index);
                  final student = responseData[index];
                  final phoneNumber = student['phone'] ?? '';

                  return Card(
                    color: studentColors[rollNumber],
                    child: ListTile(
                      title: Text(rollNumber),
                      subtitle: Text('Phone: $phoneNumber'),
                      trailing: IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () {
                          _callNumber(phoneNumber);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedStudents.contains(rollNumber)) {
                            selectedStudents.remove(rollNumber);
                            studentColors[rollNumber] = Colors.white;
                          } else {
                            selectedStudents.add(rollNumber);
                            studentColors[rollNumber] = Colors.green;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: grantPermissions,
              child: Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _callNumber(String phonenumber) async {
    callInProgress = true;
    bool? res = await FlutterPhoneDirectCaller.callNumber(phonenumber);
    if (res != null && !res) {
      print('Failed to call $phonenumber');
    }
  }
}
