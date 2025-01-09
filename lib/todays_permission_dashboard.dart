import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodaysPermissionDashboard extends StatefulWidget {
  final String token;

  TodaysPermissionDashboard({
    required this.token,
  });

  @override
  _TodaysPermissionDashboardState createState() =>
      _TodaysPermissionDashboardState();
}

class _TodaysPermissionDashboardState extends State<TodaysPermissionDashboard> {
  List<Map<String, dynamic>> studentPermissions = [];
  late http.Client client;
  String selectedYear = '3'; // Default selected year
  String selectedBranch = 'CSE'; // Default selected branch
  List<String> years = ['1', '2', '3', '4'];
  List<String> branches = ['CSE', 'ECE']; // Add more branches if needed

  @override
  void initState() {
    super.initState();
    client = http.Client();
    fetchData(selectedYear, selectedBranch);
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  void fetchData(String year, String branch) async {
    // Constructing the API URL with the selected year and branch
    String apiUrl =
        'https://easehub-1.onrender.com/api/students/event/$year/$branch/permission';

    print('Fetching data for Year: $year, Branch: $branch'); // Debug print

    try {
      final response = await client.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          studentPermissions = List<Map<String, dynamic>>.from(responseData);
        });
        print(
            'Fetched ${studentPermissions.length} permissions'); // Debug print
      } else {
        // Handle error
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                      });
                      fetchData(selectedYear, selectedBranch);
                    }
                  },
                  items: years.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  underline: Container(),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
                DropdownButton<String>(
                  value: selectedBranch,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedBranch = newValue;
                      });
                      fetchData(selectedYear, selectedBranch);
                    }
                  },
                  items: branches.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  underline: Container(),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: studentPermissions.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(),
                ),
                itemBuilder: (context, index) {
                  final student = studentPermissions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.blue[300]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.blue[900]),
                              SizedBox(width: 8),
                              Text(
                                'Name: ${student['name']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.confirmation_number,
                                  color: Colors.blue[900]),
                              SizedBox(width: 8),
                              Text('Roll No.: ${student['rollNo']}'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.blue[900]),
                              SizedBox(width: 8),
                              Text('End: ${student['end']}'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.note, color: Colors.blue[900]),
                              SizedBox(width: 8),
                              Text('Reason: ${student['reason']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
