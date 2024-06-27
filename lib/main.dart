import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'hive_setup.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'sleep_page.dart';
import 'work_page.dart';
import 'play_page.dart';
import 'notification_page.dart';
import 'Profile_Page.dart';
import 'other_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize path_provider
  await initPathProvider();

  // Initialize Hive
  await HiveSetup.init();

  runApp(MyApp());
}

Future<void> initPathProvider() async {
  await getApplicationDocumentsDirectory();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            elevation: 5,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            iconSize: 24.0,
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            splashRadius: 24.0,
            color: Color.fromARGB(255, 6, 116, 219),
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
          IconButton(
            iconSize: 24.0,
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            splashRadius: 24.0,
            color: Color.fromARGB(255, 6, 116, 219),
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              CarouselSlider(
                items: [
                  PlaceholderBox(
                    text: 'Time: ${getCurrentTime()}',
                    boxWidth: 250,
                  ),
                  PlaceholderBox(
                    text: 'Recreation',
                    boxWidth: 250,
                    icon: Icons.sports,
                    onTap: () {
                      // Add your navigation logic for 'Recreation' here
                    },
                  ),
                  PlaceholderBox(
                    text: 'Productivity',
                    boxWidth: 250,
                    icon: Icons.work,
                    onTap: () {
                      // Add your navigation logic for 'Productivity' here
                    },
                  ),
                  PlaceholderBox(
                    text: 'Rest',
                    boxWidth: 250,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SleepPage()),
                      );
                    },
                    icon: Icons.night_shelter,
                  ),
                ],
                options: CarouselOptions(
                  height: 100.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  viewportFraction: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 53),
                  child: Image.asset(
                    'lib/assets/home1.jpg',
                    width: 250, // Set the desired width
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryBox(title: 'Rest', boxWidth: 150, boxHeight: 120, icon: Icons.night_shelter),
                  CategoryBox(title: 'Productivity', boxWidth: 150, boxHeight: 120, icon: Icons.work),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryBox(title: 'Recreation', boxWidth: 150, boxHeight: 120, icon: Icons.sports),
                  CategoryBox(title: 'Info', boxWidth: 150, boxHeight: 120, icon: Icons.info),
                ],
              ),
              const SizedBox(height: 33),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.blue, width: 2),
                    //bottom: BorderSide(color: Colors.blue, width: 2),
                    left: BorderSide(color: Colors.blue, width: 2),
                    right: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    BottomNavItem(icon: Icons.home, label: 'Home'),
                    BottomNavItem(icon: Icons.account_circle, label: 'Profile'),
                    BottomNavItem(icon: Icons.night_shelter, label: 'Sleep'),
                    BottomNavItem(icon: Icons.info, label: 'Info'),
                  ],
                ),
                
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  String getCurrentTime() {
    final currentTime = DateTime.now();
    return DateFormat.jm().format(currentTime);
  }
}

class PlaceholderBox extends StatelessWidget {
  final String text;
  final double boxWidth;
  final VoidCallback? onTap;
  final IconData? icon;

  const PlaceholderBox({
    required this.text,
    this.boxWidth = 200.0,
    this.onTap,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: boxWidth,
        height: 80,
        decoration: BoxDecoration(
          color: text == 'Time: ${getCurrentTime()}' ? Color.fromARGB(255, 6, 116, 219) : Color.fromARGB(255, 6, 116, 219),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  String getCurrentTime() {
    final currentTime = DateTime.now();
    return DateFormat.jm().format(currentTime);
  }
}

class CategoryBox extends StatelessWidget {
  final String title;
  final double boxWidth;
  final double boxHeight;
  final IconData icon;

  const CategoryBox({
    required this.title,
    this.boxWidth = 150,
    this.boxHeight = 120,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Rest') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SleepPage()),
          );
        } else if (title == 'Productivity') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkPage()),
          );
        } else if (title == 'Recreation') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayPage()),
          );
        } else if (title == 'Info') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtherPage()),
          );
        }
      },
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 6, 116, 219),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Color.fromARGB(255, 6, 116, 219)),
          iconSize: 24.0,
          onPressed: () {
            if (label == 'Profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            } else if (label == 'Sleep') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SleepPage()),
              );
            } else if (label == 'Info') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OtherPage()),
              );
            }
          },
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
