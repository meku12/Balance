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
    return _userBox.keys.contains(email);
  }

  static Future<void> saveUserData(String firstName, String lastName, String email, String password) async {
    await setupUserBox();
    
    // Check if the email already exists before saving
    if (await doesEmailExist(email)) {
      throw EmailAlreadyExistsException('Email already exists.');
    }

    await _userBox.put('firstName', firstName);
    await _userBox.put('lastName', lastName);
    await _userBox.put('email', email);
    await _userBox.put('password', password);
  }

  // ... (other methods)

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