import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DayAnalytics extends StatefulWidget {
  final String token;

  const DayAnalytics({Key? key, required this.token}) : super(key: key);

  @override
  _DayAnalyticsState createState() => _DayAnalyticsState();
}

class _DayAnalyticsState extends State<DayAnalytics> {
  DateTime selectedDate = DateTime.now();
  List<String> studentIds = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchStudentIds(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day Analytics'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          fetchStudentIds(pickedDate);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildStudentIdsList(),
            ),
            if (isLoading) CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentIdsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    } else if (studentIds.isEmpty) {
      return Center(child: Text('No student IDs available.'));
    } else {
      return ListView.builder(
        itemCount: studentIds.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              studentIds[index],
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      );
    }
  }

  Future<void> fetchStudentIds(DateTime date) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      studentIds = [];
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    String apiUrl =
        'https://easehub-1.onrender.com/api/analytics/data?date=$formattedDate';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> ids = data.map((student) {
          // Split the student ID if it's a compound string
          List<String> parts = student.toString().split('-');
          // Pad each part to 6 digits
          List<String> paddedParts =
              parts.map((part) => part.padLeft(6, '0')).toList();
          // Join the padded parts with a separator, if necessary
          return paddedParts.join('-');
        }).toList();
        setState(() {
          studentIds = ids;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch student IDs: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching student IDs: $e';
        isLoading = false;
      });
      print('Error fetching student IDs: $e');
    }
  }
}
