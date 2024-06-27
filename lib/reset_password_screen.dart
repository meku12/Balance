import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'hive_setup.dart';
import 'main.dart'; // Import your home screen file

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Color.fromARGB(255, 6, 116, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your new password below.',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            PasswordField(
              labelText: 'New Password',
              controller: _newPasswordController,
            ),
            SizedBox(height: 16.0),
            PasswordField(
              labelText: 'Confirm Password',
              controller: _confirmPasswordController,
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                await _resetPassword(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                primary: Color.fromARGB(255, 6, 116, 219),
              ),
              child: Text(
                'Reset Password',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    try {
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _showErrorDialog(context, 'Please enter both new and confirm passwords.');
        return;
      }

      if (newPassword != confirmPassword) {
        _showErrorDialog(context, 'Passwords do not match.');
        return;
      }

      // Save the new password to Hive database
      await HiveSetup.saveNewPassword(newPassword);

      // Navigate to the home screen after resetting the password
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e, stackTrace) {
      print('Error during password reset: $e');
      print('Stack trace: $stackTrace');
      _showErrorDialog(context, 'An error occurred during password reset.');
    }
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

class PasswordField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;

  const PasswordField({
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
        obscureText: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }
}
