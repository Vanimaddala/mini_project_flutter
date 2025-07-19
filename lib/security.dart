import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SecurityPage extends StatefulWidget {
  final String token;
  final String name;
  final String photoUrl;

  SecurityPage({
    Key? key,
    required this.token,
    required this.name,
    required this.photoUrl,
  }) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
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
              data.map((student) => '${student['rollNo']}').toList();
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
      return permission == rollNo;
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
        backgroundColor: Colors.blue[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text('Search'),
    );
  }

  Widget buildListView() {
    if (isLoading) {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (filteredPermissions.isEmpty) {
      return Expanded(child: Center(child: Text('No permissions found.')));
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
                  print('Selected Roll Number: ${filteredPermissions[index]}');
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(widget.photoUrl),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Security appointed for today.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Outpass Permissions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildProfileHeader(),
            SizedBox(height: 20),
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

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
