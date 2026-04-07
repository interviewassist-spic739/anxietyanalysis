import 'dart:io';
import 'package:flutter/material.dart';
import 'save_assessment_screen.dart';
import 'dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../services/pdf_service.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String score;
  final String status;
  final String? imagePath;
  final bool useOldDesign;
  final bool showActionButtons;
  final Map<String, dynamic>? resultData;

  const AnalysisDetailScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.score,
    required this.status,
    this.imagePath,
    this.useOldDesign = false,
    this.showActionButtons = true,
    this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    if (useOldDesign) {
      return Scaffold(
        backgroundColor: AppColors.editorialBackground,
        appBar: AppBar(
          backgroundColor: AppColors.editorialBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Analysis Report',
            style: TextStyle(color: AppColors.editorialTextPrimary, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      score,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary),
                    ),
                    const Text('Anxiety Score', style: TextStyle(color: AppColors.editorialTextSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.editorialBackground,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.getAnxietyColor(status), width: 2),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: AppColors.getAnxietyColor(status), fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recommendation',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Based on the scan, it is recommended to practice deep breathing and mindfulness exercises.',
                style: TextStyle(color: AppColors.editorialTextSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    // New Design (Current Build)
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.editorialTextPrimary),
            onPressed: () async {
              await PdfService.generateAndSaveReport(
                patientName: patientName,
                patientId: patientId,
                score: score,
                status: status,
                resultData: resultData,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.editorialTextPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 3)),
                  (route) => false,
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.editorialCardBackground,
                child: Icon(Icons.person_outline, color: AppColors.editorialTextPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Breadcrumb
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 18, color: AppColors.editorialTextPrimary),
                      const SizedBox(width: 8),
                      const Text(
                        'PATIENT RECORDS',
                        style: TextStyle(
                          color: AppColors.editorialTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Column(
                    children: [
                      // Patient Image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/images/profile_placeholder.png'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Anxiety Analysis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Patient: $patientName',
                            style: const TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Text('▫', style: TextStyle(color: AppColors.editorialDivider)),
                          const SizedBox(width: 8),
                          Text(
                            'ID: $patientId',
                            style: const TextStyle(color: AppColors.editorialTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // AI Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.editorialCardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'AI-GENERATED ANXIETY SCORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                                value: (double.tryParse(score.replaceAll('%', '')) ?? 0.0) / 100,
                                strokeWidth: 8,
                                backgroundColor: AppColors.editorialDivider,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.anxietyLow),
                              ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                score.replaceAll('%', ''),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.editorialTextPrimary,
                                  height: 1,
                                ),
                                ),
                                const Text(
                                  'out of 100',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.editorialTextSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.getAnxietyColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '$status Anxiety',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getAnxietyColor(status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'THE AI DETECTED SIGNIFICANT PATTERNS CONSISTENT WITH $status ANXIETY LEVELS DURING THE SESSION.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextSecondary,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Emotion Analysis Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.editorialCardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.editorialTextPrimary),
                          const SizedBox(width: 10),
                          const Text(
                            'EMOTION ANALYSIS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.editorialTextPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (resultData != null) ...[
                        Row(
                          children: [
                            const Text(
                              'Dominant: ',
                              style: TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              (resultData!['dominant_emotion'] ?? 'N/A').toString().toUpperCase(),
                              style: const TextStyle(color: AppColors.editorialTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Date: ',
                              style: TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              (resultData!['created_at'] ?? DateTime.now().toString().split('.')[0]).toString(),
                              style: const TextStyle(color: AppColors.editorialTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Row(
                          children: [
                            Text(
                              'Dominant: ',
                              style: TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'NEUTRAL',
                              style: TextStyle(color: AppColors.editorialTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Text(
                              'Date: ',
                              style: TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'NEW ASSESSMENT',
                              style: TextStyle(color: AppColors.editorialTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Level Guide Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.editorialCardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.editorialTextPrimary),
                          SizedBox(width: 10),
                          Text(
                            'CLINICAL SCALE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.editorialTextPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildGuideRow('0-39 RANGE', 'LOW ANXIETY', 'STABLE', AppColors.anxietyLow),
                      _buildGuideRow('40-69 RANGE', 'MODERATE', 'MONITOR', AppColors.anxietyModerate),
                      _buildGuideRow('70-100 RANGE', 'HIGH RISK', 'URGENT', AppColors.anxietyHigh),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Bottom Buttons
                if (showActionButtons)
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.editorialTextPrimary,
                              side: const BorderSide(color: AppColors.editorialTextPrimary, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'NEW SCAN',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.editorialTextPrimary,
                              foregroundColor: AppColors.editorialBackground,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'DASHBOARD',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionRow(String label, double value, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary),
            ),
            Text(
              percentage,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideRow(String range, String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                range,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.editorialTextSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
