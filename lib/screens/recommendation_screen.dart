import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RecommendationScreen extends StatelessWidget {
  final String status;

  const RecommendationScreen({super.key, required this.status});

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
        title: const Text(
          'Clinical Guidance',
          style: TextStyle(
            color: AppColors.editorialTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
              'PROTOCOLS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.editorialTextPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            _buildGuidelineItem('Protocol A: Patient observation for 15 minutes.'),
            _buildGuidelineItem('Protocol B: Ensure calm environment.'),
            _buildGuidelineItem('Protocol C: Review medical history for stimulants.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.editorialTextPrimary,
                  foregroundColor: AppColors.editorialBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text(
                  'CONFIRM RECEIPT',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.editorialTextPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.editorialTextSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
