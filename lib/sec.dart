import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Sec extends StatefulWidget {
  final String token;

  Sec({Key? key, required this.token}) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<Sec> {
  List<String> grantedPermissions = [];
  List<String> filteredPermissions = [];
  TextEditingController _searchController = TextEditingController();
  int? foundIndex;
  Timer? _timer;
  bool dataFetched = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
  }

  void fetchDataFromServer() async {
    String apiUrl = 'https://easehub-1.onrender.com/api/students/outpass/all';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> studentsJson = jsonDecode(response.body);
        setState(() {
          grantedPermissions = studentsJson
              .map((student) => '${student['name']} / ${student['rollNo']}')
              .toList();
          filteredPermissions = grantedPermissions;
          dataFetched = true;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        grantedPermissions = [];
        filteredPermissions = [];
        dataFetched = false;
      });
    }
  }

  void searchRollNumber(String rollNo) {
    if (!dataFetched) {
      print('Data not fetched yet. Please wait...');
      return;
    }

    setState(() {
      filteredPermissions = grantedPermissions;
    });

    int index = filteredPermissions.indexWhere((permission) {
      List<String> parts = permission.split(' / ');
      if (parts.length == 2) {
        String extractedRollNo = parts[1];
        return extractedRollNo == rollNo;
      }
      return false;
    });

    if (index != -1) {
      setState(() {
        foundIndex = index;
        filteredPermissions.insert(0, filteredPermissions.removeAt(index));
      });
      _startTimer();
    } else {
      setState(() {
        foundIndex = null;
      });
      _showNotFoundSnackBar();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        foundIndex = null;
      });
    });
  }

  void _showNotFoundSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Roll number not found.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget buildSearchButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          String rollNo = _searchController.text;
          searchRollNumber(rollNo);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue[900],
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Search',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredPermissions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                filteredPermissions[index],
                style: TextStyle(
                  fontWeight:
                      foundIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                String studentInfo = filteredPermissions[index];
                String rollNo = studentInfo.split(' / ')[1];
                print('Selected Roll Number: $rollNo');
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Outpass Permission List for Today',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Roll Number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),
            buildSearchButton(),
            SizedBox(height: 10),
            buildListView(),
          ],
        ),
      ),
    );
  }
}
