import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GrantEventPermissions extends StatefulWidget {
  final String token;

  GrantEventPermissions({required this.token});

  @override
  _GrantEventPermissionsState createState() => _GrantEventPermissionsState();
}

class _GrantEventPermissionsState extends State<GrantEventPermissions> {
  String selectedYear = '1st';
  String event = '';
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  List<dynamic> responseData = [];
  List<int> selectedStudents = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    fetchDataFromServer();
  }

  // ----------------------------- API Calls -----------------------------

  void fetchDataFromServer() async {
    final String apiUrl =
        'http://10.0.2.2:5000/api/v1/students/year/$selectedYear';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          responseData = json.decode(response.body);
          selectedStudents.clear();
        });
      } else {
        showSnackBar('Failed to fetch students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      showSnackBar('Error fetching students');
    }
  }

  void grantPermissions() async {
    if (!validateFields()) return;

    try {
      List<String> selectedRollNos = selectedStudents
          .map((index) => responseData[index]['rollNo'].toString())
          .toList();

      Map<String, dynamic> requestBody = {
        "rollNumbers": selectedRollNos,
        "startDate": selectedStartDate.toUtc().toIso8601String(),
        "endDate": selectedEndDate.toUtc().toIso8601String(),
      };

      final String apiUrl =
          'http://10.0.2.2:5000/api/v1/event-permissions/grant';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Permissions granted successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          event = '';
          selectedStudents.clear();
        });
      } else {
        showSnackBar('Failed to grant permissions');
      }
    } catch (e) {
      print('Error granting permissions: $e');
      showSnackBar('Error granting permissions');
    }
  }

  // ----------------------------- Helpers -----------------------------

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
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }

  void toggleStudentSelection(int index) {
    setState(() {
      if (selectedStudents.contains(index)) {
        selectedStudents.remove(index);
      } else {
        selectedStudents.add(index);
      }
    });
  }

  // ----------------------------- UI -----------------------------

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
        padding: EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year Dropdown
                Row(
                  children: [
                    Text('Year:'),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedYear,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => selectedYear = newValue);
                          fetchDataFromServer();
                        }
                      },
                      items: ['1st', '2nd', '3rd', '4th']
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ))
                          .toList(),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Start Date
                Text('Start Date:'),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(
                    "${selectedStartDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                // End Date
                Text('End Date:'),
                TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(
                    "${selectedEndDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                // Event Name Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => event = value),
                ),

                SizedBox(height: 20),

                // Grant Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Grant'),
                          content: Text(
                            'Grant permission to selected students for "$event"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                grantPermissions();
                              },
                              child: Text('Grant'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Grant Permissions'),
                  ),
                ),

                SizedBox(height: 20),

                // Student List
                if (responseData.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: responseData.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedStudents.contains(index);
                      return GestureDetector(
                        onTap: () => toggleStudentSelection(index),
                        child: Card(
                          color: isSelected ? Colors.green[100] : Colors.white,
                          child: ListTile(
                            title: Text(responseData[index]['name']),
                            subtitle: Text(
                                "Roll No: ${responseData[index]['rollNo']}"),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Center(child: Text('No students found')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
