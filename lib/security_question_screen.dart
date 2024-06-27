import 'package:flutter/material.dart';
import 'main.dart'; // Import your home page file
import 'hive_setup.dart';
import 'reset_password_screen.dart';
import 'security_question_hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import your reset password screen file

class SecurityQuestionScreen extends StatelessWidget {
  final TextEditingController _question1Controller = TextEditingController();
  final TextEditingController _question2Controller = TextEditingController();

  // List of well-known security questions
  final List<String> wellKnownQuestions = [
    'What is your nickname?',
    'In what city were you born?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Question'),
        backgroundColor: Color.fromARGB(255, 6, 116, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'These questions help to reset your password in case you forget it.',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wellKnownQuestions
                  .map((question) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          question,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20.0),
            SecurityQuestionField(
              labelText: 'Your Answer for Question 1',
              controller: _question1Controller,
            ),
            SizedBox(height: 16.0),
            SecurityQuestionField(
              labelText: 'Your Answer for Question 2',
              controller: _question2Controller,
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                await _handleSecurityQuestions(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                primary: Color.fromARGB(255, 6, 116, 219),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSecurityQuestions(BuildContext context) async {
    String answer1 = _question1Controller.text;
    String answer2 = _question2Controller.text;

    if (answer1.isEmpty || answer2.isEmpty) {
      _showErrorDialog(context, 'Please answer both security questions.');
      return;
    }

    // Open the "userBox" Hive box
    var userBox = await Hive.openBox('userBox');

    // Save the entered security answers to the userBox
    await SecurityQuestionHive.saveNewSecurityAnswers(answer1, answer2, userBox);

    // Navigate to the home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class SecurityQuestionField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;

  const SecurityQuestionField({
    Key? key,
    required this.labelText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }
}
