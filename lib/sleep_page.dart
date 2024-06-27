import 'dart:math';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest'),
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
                  'Take care of your sleep. It\'s the foundation of your well-being.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Sleep Input Form
              SleepInputForm(),
              const SizedBox(height: 16.0),
              // Placeholder Graph
              SleepGraph(),
            ],
          ),
        ),
      ),
    );
  }
}

class SleepInputForm extends StatefulWidget {
  const SleepInputForm({Key? key}) : super(key: key);

  @override
  _SleepInputFormState createState() => _SleepInputFormState();
}

class _SleepInputFormState extends State<SleepInputForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _bedtime;
  late DateTime _wakeupTime;

  Future<void> _saveDataToDatabase() async {
    await Hive.openBox('userBox');
    final userBox = Hive.box('userBox');
    final bedtimeList = userBox.get('bedtimeList', defaultValue: <String>[]);
    final wakeupTimeList = userBox.get('wakeupTimeList', defaultValue: <String>[]);
    bedtimeList.add(_bedtime.toIso8601String());
    wakeupTimeList.add(_wakeupTime.toIso8601String());
    await userBox.put('bedtimeList', bedtimeList);
    await userBox.put('wakeupTimeList', wakeupTimeList);
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
                _bedtime = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Bedtime',
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
                _wakeupTime = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Wake-up Time',
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

class SleepGraph extends StatelessWidget {
  const SleepGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('userBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<dynamic> userBox = snapshot.requireData;

          final bedtimeList = userBox.get('bedtimeList') as List<String>?;
          final wakeupTimeList = userBox.get('wakeupTimeList') as List<String>?;

          if (bedtimeList != null && wakeupTimeList != null && bedtimeList.isNotEmpty && wakeupTimeList.isNotEmpty) {
            final List<double> sleepDurations = [];
            for (int i = 0; i < min(bedtimeList.length, wakeupTimeList.length); i++) {
              final bedtime = DateTime.parse(bedtimeList[i]);
              final wakeupTime = DateTime.parse(wakeupTimeList[i]);
              final sleepDuration = wakeupTime.difference(bedtime).inHours.toDouble();
              sleepDurations.add(sleepDuration);
            }
            final lastSevenSleepDurations = sleepDurations.sublist(max(0, sleepDurations.length - 7));

            double? dailyPercentage;
            double? weeklyPercentage;

            if (sleepDurations.isNotEmpty) {
              dailyPercentage = (sleepDurations.last / 8.0) * 100.0;
              if (sleepDurations.length >= 7) {
                final lastSevenDaysSleepDuration = sleepDurations.sublist(max(0, sleepDurations.length - 7));
                final totalSleepHours = lastSevenDaysSleepDuration.reduce((value, element) => value + element);
                weeklyPercentage = (totalSleepHours / (8.0 * 7)) * 100.0;
              }
            }

            return Column(
              children: [
                Container(
                  height: 200.0,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(lastSevenSleepDurations.length, (index) => FlSpot(index.toDouble(), lastSevenSleepDurations[index])),
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
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularPercentagePlaceholder(
                      percentage: dailyPercentage,
                      label: 'Daily',
                    ),
                    CircularPercentagePlaceholder(
                      percentage: weeklyPercentage,
                      label: 'Weekly',
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Text('No data available'),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularPercentagePlaceholder(
                      percentage: null,
                      label: 'Daily',
                    ),
                    CircularPercentagePlaceholder(
                      percentage: null,
                      label: 'Weekly',
                    ),
                  ],
                ),
              ],
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class CircularPercentagePlaceholder extends StatelessWidget {
  final double? percentage;
  final String label;

  const CircularPercentagePlaceholder({
    Key? key,
    required this.label,
    this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          child: CircularProgressIndicator(
            value: percentage != null ? percentage! / 100 : 0.0,
            strokeWidth: 10,
            color: Color.fromARGB(255, 6, 116, 219),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '${label}: ${percentage != null ? percentage!.toStringAsFixed(1) : 'N/A'}%',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.openBox('userBox');
  runApp(MaterialApp(
    home: const SleepPage(),
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
