import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/pdf_service.dart';

class PostSaveReportScreen extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String score;
  final String status;
  final Map<String, dynamic>? resultData;

  const PostSaveReportScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.score,
    required this.status,
    this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't show back button on final screen
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
            icon: const Icon(Icons.share_outlined, color: AppColors.editorialTextPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Section
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'Final Report',
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
            
            // Score Summary Card (Matching recommendations screen)
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
                          value: (double.tryParse(score) ?? 0) / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.editorialDivider,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.getAnxietyColor(status)),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            score,
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: AppColors.editorialTextPrimary,
                            ),
                          ),
                          const Text(
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
                      border: Border.all(color: AppColors.getAnxietyColor(status), width: 2),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.getAnxietyColor(status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'The assessment has been successfully logged into the clinical record for future reference.',
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
            
            // Emotion Analysis Section (Mirrored from Recommendations)
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
                  ..._buildEmotionBars(resultData?['emotions'] ?? {}),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Clinical Scale Guide (Matching recommendations screen)
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
                      const Text(
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
                      score: score,
                      status: status,
                      resultData: resultData,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.editorialTextPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('SAVE TO PDF', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                  child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
      final double roundedValue = value.roundToDouble();
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

      return _buildEmotionRow(label, roundedValue, color);
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
                '${percentage.toInt()}%',
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
