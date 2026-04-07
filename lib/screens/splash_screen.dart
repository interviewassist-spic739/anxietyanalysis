import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../services/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final isLoggedIn = await UserSession.isLoggedIn();
    
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      body: Center(
        child: Image.asset(
          'assets/images/leaf_icon.png',
          height: 120, // Reduced from 180 as requested
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
