// signup_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'security_question_screen.dart';
import 'hive_setup.dart' as balanceHive;
import 'hive_signup.dart';

void main() async {
  await balanceHive.HiveSetup.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUpButtonEnabled = true;

  void _handleSignup() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (firstName.length <= 3 || lastName.length <= 3) {
      _showErrorDialog('Please enter a valid First Name and Last Name.');
      return;
    }

    bool isEmailValid =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email);
    if (!isEmailValid) {
      _showErrorDialog('Please enter a valid Email address.');
      return;
    }

    if (password.length < 8) {
      _showErrorDialog(
          'Please use a strong password with at least 8 characters.');
      return;
    }

    try {
      print('Checking if email exists...');
      bool emailExists = await balanceHive.HiveSetup.doesEmailExist(email);
      print('Does email exist: $emailExists');

      if (emailExists) {
        print('Email already exists.');
        _showErrorDialog('Email already in use.');
        // Disable sign-up button and clear form fields
        setState(() {
          _isSignUpButtonEnabled = false;
          _firstNameController.clear();
          _lastNameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
        return; // Return here to prevent further execution
      }

      // Proceed with signup if email does not exist
      print('Saving user data...');
      await balanceHive.HiveSetup.saveUserData(
          firstName, lastName, email, password);
      print('User data stored successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SecurityQuestionScreen(),
        ),
      );
    } catch (e) {
      print('Error checking email in the database: $e');
    }
  }

  void _showErrorDialog(String errorMessage) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color.fromARGB(255, 6, 116, 219),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Image.asset(
                'lib/assets/signup1.jpg',
                height: 250.0,
                width: 250.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField(_firstNameController, 'First Name'),
                  SizedBox(height: 16),
                  _buildTextField(_lastNameController, 'Last Name'),
                  SizedBox(height: 16),
                  _buildTextField(
                      _emailController, 'Email', keyboardType: TextInputType.emailAddress),
                  SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Password', obscureText: true),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSignUpButtonEnabled ? _handleSignup : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      primary: Color.fromARGB(255, 6, 116, 219),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      TextButton(
                        onPressed: () {
                          _navigateToLogin(context);
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 6, 116, 219)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
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
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
