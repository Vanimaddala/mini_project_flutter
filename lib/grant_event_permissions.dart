import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GrantEventPermissions extends StatefulWidget {
  final String token;

  GrantEventPermissions({
    required this.token,
  });

  @override
  _GrantEventPermissionsState createState() => _GrantEventPermissionsState();
}

class _GrantEventPermissionsState extends State<GrantEventPermissions> {
  String selectedYear = '3';
  String selectedBranch = 'CSE';
  String event = '';
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;
  bool permissionsGranted = false;
  late List<dynamic> responseData = [];

  // List to keep track of selected students
  List<int> selectedStudents = [];

  // Scroll controller to control the scrollbar
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    fetchDataFromServer(selectedYear, selectedBranch);
  }

  void fetchDataFromServer(String year, String branch) async {
    String apiUrl =
        'https://easehub-1.onrender.com/api/students/event/permission/$year/$branch';
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
        });
      } else {
        throw Exception('Failed to fetch students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      // Optionally, show a snackbar or handle the error in UI
    }
  }

  void grantPermissions() async {
    if (!validateFields()) return;

    try {
      List selectedRollNos = selectedStudents
          .map((studentIndex) => responseData[studentIndex]['rollNo'])
          .toList();

      Map<String, dynamic> requestBody = {
        "ids": selectedRollNos,
        "start":
            selectedStartDate.toIso8601String().substring(0, 10) + 'T00:00:00',
        "end": selectedEndDate.toIso8601String().substring(0, 10) + 'T00:00:00',
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permissions Granted'),
              content: Text('Permissions granted successfully!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  // Function to toggle selection of a student
  void toggleStudentSelection(int index) {
    setState(() {
      if (selectedStudents.contains(index)) {
        selectedStudents.remove(index);
      } else {
        selectedStudents.add(index);
      }
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
        padding: EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 10),
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
                    SizedBox(width: 20),
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
                Text(
                  'Start Date:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text(
                        "${selectedStartDate.toLocal()}".split(' ')[0],
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'End Date:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _selectEndDate(context),
                      child: Text(
                        "${selectedEndDate.toLocal()}".split(' ')[0],
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      event = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Permission!'),
                            content: Text(
                                'Are you sure you want to grant the permissions to the selected students for the event "$event" from ${selectedStartDate.toLocal()} to ${selectedEndDate.toLocal()}?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Grant'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  grantPermissions();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Grant Permissions'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      textStyle: TextStyle(color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (responseData.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students List:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: responseData.length,
                        itemBuilder: (context, index) {
                          // Check if current student is selected
                          bool isSelected = selectedStudents.contains(index);

                          return GestureDetector(
                            onTap: () {
                              toggleStudentSelection(index);
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              elevation: 3,
                              color:
                                  isSelected ? Colors.green[100] : Colors.white,
                              child: ListTile(
                                title: Text(
                                  responseData[index]['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                        'Roll No: ${responseData[index]['rollNo']}'),
                                    SizedBox(height: 4),
                                    Text(
                                        'Mentor: ${responseData[index]['mentorId']}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
