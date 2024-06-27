import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'security_question_screen.dart';
import 'security_forgot.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Color.fromARGB(255, 6, 116, 219),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300.0,
                margin: EdgeInsets.only(bottom: 35.0),
                child: Image.asset(
                  'lib/assets/forgot1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Forgot Your Password?',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Enter your email address below to reset your password.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  _resetPassword(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  primary: Color.fromARGB(255, 6, 116, 219),
                ),
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetPassword(BuildContext context) async {
    final userEmail = _emailController.text;
    await Hive.initFlutter();
    final userBox = await Hive.openBox('userBox');

    if (userBox.containsKey('email') && userBox.get('email') == userEmail) {
      // Email exists in the userBox, navigate to SecurityQuestionScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SecurityQuestionScreenab()),
      );
    } else {
      // Email doesn't exist in the userBox
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email not found. Enter a valid email address'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: ForgotPasswordPage(),
  ));
}
