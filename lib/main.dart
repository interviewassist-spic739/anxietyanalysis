import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnxiSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.editorialBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.editorialTextPrimary,
          primary: AppColors.editorialTextPrimary,
          surface: AppColors.editorialBackground,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.editorialTextPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.editorialTextPrimary, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.editorialTextPrimary),
          bodyMedium: TextStyle(color: AppColors.editorialTextSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.editorialDivider,
          thickness: 1,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
