import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'day_analytics.dart'; // Import the DayAnalytics widget // Import the StudentsPage widget

class Analytics extends StatefulWidget {
  final String token;

  Analytics({required this.token});

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  late Future<List<int>> _fetchDataFuture;
  List<int> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  Future<List<int>> fetchData() async {
    final response = await http.get(
      Uri.parse(
          'https://easehub-1.onrender.com/api/analytics/count?date=${DateTime.now().toString().substring(0, 10)}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      return List<int>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  List<charts.Series<DayCount, String>> _createSampleData(List<int> data) {
    final today = DateTime.now();
    final days = List.generate(data.length, (index) {
      final date = today.subtract(Duration(days: data.length - 1 - index));
      return DayCount(date: date, count: data[index]);
    });

    int maxCount = days.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return [
      charts.Series<DayCount, String>(
        id: 'Analytics',
        colorFn: (DayCount dayCount, _) => dayCount.count == maxCount
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DayCount dayCount, _) =>
            DateFormat('dd-MM').format(dayCount.date),
        measureFn: (DayCount dayCount, _) => dayCount.count,
        data: days,
        labelAccessorFn: (DayCount dayCount, _) => '${dayCount.count}',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final systemDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('Outpass Analysis'),
        backgroundColor: Color.fromARGB(3, 52, 0, 172),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayAnalytics(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: FutureBuilder<List<int>>(
          future: _fetchDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _data = snapshot.data!;
              return _data.isEmpty
                  ? Center(child: Text('No data available.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DayAnalytics(token: widget.token),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today\'s date: $systemDate',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: charts.BarChart(
                            _createSampleData(_data),
                            animate: true,
                            domainAxis: charts.OrdinalAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(
                                labelStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            primaryMeasureAxis: charts.NumericAxisSpec(
                              renderSpec: charts.GridlineRendererSpec(
                                labelStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 14,
                                ),
                                lineStyle: charts.LineStyleSpec(
                                  color:
                                      charts.MaterialPalette.gray.shadeDefault,
                                ),
                              ),
                            ),
                            barGroupingType: charts.BarGroupingType.grouped,
                            behaviors: [
                              charts.SelectNearest(),
                              charts.DomainHighlighter(),
                              charts.SeriesLegend(
                                entryTextStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                            selectionModels: [
                              charts.SelectionModelConfig(
                                type: charts.SelectionModelType.info,
                                changedListener: _onSelectionChanged,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            }
          },
        ),
      ),
    );
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      final date = selectedDatum.first.datum.date;
      final count = selectedDatum.first.datum.count;
      final day = DateFormat('EEEE').format(date); // Format to get day
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Bar Clicked'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${DateFormat('dd-MM-yyyy').format(date)}'),
              Text('Day: $day'),
              Text('Count: $count'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class DayCount {
  final DateTime date;
  final int count;

  DayCount({required this.date, required this.count});
}
