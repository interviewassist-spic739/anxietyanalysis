import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _keyDoctorId = 'doctor_id';
  static const String _keyDoctorEmail = 'doctor_email';
  static const String _keyDoctorName = 'doctor_name';

  static Future<void> saveDoctor(int id, String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDoctorId, id);
    await prefs.setString(_keyDoctorEmail, email);
    await prefs.setString(_keyDoctorName, name);
  }

  static Future<int?> getDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDoctorId);
  }

  static Future<String?> getDoctorEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDoctorEmail);
  }

  static Future<String?> getDoctorName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDoctorName);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final id = await getDoctorId();
    return id != null;
  }
}
