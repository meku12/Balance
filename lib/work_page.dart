import 'dart:math';

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity'),
        backgroundColor: Color.fromARGB(255, 6, 116, 219),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 6, 116, 219),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Excel in your work. It\'s the key to success.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Work Input Form
              WorkInputForm(),
              const SizedBox(height: 16.0),
              // Placeholder Graph
              WorkGraph(),
              const SizedBox(height: 16.0),
              // Daily and Weekly Percentage Placeholders
              Expanded(
                child: Column(
                  children: [
                    DailyPercentagePlaceholder(),
                    WeeklyPercentagePlaceholder(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkInputForm extends StatefulWidget {
  const WorkInputForm({Key? key}) : super(key: key);

  @override
  _WorkInputFormState createState() => _WorkInputFormState();
}

class _WorkInputFormState extends State<WorkInputForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime = DateTime.now(); // Initialize with default value
  late DateTime _endTime = DateTime.now(); // Initialize with default value

  Future<void> _saveDataToDatabase() async {
    await Hive.openBox('workBox');
    final workBox = Hive.box('workBox');
    final startTimeList = workBox.get('startTimeList', defaultValue: <String>[]);
    final endTimeList = workBox.get('endTimeList', defaultValue: <String>[]);
    startTimeList.add(_startTime.toIso8601String());
    endTimeList.add(_endTime.toIso8601String());
    await workBox.put('startTimeList', startTimeList);
    await workBox.put('endTimeList', endTimeList);
    setState(() {}); // Update UI after data is saved
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DateTimeField(
            format: DateFormat('yyyy-MM-dd HH:mm'),
            onChanged: (value) {
              setState(() {
                _startTime = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Start Time',
              border: OutlineInputBorder(),
            ),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    currentValue ?? DateTime.now(),
                  ),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
          ),
          const SizedBox(height: 16.0),
          DateTimeField(
            format: DateFormat('yyyy-MM-dd HH:mm'),
            onChanged: (value) {
              setState(() {
                _endTime = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'End Time',
              border: OutlineInputBorder(),
            ),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    currentValue ?? DateTime.now(),
                  ),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _saveDataToDatabase();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Data saved successfully'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 6, 116, 219),
              onPrimary: Colors.white,
              minimumSize: Size(350, 57),
            ),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkGraph extends StatelessWidget {
  const WorkGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('workBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> workBox = snapshot.requireData;

          final startTimeList = workBox.get('startTimeList') as List<String>?;
          final endTimeList = workBox.get('endTimeList') as List<String>?;

          if (startTimeList != null &&
              endTimeList != null &&
              startTimeList.isNotEmpty &&
              endTimeList.isNotEmpty) {
            final List<double> workDurations = [];
            for (int i = 0; i < min(startTimeList.length, endTimeList.length); i++) {
              final startTime = DateTime.parse(startTimeList[i]);
              final endTime = DateTime.parse(endTimeList[i]);
              final workDuration = endTime.difference(startTime).inHours.toDouble();
              if (workDuration.isFinite) {
                workDurations.add(workDuration);
              } else {
                print('Invalid work duration at index $i: $workDuration');
              }
            }

            if (workDurations.isNotEmpty) {
              return Container(
                height: 200.0,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          workDurations.length,
                          (index) => FlSpot(index.toDouble(), workDurations[index]),
                        ),
                        isCurved: true,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(show: false),
                        colors: [Color.fromARGB(255, 6, 116, 219)],
                        barWidth: 4,
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(showTitles: true),
                      bottomTitles: SideTitles(showTitles: true),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                  ),
                ),
              );
            } else {
              return Text('No valid work durations available');
            }
          } else {
            return Text('No data available');
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class DailyPercentagePlaceholder extends StatelessWidget {
  const DailyPercentagePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('workBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> workBox = snapshot.requireData;

          final startTimeList = workBox.get('startTimeList') as List<String>?;
          final endTimeList = workBox.get('endTimeList') as List<String>?;

          if (startTimeList != null &&
              endTimeList != null &&
              startTimeList.isNotEmpty &&
              endTimeList.isNotEmpty) {
            final int lastIndex = startTimeList.length - 1;
            final DateTime lastStartTime = DateTime.parse(startTimeList[lastIndex]);
            final DateTime lastEndTime = DateTime.parse(endTimeList[lastIndex]);
            final double lastWorkDuration = lastEndTime.difference(lastStartTime).inHours.toDouble();
            final double dailyPercentage = (lastWorkDuration / 8.0) * 100.0;

            return CircularPercentagePlaceholder(
              label: 'Daily',
              percentage: dailyPercentage,
            );
          } else {
            return CircularPercentagePlaceholder(
              label: 'Daily',
              percentage: 0.0,
            );
          }
        } else {
          return CircularPercentagePlaceholder(
            label: 'Daily',
            percentage: 0.0,
          );
        }
      },
    );
  }
}

class WeeklyPercentagePlaceholder extends StatelessWidget {
  const WeeklyPercentagePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('workBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> workBox = snapshot.requireData;

          final startTimeList = workBox.get('startTimeList') as List<String>?;
          final endTimeList = workBox.get('endTimeList') as List<String>?;

          if (startTimeList != null &&
              endTimeList != null &&
              startTimeList.isNotEmpty &&
              endTimeList.isNotEmpty) {
            double weeklyPercentage = 0.0;
            if (startTimeList.length >= 7 && endTimeList.length >= 7) {
              final lastSevenStartTimes = startTimeList.sublist(max(0, startTimeList.length - 7));
              final lastSevenEndTimes = endTimeList.sublist(max(0, endTimeList.length - 7));
              double totalWorkHours = 0;
              for (int i = 0; i < lastSevenStartTimes.length; i++) {
                final startTime = DateTime.parse(lastSevenStartTimes[i]);
                final endTime = DateTime.parse(lastSevenEndTimes[i]);
                final workDuration = endTime.difference(startTime).inHours.toDouble();
                totalWorkHours += workDuration;
              }
              weeklyPercentage = (totalWorkHours / (8.0 * 7)) * 100.0;
            }

            return CircularPercentagePlaceholder(
              label: 'Weekly',
              percentage: weeklyPercentage,
            );
          } else {
            return CircularPercentagePlaceholder(
              label: 'Weekly',
              percentage: 0.0,
            );
          }
        } else {
          return CircularPercentagePlaceholder(
            label: 'Weekly',
            percentage: 0.0,
          );
        }
      },
    );
  }
}

class CircularPercentagePlaceholder extends StatelessWidget {
  final String label;
  final double percentage;

  const CircularPercentagePlaceholder({
    Key? key,
    required this.label,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.0,
          height: 80.0,
          child: CircularProgressIndicator(
            value: percentage / 100,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '$label\n${percentage.toStringAsFixed(0)}%',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.openBox('workBox');
  runApp(MaterialApp(
    home: const WorkPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 6, 116, 219),
          elevation: 5,
        ),
      ),
    ),
    debugShowCheckedModeBanner: false,
  ));
}
