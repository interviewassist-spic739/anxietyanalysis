import 'package:flutter/material.dart';
import 'dart:io';
import 'assessment_results_screen.dart';
import 'assessment_recommendations_screen.dart';
import '../theme/app_colors.dart';
import 'assessment_scan_screen.dart';
import 'dashboard_screen.dart';
import '../services/assessment_service.dart';
import '../services/user_session.dart';

class AssessmentSuccessScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final int? dbId;
  final String? imagePath;
  final Map<String, dynamic>? resultData;

  const AssessmentSuccessScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.dbId,
    this.imagePath,
    this.resultData,
  });

  @override
  State<AssessmentSuccessScreen> createState() => _AssessmentSuccessScreenState();
}

class _AssessmentSuccessScreenState extends State<AssessmentSuccessScreen> {
  final AssessmentService _assessmentService = AssessmentService();
  bool _isSaving = false;

  Future<void> _saveAndNavigate() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final doctorId = await UserSession.getDoctorId();
      
      // IF dbId is null, it's a Quick Scan - skip background save
      if (widget.dbId == null || doctorId == null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentResultsScreen(
                patientName: widget.patientName,
                patientId: widget.patientId,
                imagePath: widget.imagePath,
                resultData: widget.resultData!,
                assessmentId: null,
              ),
            ),
          );
        }
        return;
      }

      // Prepare save data
      final saveData = {
        'doctorid': doctorId,
        'patientid': widget.dbId,
        'anxiety_score': widget.resultData?['anxiety_score'] ?? 0,
        'anxiety_level': widget.resultData?['anxiety_level'] ?? 'LOW',
        'dominant_emotion': widget.resultData?['dominant_emotion'],
        'emotions': widget.resultData?['emotions'] ?? {},
        'status': 'PENDING',
        'procedure_type': 'Biometric Scan',
        'health_issues': 'None reported',
        'notes': 'Automatic save from assessment flow',
      };

      final response = await _assessmentService.saveAssessment(saveData);

      if (mounted) {
        if (response['success'] == true || response['assessmentId'] != null) {
          final int assessmentId = response['assessmentId'] ?? 0;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentResultsScreen(
                patientName: widget.patientName,
                patientId: widget.patientId,
                imagePath: widget.imagePath,
                resultData: widget.resultData!,
                assessmentId: assessmentId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: ${response['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Row(
            children: [
              Image.asset(
                'assets/images/leaf_icon.png',
                width: 24,
                height: 24,
                color: AppColors.editorialTextPrimary,
              ),
              const SizedBox(width: 12),
              const Text(
                'AnxiSense',
                style: TextStyle(
                  color: AppColors.editorialTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Success Checkmark
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.anxietyLow,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'SCAN COMPLETE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.editorialTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'PATIENT BIOMETRIC DATA HAS BEEN CAPTURED AND ANALYZED SUCCESSFULLY FOR DIAGNOSTIC MARKERS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.editorialTextSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Scan Reference Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.editorialDivider, width: 1),
                ),
                child: Row(
                  children: [
                    // Captured Photo / Avatar Placeholder
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(16),
                        image: widget.imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(widget.imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.imagePath == null
                          ? const Center(
                              child: Icon(Icons.person, color: Colors.white, size: 40),
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
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
                          Text(
                            '#AS-${widget.resultData?['assessment_id'] ?? "TEMP"}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.editorialTextPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                Icon(Icons.verified_outlined, color: AppColors.anxietyLow, size: 14),
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
              const SizedBox(height: 48),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.editorialTextPrimary,
                          foregroundColor: AppColors.editorialBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.editorialBackground))
                            : const Text(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.editorialTextPrimary, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'DASHBOARD',
                          style: TextStyle(
                            fontSize: 12,
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
              const Spacer(flex: 3),
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppColors.editorialTextSecondary, size: 14),
                    const SizedBox(width: 8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
