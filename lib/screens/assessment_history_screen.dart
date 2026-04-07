import 'package:flutter/material.dart';
import 'analysis_detail_screen.dart';
import 'dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../services/assessment_service.dart';
import '../services/user_session.dart';

class AssessmentHistoryScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final int patientDbId;

  const AssessmentHistoryScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.patientDbId,
  });

  @override
  State<AssessmentHistoryScreen> createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  List<dynamic> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final int? doctorId = await UserSession.getDoctorId();
    final result = await AssessmentService().getAssessments(
      patientId: widget.patientDbId,
      doctorId: doctorId,
    );
    if (result['success'] == true) {
      setState(() {
        _assessments = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment History',
              style: TextStyle(
                color: AppColors.editorialTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${widget.patientName.toUpperCase()} | ID: ${widget.patientId}',
              style: const TextStyle(
                color: AppColors.editorialTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.editorialTextPrimary))
            : _assessments.isEmpty
                ? const Center(
                    child: Text(
                      'No clinical records found.',
                      style: TextStyle(color: AppColors.editorialTextSecondary),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ListView.builder(
                      itemCount: _assessments.length,
                      itemBuilder: (context, index) {
                        final a = _assessments[index];
                        return _buildHistoryCard(
                          context,
                          widget.patientName,
                          a,
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String name, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisDetailScreen(
                patientName: name,
                patientId: widget.patientId,
                score: '${data['anxiety_score']}%',
                status: data['anxiety_level'] ?? 'LOW',
                resultData: data,
                showActionButtons: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.editorialCardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.editorialBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.editorialTextPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.editorialTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (data['created_at'] ?? 'N/A').toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.editorialTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data['anxiety_score']}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.editorialBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.getAnxietyColor(data['anxiety_level'] ?? 'Low')),
                    ),
                    child: Text(
                      (data['anxiety_level'] ?? 'Low').toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.getAnxietyColor(data['anxiety_level'] ?? 'Low'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
