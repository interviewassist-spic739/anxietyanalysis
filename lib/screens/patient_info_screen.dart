import 'package:flutter/material.dart';
import 'assessment_scan_screen.dart';
import '../theme/app_colors.dart';
import '../services/patient_service.dart';
import '../services/user_session.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _ageController = TextEditingController();
  final _healthIssuesController = TextEditingController();
  final _anxietyHistoryController = TextEditingController();
  String? _selectedGender;
  String? _selectedProcedure;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    _healthIssuesController.dispose();
    _anxietyHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Intake',
              style: TextStyle(
                color: AppColors.editorialTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'SECURE CLINICAL DATA ENTRY',
              style: TextStyle(
                color: AppColors.editorialTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: const Icon(Icons.person_outline, color: AppColors.editorialTextPrimary, size: 40),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField('Patient ID *', 'e.g., P001234', _idController, validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 20),
                      _buildInputField('Full Name *', "Enter patient's full name", _nameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildInputField('Age *', 'Age', _ageController, validator: (v) => v!.isEmpty ? 'Req' : null)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField('Gender', 'Select', [
                              'Male',
                              'Female',
                              'Other'
                            ], _selectedGender, (v) => setState(() => _selectedGender = v)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField('Procedure Type', 'Select procedure type', [
                        'Routine Checkup',
                        'Pre-Surgery',
                        'Post-Surgery',
                        'Therapy Session'
                      ], _selectedProcedure, (v) => setState(() => _selectedProcedure = v)),
                      const SizedBox(height: 20),
                      _buildInputField('Health Issues', 'Note any health issues...', _healthIssuesController, maxLines: 4),
                      const SizedBox(height: 20),
                      _buildInputField('Previous Anxiety History', 'Note any previous anxiety episodes...', _anxietyHistoryController, maxLines: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Note Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.editorialBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.editorialDivider),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: AppColors.editorialTextSecondary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Patient information is fully encrypted and stored securely in compliance with HIPAA and healthcare data regulations.',
                          style: TextStyle(
                            color: AppColors.editorialTextSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
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
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.editorialTextPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: AppColors.editorialTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator()),
                              );

                              final doctorId = await UserSession.getDoctorId();
                              
                              final patientData = {
                                'doctorid': doctorId,
                                'patientid': _idController.text.trim(),
                                'fullname': _nameController.text.trim(),
                                'age': _ageController.text.trim(),
                                'gender': _selectedGender,
                                'proceduretype': _selectedProcedure,
                                'healthissue': _healthIssuesController.text.trim(),
                                'previousanxietyhistory': _anxietyHistoryController.text.trim(),
                              };

                              final result = await PatientService().createPatient(patientData);

                              if (mounted) Navigator.pop(context); // Hide loading

                              if (result['success'] == true) {
                                final int dbId = result['data']['id'];
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssessmentScanScreen(
                                        patientName: _nameController.text.trim(),
                                        patientId: _idController.text.trim(),
                                        dbId: dbId,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.editorialTextPrimary,
                            foregroundColor: AppColors.editorialBackground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'START SCAN',
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

  Widget _buildInputField(String label, String hint, TextEditingController controller, {int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.editorialTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.editorialTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.editorialTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.editorialBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.editorialDivider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(color: AppColors.editorialTextSecondary, fontSize: 13)),
              isExpanded: true,
              decoration: const InputDecoration(border: InputBorder.none),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
              validator: (v) => v == null ? 'Required' : null,
            ),
          ),
        ),
      ],
    );
  }
}
