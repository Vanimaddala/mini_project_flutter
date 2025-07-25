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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
  }

  Future<void> fetchDataFromServer() async {
    String apiUrl = 'http://10.0.2.2:5000/api/v1/security/outpass-permissions';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          grantedPermissions =
              data.map((student) => ' ${student['rollNo']}').toList();
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
        isLoading = false;
      });
    }
  }

  void searchRollNumber(String rollNo) {
    if (!dataFetched) {
      print('Data not fetched yet.');
      return;
    }

    setState(() {
      filteredPermissions = grantedPermissions;
    });

    int index = filteredPermissions.indexWhere((permission) {
      List<String> parts = permission.split(' / ');
      return parts.length == 2 && parts[1] == rollNo;
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
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget buildSearchButton() {
    return ElevatedButton(
      onPressed: () => searchRollNumber(_searchController.text),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text('Search'),
    );
  }

  Widget buildListView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (filteredPermissions.isEmpty) {
      return Center(child: Text('No permissions found.'));
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: fetchDataFromServer,
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
                    fontWeight: foundIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  String rollNo = filteredPermissions[index].split(' / ')[1];
                  print('Selected Roll Number: $rollNo');
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outpass Permission List for Today'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
