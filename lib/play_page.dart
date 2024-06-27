import 'dart:math';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recreation'),
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
                  'Play and have some fun. It\'s good for the soul!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Play Input Form
              PlayInputForm(),
              const SizedBox(height: 16.0),
              // Placeholder Graph
              PlaceholderGraph(),
              const SizedBox(height: 16.0),
              // Percentage Placeholders
              PlayPercentagePlaceholders(),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayInputForm extends StatefulWidget {
  const PlayInputForm({Key? key}) : super(key: key);

  @override
  _PlayInputFormState createState() => _PlayInputFormState();
}

class _PlayInputFormState extends State<PlayInputForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;

  Future<void> _saveDataToDatabase() async {
    await Hive.openBox('playBox');
    final playBox = Hive.box('playBox');
    final startTimeList = playBox.get('startTimeList', defaultValue: <String>[]);
    final endTimeList = playBox.get('endTimeList', defaultValue: <String>[]);
    startTimeList.add(_startTime.toIso8601String());
    endTimeList.add(_endTime.toIso8601String());
    await playBox.put('startTimeList', startTimeList);
    await playBox.put('endTimeList', endTimeList);
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
                setState(() {}); // Update UI after data is saved
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

class PlaceholderGraph extends StatelessWidget {
  const PlaceholderGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('playBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> playBox = snapshot.requireData;

          final startTimeList = playBox.get('startTimeList') as List<String>?;
          final endTimeList = playBox.get('endTimeList') as List<String>?;

          if (startTimeList != null && endTimeList != null && startTimeList.isNotEmpty && endTimeList.isNotEmpty) {
            final List<double> playDurations = [];
            for (int i = 0; i < min(startTimeList.length, endTimeList.length); i++) {
              final startTime = DateTime.parse(startTimeList[i]);
              final endTime = DateTime.parse(endTimeList[i]);
              final playDuration = endTime.difference(startTime).inHours.toDouble();
              playDurations.add(playDuration);
            }
            final lastSevenPlayDurations = playDurations.sublist(max(0, playDurations.length - 7));

            return Container(
              height: 200.0,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(lastSevenPlayDurations.length, (index) => FlSpot(index.toDouble(), lastSevenPlayDurations[index])),
                      isCurved: true,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                      colors: [Color.fromARGB(255, 6, 116, 219)],
                      barWidth: 4,
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                ),
              ),
            );
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

class PlayPercentagePlaceholders extends StatelessWidget {
  const PlayPercentagePlaceholders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('playBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> playBox = snapshot.requireData;

          final startTimeList = playBox.get('startTimeList') as List<String>?;
          final endTimeList = playBox.get('endTimeList') as List<String>?;

          if (startTimeList != null && endTimeList != null && startTimeList.isNotEmpty && endTimeList.isNotEmpty) {
            final double dailyPercentage = calculateDailyPercentage(startTimeList.last, endTimeList.last);
            final double weeklyPercentage = calculateWeeklyPercentage(startTimeList, endTimeList);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularPercentagePlaceholder(
                  label: 'Daily',
                  percentage: dailyPercentage,
                ),
                CircularPercentagePlaceholder(
                  label: 'Weekly',
                  percentage: weeklyPercentage,
                ),
              ],
            );
          } else {
            return SizedBox.shrink(); // No placeholders if no data available
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  double calculateDailyPercentage(String startTimeString, String endTimeString) {
    final startTime = DateTime.parse(startTimeString);
    final endTime = DateTime.parse(endTimeString);
    final playDuration = endTime.difference(startTime).inHours.toDouble();
    final double percentage = (playDuration / 8.0) * 100.0; // Assuming 8 hours as a reference
    return percentage > 100 ? 100.0 : percentage; // Cap the percentage at 100
  }

  double calculateWeeklyPercentage(List<String> startTimeList, List<String> endTimeList) {
    double totalPlayDuration = 0;
    final lastSevenEntries = startTimeList.length > 7 ? startTimeList.length - 7 : 0;
    for (int i = lastSevenEntries; i < startTimeList.length; i++) {
      final startTime = DateTime.parse(startTimeList[i]);
      final endTime = DateTime.parse(endTimeList[i]);
      final playDuration = endTime.difference(startTime).inHours.toDouble();
      totalPlayDuration += playDuration;
    }
    return (totalPlayDuration / (8.0 * 7)) * 100.0; // Assuming a week has 7 days and 8 hours per day
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
  await Hive.openBox('playBox');
  runApp(MaterialApp(
    home: const PlayPage(),
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
