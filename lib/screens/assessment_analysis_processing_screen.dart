import 'package:flutter/material.dart';
import 'dart:io';
import 'assessment_success_screen.dart';
import '../theme/app_colors.dart';
import '../services/assessment_service.dart';
import '../services/user_session.dart';

class AssessmentAnalysisProcessingScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final int? dbId;
  final String? imagePath;

  const AssessmentAnalysisProcessingScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.dbId,
    this.imagePath,
  });

  @override
  State<AssessmentAnalysisProcessingScreen> createState() => _AssessmentAnalysisProcessingScreenState();
}

class _AssessmentAnalysisProcessingScreenState extends State<AssessmentAnalysisProcessingScreen> {
  double _progress = 0.0;
  String _statusMessage = 'INITIALIZING ANALYSIS ENGINE...';

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    if (widget.imagePath == null) {
      _showError('No image captured.');
      return;
    }

    setState(() {
      _progress = 0.2;
      _statusMessage = 'SENDING BIOMETRIC DATA...';
    });

    final File imageFile = File(widget.imagePath!);
    final result = await AssessmentService().analyzeFace(imageFile);

    if (result['success'] == true) {
      final doctorId = await UserSession.getDoctorId();
      final assessmentData = {
        'patientid': widget.dbId,
        'doctorid': doctorId,
        'anxiety_score': result['anxiety_score'],
        'anxiety_level': _getAnxietyLevel(result['anxiety_score']),
        'dominant_emotion': result['dominant_emotion'],
        'emotions': result['emotions'],
      };

      // Skip background save, pass data to success screen for late save
      setState(() => _progress = 1.0);
      if (mounted) {
        _navigateToSuccess(assessmentData);
      }
    } else {
      _showError(result['message'] ?? 'Face analysis failed.');
    }
  }

  void _navigateToSuccess(Map<String, dynamic> assessmentData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentSuccessScreen(
          patientName: widget.patientName,
          patientId: widget.patientId,
          dbId: widget.dbId,
          imagePath: widget.imagePath,
          resultData: assessmentData,
        ),
      ),
    );
  }

  String _getAnxietyLevel(double score) {
    if (score < 30) return 'Low';
    if (score < 70) return 'Moderate';
    return 'High';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
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
              'Processing Data',
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
            // Central Analysis Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.editorialDivider, width: 1),
              ),
              child: Column(
                children: [
                  // Captured Photo / Profile Placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.editorialDivider, width: 2),
                      image: widget.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.imagePath == null
                        ? const Icon(Icons.person_outline, size: 60, color: AppColors.editorialTextSecondary)
                        : null,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'FACIAL FEATURE ANALYSIS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.editorialTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ENGINE IS PROCESSING MICRO-EXPRESSIONS AND\nKEY BIOMETRIC LANDMARKS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextSecondary,
                      height: 1.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.editorialDivider, thickness: 1),
                  const SizedBox(height: 24),
                  // Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ANALYSIS PROGRESS',
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
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 4,
                      backgroundColor: AppColors.editorialDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.editorialTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Uploading Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.editorialDivider),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.editorialTextPrimary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: AppColors.editorialTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.editorialDivider),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.editorialTextPrimary, size: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'OUR AI ANALYZES 9 KEY FACIAL POINTS TO DETERMINE STRESS LEVELS WITH HIGH ACCURACY.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.editorialTextSecondary,
                        height: 1.4,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
