// hive_setup.dart

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    return UserData(
      reader.readString(),
      reader.readString(),
      reader.readString(),
      reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer.writeString(obj.firstName);
    writer.writeString(obj.lastName);
    writer.writeString(obj.email);
    writer.writeString(obj.password);
  }
}

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserDataAdapter());
    await setupUserBox();
    await setupSecurityQuestionsBox();
  }

  static Future<void> setupUserBox() async {
    await Hive.openBox('userBox');
  }

  static Future<void> setupSecurityQuestionsBox() async {
    await Hive.openBox('securityQuestionsBox');
  }

  static Box<dynamic> get _userBox => Hive.box('userBox');
  static Box<dynamic> get _securityQuestionsBox => Hive.box('securityQuestionsBox');

  static Future<bool> doesEmailExist(String email) async {
    print('_userBox keys: ${_userBox.keys}');
    print('Checking if email exists: $email');
    bool exists = _userBox.keys.contains(email);
    print('Email exists: $exists');
    return exists;
  }

  static String getUserName() {
    return _userBox.get('name', defaultValue: '') as String;
  }

  static String getUserEmail() {
    return _userBox.get('email', defaultValue: '') as String;
  }

  static String getUserFirstName() {
    return _userBox.get('firstName', defaultValue: '') as String;
  }

  static String getUserLastName() {
    return _userBox.get('lastName', defaultValue: '') as String;
  }

  static String getUserPassword() {
    return _userBox.get('password', defaultValue: '') as String;
  }

  static Future<bool> loginUser(String email, String password) async {
    final storedEmail = _userBox.get('email', defaultValue: '') as String;
    final storedPassword = _userBox.get('password', defaultValue: '') as String;

    return email == storedEmail && password == storedPassword;
  }

  static Future<void> saveUserData(String firstName, String lastName, String email, String password) async {
    await setupUserBox();
    
    // Check if the email already exists before saving
    if (_userBox.keys.contains(email)) {
      throw EmailAlreadyExistsException('Email already exists.');
    }

    await _userBox.put('firstName', firstName);
    await _userBox.put('lastName', lastName);
    await _userBox.put('email', email);
    await _userBox.put('password', password);
  }

  static Future<void> saveSecurityQuestions(String answer1, String answer2) async {
    await setupSecurityQuestionsBox();
    await _securityQuestionsBox.put('answer1', answer1);
    await _securityQuestionsBox.put('answer2', answer2);
  }

  static Future<bool> verifySecurityAnswers(String answer1, String answer2) async {
    return await _verifySecurityAnswers(answer1, answer2);
  }

  static Future<bool> _verifySecurityAnswers(String answer1, String answer2) async {
    String storedAnswer1 = _userBox.get('securityQuestionAnswer1', defaultValue: '') as String;
    String storedAnswer2 = _userBox.get('securityQuestionAnswer2', defaultValue: '') as String;

    return answer1 == storedAnswer1 && answer2 == storedAnswer2;
  }

  static Future<bool> saveNewPassword(String newPassword) async {
    await setupUserBox();
    await _userBox.put('password', newPassword);
    return true; // Password saved successfully
  }

  static Future<bool> saveNewSecurityAnswers(String answer1, String answer2) async {
    return await _saveNewSecurityAnswers(answer1, answer2);
  }

  static Future<bool> _saveNewSecurityAnswers(String answer1, String answer2) async {
    if (answer1 != getSecurityQuestionAnswer1() || answer2 != getSecurityQuestionAnswer2()) {
      await _userBox.put('securityQuestionAnswer1', answer1);
      await _userBox.put('securityQuestionAnswer2', answer2);
      return true; // Answers are new
    } else {
      return false; // Answers are not new
    }
  }

  static String getSecurityQuestionAnswer1() {
    return _userBox.get('securityQuestionAnswer1', defaultValue: '') as String;
  }

  static String getSecurityQuestionAnswer2() {
    return _userBox.get('securityQuestionAnswer2', defaultValue: '') as String;
  }
}

@HiveType(typeId: 0)
class UserData {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String lastName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  UserData(this.firstName, this.lastName, this.email, this.password);
}

class EmailAlreadyExistsException implements Exception {
  final String message;

  EmailAlreadyExistsException(this.message);

  @override
  String toString() => 'EmailAlreadyExistsException: $message';
}
