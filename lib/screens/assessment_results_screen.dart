import 'package:flutter/material.dart';
import 'dart:io';
import 'assessment_recommendations_screen.dart';
import 'save_assessment_screen.dart';
import '../theme/app_colors.dart';
import 'scan_session_screen.dart';
import 'assessment_scan_screen.dart';
import 'dashboard_screen.dart';

class AssessmentResultsScreen extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String? imagePath;
  final Map<String, dynamic>? resultData;
  final int? assessmentId;

  const AssessmentResultsScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.imagePath,
    this.resultData,
    this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    final double score = (resultData?['anxiety_score'] ?? 0.0).toDouble();
    final String level = resultData?['anxiety_level'] ?? 'LOW';
    final Color statusColor = _getStatusColor(level);

    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text(
            'AnxiSense',
            style: TextStyle(
              color: AppColors.editorialTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
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
                backgroundColor: AppColors.editorialCardBackground,
                child: Icon(Icons.person_outline, color: AppColors.editorialTextPrimary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Patient Records back link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  final int? dbId = resultData?['patientid'];
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  
                  if (dbId == null || dbId == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanSessionScreen(
                          patientName: patientName,
                          patientId: patientId,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssessmentScanScreen(
                          patientName: patientName,
                          patientId: patientId,
                          dbId: dbId,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 20, color: AppColors.editorialTextPrimary),
                    const SizedBox(width: 8),
                    const Text(
                      'PATIENT RECORDS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.editorialTextPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Patient Profile
            Center(
              child: Column(
                children: [
                  // Captured Photo in Results
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.editorialCardBackground,
                      shape: BoxShape.circle,
                      image: imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imagePath == null
                        ? const Center(
                            child: Icon(Icons.person_outline, size: 40, color: AppColors.editorialTextPrimary),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assessment Data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        patientName.toUpperCase(),
                        style: const TextStyle(color: AppColors.editorialTextSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: AppColors.editorialDivider)),
                      const SizedBox(width: 8),
                      Text(
                        'ID: $patientId',
                        style: const TextStyle(color: AppColors.editorialTextSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Main Assessment Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Score Gauge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: (resultData?['anxiety_score'] ?? 0) / 100, 
                          strokeWidth: 8,
                          backgroundColor: AppColors.editorialDivider,
                          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(resultData?['anxiety_level'] ?? 'Low')),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            (resultData?['anxiety_score'] ?? 0).toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.editorialTextPrimary,
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
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(resultData?['anxiety_level'] ?? 'Low'), width: 2),
                    ),
                    child: Text(
                      '${(resultData?['anxiety_level'] ?? 'LOW').toUpperCase()} ANXIETY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: _getStatusColor(resultData?['anxiety_level'] ?? 'Low'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'THE AI DETECTED SIGNIFICANT PATTERNS CONSISTENT WITH ${(resultData?['anxiety_level'] ?? 'LOW').toUpperCase()} ANXIETY LEVELS DURING THE SESSION.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
            const SizedBox(height: 24),
            // Emotion Analysis Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: AppColors.editorialTextPrimary, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'EMOTION DATA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ..._buildEmotionBars(resultData?['emotions'] ?? {}),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Anxiety Scale Level Guide
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.editorialTextSecondary, size: 16),
                      SizedBox(width: 12),
                      Text(
                        'CLINICAL SCALE GUIDE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGuideRow('0-39 RANGE', 'LOW ANXIETY', 'STABLE', AppColors.anxietyLow, AppColors.editorialBackground),
                  const SizedBox(height: 16),
                  _buildGuideRow('40-69 RANGE', 'MODERATE', 'MONITOR', AppColors.anxietyModerate, AppColors.editorialBackground),
                  const SizedBox(height: 16),
                  _buildGuideRow('70-100 RANGE', 'HIGH RISK', 'URGENT', AppColors.anxietyHigh, AppColors.editorialBackground),
                ],
              ),
            ),
            const SizedBox(height: 120), // Spacing for sticky bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.editorialBackground,
          border: Border(top: BorderSide(color: AppColors.editorialDivider)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    final int? dbId = resultData?['patientid'];
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    
                    if (dbId == null || dbId == 0) {
                      // Quick Scan flow
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanSessionScreen(
                            patientName: patientName,
                            patientId: patientId,
                          ),
                        ),
                      );
                    } else {
                      // Regular Scan flow
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssessmentScanScreen(
                            patientName: patientName,
                            patientId: patientId,
                            dbId: dbId,
                          ),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.editorialTextPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NEW SCAN',
                    style: TextStyle(
                      color: AppColors.editorialTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (assessmentId == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaveAssessmentScreen(
                            patientName: patientName,
                            patientId: patientId,
                            score: score.toStringAsFixed(0),
                            status: level,
                            resultData: resultData,
                            assessmentId: null,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssessmentRecommendationsScreen(
                            patientName: patientName,
                            patientId: patientId,
                            resultData: resultData!,
                            assessmentId: assessmentId,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.editorialTextPrimary,
                    foregroundColor: AppColors.editorialBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      assessmentId == null ? 'SAVE RECORD' : 'RECOMMENDATIONS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmotionBars(Map<dynamic, dynamic> emotions) {
    // Sort emotions by value descending
    final sortedKeys = emotions.keys.toList()
      ..sort((a, b) => (emotions[b] as num).compareTo(emotions[a] as num));

    return sortedKeys.map((key) {
      final String label = key.toString().toUpperCase();
      final double value = (emotions[key] as num).toDouble();
      // Update to 4 decimal places as requested
      final double displayValue = value;
      Color color = AppColors.editorialTextSecondary;
      
      switch (label) {
        case 'NEUTRAL': color = AppColors.emotionNeutral; break;
        case 'HAPPY': color = AppColors.emotionHappy; break;
        case 'SAD': color = AppColors.emotionSad; break;
        case 'ANGRY': color = AppColors.emotionAngry; break;
        case 'FEAR': color = AppColors.emotionFear; break;
        case 'SURPRISE': color = AppColors.emotionSurprise; break;
        case 'DISGUST': color = Colors.brown; break;
      }

      return _buildEmotionRow(label, displayValue, color);
    }).toList();
  }

  Color _getStatusColor(String level) {
    switch (level.toLowerCase()) {
      case 'low': return AppColors.anxietyLow;
      case 'moderate': return AppColors.anxietyModerate;
      case 'high': return AppColors.anxietyHigh;
      default: return AppColors.anxietyLow;
    }
  }

  Widget _buildEmotionRow(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.editorialTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(4)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.editorialTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 2,
              backgroundColor: AppColors.editorialDivider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String range, String title, String badge, Color color, Color bgColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              range,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.editorialTextSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
