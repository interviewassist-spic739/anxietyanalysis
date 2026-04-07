import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/pdf_service.dart';
import 'save_assessment_screen.dart';
import 'dashboard_screen.dart';

class AssessmentRecommendationsScreen extends StatelessWidget {
  final String patientName;
  final String patientId;
  final Map<String, dynamic>? resultData;
  final int? assessmentId;

  const AssessmentRecommendationsScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    this.resultData,
    this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
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
          'AnxiSense',
          style: TextStyle(
            color: AppColors.editorialTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
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
                radius: 18,
                backgroundColor: AppColors.editorialCardBackground,
                child: Icon(Icons.person_outline, color: AppColors.editorialTextPrimary, size: 20),
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
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1B2144)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'AI Recommendation',
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
            ),
            const SizedBox(height: 32),
            // Score Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'AI-GENERATED ANXIETY SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Gauge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
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
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: AppColors.editorialTextPrimary,
                            ),
                          ),
                          Text(
                            'out of 100',
                            style: TextStyle(
                              fontSize: 16,
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
                    'The AI detected ${(resultData?['anxiety_level'] ?? 'LOW').toLowerCase()} physiological stress markers consistent with facial patterns.',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bar_chart, color: Color(0xFF1B2144), size: 18),
                      SizedBox(width: 12),
                      Text(
                        'EMOTION ANALYSIS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (resultData?['emotions'] != null && (resultData!['emotions'] as Map).isNotEmpty) ...[
                    Row(
                      children: [
                        const Text(
                          'Dominant: ',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (resultData!['emotions'] as Map<String, dynamic>).entries
                              .reduce((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) => 
                                (a.value as num) > (b.value as num) ? a : b)
                              .key.toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.editorialTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Date of Analysis:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateTime.now().toString().substring(0, 16),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Anxiety Scale Guide
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF8FAFC), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.editorialTextSecondary, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'ANXIETY SCALE LEVEL GUIDE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.editorialTextSecondary,
                          letterSpacing: 1,
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
            const SizedBox(height: 120),
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
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    await PdfService.generateAndSaveReport(
                      patientName: patientName,
                      patientId: patientId,
                      score: (resultData?['anxiety_score'] ?? 0).toStringAsFixed(0),
                      status: resultData?['anxiety_level'] ?? 'LOW',
                      resultData: resultData,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.editorialTextPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('EXPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: assessmentId == null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SaveAssessmentScreen(
                                patientName: patientName,
                                patientId: patientId,
                                score: (resultData?['anxiety_score'] ?? 0).toStringAsFixed(0),
                                status: resultData?['anxiety_level'] ?? 'LOW',
                                resultData: resultData,
                                assessmentId: assessmentId,
                              ),
                            ),
                          );
                        }
                      : () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.editorialTextPrimary,
                    foregroundColor: AppColors.editorialBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    assessmentId == null ? 'SAVE RECORD' : 'DASHBOARD',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String level) {
    switch (level.toLowerCase()) {
      case 'low': return AppColors.anxietyLow;
      case 'moderate': return AppColors.anxietyModerate;
      case 'high': return AppColors.anxietyHigh;
      default: return AppColors.anxietyLow;
    }
  }


  List<Widget> _buildEmotionBars(Map<dynamic, dynamic> emotions) {
    // Sort emotions by value descending
    final sortedKeys = emotions.keys.toList()
      ..sort((a, b) => (emotions[b] as num).compareTo(emotions[a] as num));

    return sortedKeys.map((key) {
      final String label = key.toString().toUpperCase();
      final double value = (emotions[key] as num).toDouble();
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
    }).toList().cast<Widget>();
  }

  Widget _buildEmotionRow(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.editorialTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(4)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.editorialTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.editorialDivider.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
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
                fontSize: 10,
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
