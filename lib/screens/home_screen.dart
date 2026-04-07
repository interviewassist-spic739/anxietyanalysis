import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.editorialBackground,
      body: Center(
        child: Text(
          'ANXISENSE AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.editorialTextPrimary,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}
