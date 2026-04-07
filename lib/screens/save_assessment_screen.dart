import 'package:flutter/material.dart';
import 'post_save_report_screen.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import '../services/assessment_service.dart';
import '../services/patient_service.dart';
import '../services/user_session.dart';
import 'dart:convert';

class SaveAssessmentScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String score;
  final String status;
  final String? imagePath;
  final Map<String, dynamic>? resultData;
  final int? assessmentId;

  const SaveAssessmentScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.score,
    required this.status,
    this.imagePath,
    this.resultData,
    this.assessmentId,
  });

  @override
  State<SaveAssessmentScreen> createState() => _SaveAssessmentScreenState();
}

class _SaveAssessmentScreenState extends State<SaveAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idController;
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Select';
  String _selectedProcedure = 'Select procedure type';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _healthIssuesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patientName);
    _idController = TextEditingController(text: widget.patientId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    _healthIssuesController.dispose();
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
              'Finalize Record',
              style: TextStyle(
                color: AppColors.editorialTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'SECURE CLINICAL FILING',
              style: TextStyle(
                color: AppColors.editorialTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.editorialCardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.editorialTextPrimary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Patient ID *'),
                      _buildTextField(_idController, hint: 'e.g. P1001'),
                      const SizedBox(height: 20),
                      
                      _buildLabel('Full Name *'),
                      _buildTextField(_nameController, hint: 'Patient name'),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Age *'),
                                _buildTextField(_ageController, hint: 'Age'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Gender'),
                                _buildDropdown(['Select', 'Male', 'Female', 'Other'], _selectedGender, (v) => setState(() => _selectedGender = v!)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Procedure Type'),
                      _buildDropdown(
                        ['Select procedure type', 'Routine Checkup', 'Stress Evaluation', 'Post-Op Anxiety'],
                        _selectedProcedure,
                        (v) => setState(() => _selectedProcedure = v!),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Health Issues'),
                      _buildTextField(_healthIssuesController, hint: 'Note any health issues, allergies, or relevant medical history', maxLines: 3),
                      const SizedBox(height: 20),

                      _buildLabel('Anxiety History / Notes'),
                      _buildTextField(_notesController, hint: 'Note any previous anxiety episodes or general clinical observations...', maxLines: 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Compliance Note
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.editorialBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.editorialDivider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: AppColors.editorialTextSecondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PATIENT DATA IS ENCRYPTED AND STORED ON SECURE INFRASTRUCTURE.',
                        style: TextStyle(
                          color: AppColors.editorialTextSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.editorialTextPrimary,
                          side: const BorderSide(color: AppColors.editorialTextPrimary, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.editorialTextPrimary,
                          foregroundColor: AppColors.editorialBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SAVE RECORD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary),
      ),
    );
  }

  Widget _buildTextField(TextEditingController? controller, {String? hint, int maxLines = 1, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.editorialTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.editorialTextSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: AppColors.editorialBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.editorialDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.editorialDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.editorialTextPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _saveRecord() async {
    final String enteredPatientId = _idController.text.trim();
    if (enteredPatientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Patient ID.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final int? doctorId = await UserSession.getDoctorId();
      if (doctorId == null) {
        throw Exception('Doctor session not found. Please log in again.');
      }

      final updateData = {
        'procedure_type': _selectedProcedure == 'Select procedure type' ? null : _selectedProcedure,
        'health_issues': _healthIssuesController.text.trim().isEmpty ? null : _healthIssuesController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      if (widget.assessmentId != null) {
        // CASE: Standard update flow
        final result = await AssessmentService().updateAssessment(widget.assessmentId!, updateData);
        if (mounted) {
          if (result['success'] == true) _navigateToReport();
          else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Failed to update.')));
        }
      } else {
        // CASE: Quick assessment save flow (New Record)
        // 1. Resolve Patient ID to dbId
        final patientsResult = await PatientService().getPatients(doctorId);
        int? resolvedPatientDbId;
        
        if (patientsResult['success'] == true) {
          final List patients = patientsResult['data'] ?? [];
          final match = patients.firstWhere(
            (p) => (p['patientid'] ?? p['patient_id'] ?? '').toString().toLowerCase() == enteredPatientId.toLowerCase(),
            orElse: () => <String, dynamic>{},
          );
          if (match.isNotEmpty) {
            resolvedPatientDbId = match['id'];
          } else {
            // AUTO-CREATE PATIENT
            final String enteredName = _nameController.text.trim();
            if (enteredName.isEmpty) {
              throw Exception('Please enter a Full Name to register this new patient.');
            }
            
            final createResult = await PatientService().createPatient({
              'patient_id': enteredPatientId,
              'fullname': enteredName,
              'doctorid': doctorId,
              'age': int.tryParse(_ageController.text) ?? 30,
              'gender': _selectedGender == 'Select' ? 'Other' : _selectedGender,
            });
            
            if (createResult['success'] == true) {
              resolvedPatientDbId = createResult['data']?['id'] ?? createResult['id'];
            } else {
              throw Exception('Could not register patient: ${createResult['message']}');
            }
          }
        }

        // 2. Prepare full save payload
        final saveData = {
          'patientid': resolvedPatientDbId,
          'doctorid': doctorId,
          'anxiety_score': double.tryParse(widget.score) ?? 0.0,
          'anxiety_level': widget.status,
          'dominant_emotion': widget.resultData?['dominant_emotion'],
          'emotions': widget.resultData?['emotions'] ?? {},
          'status': 'COMPLETED', // Mark as finalized
          ...updateData,
        };

        final result = await AssessmentService().saveAssessment(saveData);
        if (mounted) {
          if (result['success'] == true) _navigateToReport();
          else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Failed to save.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _navigateToReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostSaveReportScreen(
          patientName: widget.patientName,
          patientId: widget.patientId,
          score: widget.score,
          status: widget.status,
          resultData: widget.resultData,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.editorialBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.editorialDivider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.editorialTextPrimary),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: AppColors.editorialTextPrimary, fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.editorialBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.editorialDivider)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.anxietyLow, size: 64),
            const SizedBox(height: 24),
            const Text(
              'ASSESSMENT SAVED',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.editorialTextPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Patient records have been updated successfully and synced to clinical storage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.editorialTextPrimary,
                  foregroundColor: AppColors.editorialBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('BACK TO DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
