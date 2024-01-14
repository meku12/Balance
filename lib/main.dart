import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sleep_page.dart';
import 'work_page.dart';
import 'play_page.dart';
import 'other_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
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
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            iconSize: 24.0,
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            splashRadius: 24.0,
            color: Colors.black,
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to NotificationPage
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
            color: Colors.black,
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CarouselSlider(
              items: [
                PlaceholderBox(
                  text: 'Time: 12:00 PM',
                  boxWidth: 250,
                ),
                PlaceholderBox(
                  text: 'Fun',
                  boxWidth: 250,
                ),
                PlaceholderBox(
                  text: 'Work',
                  boxWidth: 250,
                ),
                PlaceholderBox(
                  text: 'Sleep',
                  boxWidth: 250,
                  onTap: () {
                    // Navigate to SleepPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SleepPage()),
                    );
                  },
                ),
                PlaceholderBox(
                  text: 'Study',
                  boxWidth: 250,
                ),
              ],
              options: CarouselOptions(
                height: 100.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                viewportFraction: 1.0, // Display one item at a time
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Handle the onTap action for the interactive image
              },
              child: Image.asset(
                'lib/assets/0511.png_860.png', // Replace with your image asset path
                width: 320,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CategoryBox(title: 'Sleep', boxWidth: 120, boxHeight: 100),
                CategoryBox(title: 'Work', boxWidth: 120, boxHeight: 100),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CategoryBox(title: 'Play', boxWidth: 120, boxHeight: 100),
                CategoryBox(title: 'Other', boxWidth: 120, boxHeight: 100),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    BottomNavItem(icon: Icons.home, label: 'Home'),
                    BottomNavItem(icon: Icons.account_circle, label: 'Profile'),
                    BottomNavItem(icon: Icons.night_shelter, label: 'Sleep'),
                    BottomNavItem(icon: Icons.category, label: 'Other'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderBox extends StatelessWidget {
  final String text;
  final double boxWidth;
  final VoidCallback? onTap;

  const PlaceholderBox({
    required this.text,
    this.boxWidth = 200.0,
    this.onTap,
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
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  final String title;
  final double boxWidth;
  final double boxHeight;

  const CategoryBox({
    required this.title,
    this.boxWidth = 150,
    this.boxHeight = 120,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle category box press
        if (title == 'Sleep') {
          // Navigate to SleepPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SleepPage()),
          );
        } else if (title == 'Work') {
          // Navigate to WorkPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkPage()),
          );
        } else if (title == 'Play') {
          // Navigate to PlayPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayPage()),
          );
        } else if (title == 'Other') {
          // Navigate to OtherPage
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
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
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
          icon: Icon(icon),
          iconSize: 24.0,
          onPressed: () {
            // Handle bottom navigation item press
            if (label == 'Profile') {
              // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            } else if (label == 'Sleep') {
              // Navigate to SleepPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SleepPage()),
              );
            } else if (label == 'Other') {
              // Navigate to OtherPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OtherPage()),
              );
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
