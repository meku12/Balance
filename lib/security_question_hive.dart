import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecurityQuestionHive {
  static Future<void> init() async {
    await Hive.initFlutter();
    await setupUserBox();
    await setupSecurityQuestionsBox();
  }

  static Future<void> setupUserBox() async {
    await Hive.openBox('userBox');
  }

  static Future<void> setupSecurityQuestionsBox() async {
    await Hive.openBox('securityQuestionsBox');
  }

  static Box get _userBox => Hive.box('userBox');
  static Box get _securityQuestionsBox => Hive.box('securityQuestionsBox');

  static Future<bool> saveNewSecurityAnswers(String answer1, String answer2, Box userBox) async {
    // Check if the entered answers are different from the stored ones
    if (answer1 != getSecurityQuestionAnswer1() || answer2 != getSecurityQuestionAnswer2()) {
      // Save the new answers
      await _securityQuestionsBox.put('answer1', answer1);
      await _securityQuestionsBox.put('answer2', answer2);

      // Check if the entered answers are new to the userBox
      bool isNewAnswers = await _checkIfAnswersAreNew(answer1, answer2, userBox);

      return isNewAnswers; // Answers are new
    } else {
      return false; // Answers are not new
    }
  }

  static Future<bool> _checkIfAnswersAreNew(String answer1, String answer2, Box userBox) async {
    // Fetch the existing answers from the userBox
    String storedAnswer1 = userBox.get('securityQuestionAnswer1', defaultValue: '') as String;
    String storedAnswer2 = userBox.get('securityQuestionAnswer2', defaultValue: '') as String;

    // Check if the entered answers are new to the userBox
    if (answer1 != storedAnswer1 || answer2 != storedAnswer2) {
      // Save the new answers to the userBox
      await userBox.put('securityQuestionAnswer1', answer1);
      await userBox.put('securityQuestionAnswer2', answer2);
      return true; // Answers are new
    } else {
      return false; // Answers are not new
    }
  }

  static String getSecurityQuestionAnswer1() {
    return _securityQuestionsBox.get('answer1', defaultValue: '') as String;
  }

  static String getSecurityQuestionAnswer2() {
    return _securityQuestionsBox.get('answer2', defaultValue: '') as String;
  }
}
