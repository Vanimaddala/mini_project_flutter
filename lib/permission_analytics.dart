import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HourlyOutpassAnalytics extends StatefulWidget {
  final String token;

  const HourlyOutpassAnalytics({Key? key, required this.token})
      : super(key: key);

  @override
  _HourlyOutpassAnalyticsState createState() => _HourlyOutpassAnalyticsState();
}

class _HourlyOutpassAnalyticsState extends State<HourlyOutpassAnalytics> {
  List<int> hourlyCounts = List.filled(24, 0);
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchHourlyData();
  }

  Future<void> fetchHourlyData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/v1/outpass-analytics/hourly'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> counts = jsonData["hourlyOutpassCounts"];
        setState(() {
          hourlyCounts = counts.map((e) => e as int).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(child: Text("Failed to load analytics data"));
    }

    // Find max count to scale bars
    int maxCount = hourlyCounts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) maxCount = 1; // avoid div by zero

    return Scaffold(
      appBar: AppBar(
        title: Text('Hourly Outpass Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 24,
          itemBuilder: (context, hour) {
            final count = hourlyCounts[hour];
            final barWidth =
                (count / maxCount) * MediaQuery.of(context).size.width * 0.6;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: barWidth,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 8),
                  Text(count.toString()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
