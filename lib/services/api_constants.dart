class ApiConstants {
  // For Physical Devices: Use your PC's local IP (e.g. 172.22.x.x)
  // For iOS Simulator: Use http://localhost:5000
  // For Android Emulator: Use http://10.0.2.2:5000
  static const String baseUrl = 'http://10.107.98.190:5000';
  // static const String baseUrl = 'http://10.0.2.2:5000'; 

  // Auth
  static const String sendOtp = '/api/doctor/send-otp';
  static const String verifyOtp = '/api/doctor/verify-otp';

  // Patients
  static const String patients = '/api/patients';

  // Assessments
  static const String analyze = '/api/analyze';
  static const String saveAssessment = '/api/assessments';
  static const String getAssessments = '/api/assessments';

  // Doctor Profile & Dashboard
  static const String dashboardStats = '/api/doctor/dashboard-stats';
  static const String profile = '/api/doctor/profile';
  static const String profilePhoto = '/api/doctor/profile-photo';
}
