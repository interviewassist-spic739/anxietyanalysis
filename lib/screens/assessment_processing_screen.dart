import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'scan_success_screen.dart';
import '../theme/app_colors.dart';

class AssessmentProcessingScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String? imagePath;

  const AssessmentProcessingScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.imagePath,
  });

  @override
  State<AssessmentProcessingScreen> createState() => _AssessmentProcessingScreenState();
}

class _AssessmentProcessingScreenState extends State<AssessmentProcessingScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        _navigateToResults();
      } else {
        setState(() {
          _progress += 0.01;
        });
      }
    });
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanSuccessScreen(
          patientName: widget.patientName,
          patientId: widget.patientId,
          imagePath: widget.imagePath,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anxiety Analysis',
              style: TextStyle(
                color: AppColors.editorialTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${widget.patientName.toUpperCase()} • ID: ${widget.patientId}',
              style: const TextStyle(
                color: AppColors.editorialTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Central Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Captured Photo / Placeholder Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.editorialDivider),
                      image: widget.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.imagePath == null
                        ? const Icon(Icons.person_outline, size: 60, color: AppColors.editorialTextPrimary)
                        : null,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'ANALYZING BIOMETRICS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.editorialTextPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AI IS PROCESSING MICRO-EXPRESSIONS AND\nFACIAL LANDMARKS...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.editorialTextSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Analysis Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.editorialTextPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.editorialTextPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.editorialDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.editorialTextPrimary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Uploading Status Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.editorialDivider),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.editorialTextPrimary),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'UPLOADING TO CLOUD',
                          style: TextStyle(
                            color: AppColors.editorialTextPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Bottom Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.editorialBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.editorialDivider),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.editorialTextPrimary, size: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'AI ANALYZES BIOMETRIC DATA POINTS TO CALCULATE STRESS VECTORS.',
                      style: TextStyle(
                        color: AppColors.editorialTextSecondary,
                        fontSize: 10,
                        height: 1.4,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
