import 'dart:io';
import 'package:flutter/material.dart';
import 'analysis_detail_screen.dart';
import 'dashboard_screen.dart';
import '../theme/app_colors.dart';

class ScanSuccessScreen extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String? imagePath;

  const ScanSuccessScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Success Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.editorialCardBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.anxietyLow,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SCAN SUCCESSFUL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.editorialTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PATIENT FACIAL DATA HAS BEEN CAPTURED AND\nANALYZED SUCCESSFULLY FOR DIAGNOSTIC MARKERS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.editorialTextSecondary,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Scan Detail Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.editorialDivider, width: 1),
                ),
                child: Row(
                  children: [
                    // Avatar Placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: AppColors.editorialBackground,
                        child: imagePath != null
                            ? Image.file(File(imagePath!), fit: BoxFit.cover)
                            : const Icon(Icons.person_outline, size: 50, color: AppColors.editorialTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SCAN REFERENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.editorialTextSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '#AS-36830',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.editorialTextPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'VERIFICATION STATUS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.editorialTextSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.editorialBackground,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.editorialDivider),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_outlined, size: 14, color: AppColors.anxietyLow),
                                SizedBox(width: 6),
                                Text(
                                  'CLINICAL GRADE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.editorialTextPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalysisDetailScreen(
                                patientName: patientName,
                                patientId: patientId,
                                score: '9%',
                                status: 'Low Anxiety',
                                imagePath: imagePath,
                                useOldDesign: false,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.editorialTextPrimary,
                          foregroundColor: AppColors.editorialBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'ANALYSIS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.editorialTextPrimary, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          foregroundColor: AppColors.editorialTextPrimary,
                        ),
                        child: const Text(
                          'DASHBOARD',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.editorialTextPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Footer
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.editorialTextSecondary, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'HIPAA SECURE CLINICAL DATA ENVIRONMENT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
