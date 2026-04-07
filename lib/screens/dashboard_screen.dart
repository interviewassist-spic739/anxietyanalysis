import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'assessment_history_screen.dart';
import 'patient_info_screen.dart';
import 'scan_session_screen.dart';
import '../theme/app_colors.dart';
import '../services/doctor_service.dart';
import '../services/patient_service.dart';
import '../services/user_session.dart';
import 'package:dio/dio.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late int _selectedIndex;
  int _doctorId = 0;
  String _doctorName = "Doctor";
  String? _profilePhotoUrl;
  Map<String, dynamic> _doctorProfile = {
    'fullname': 'Doctor',
    'specialization': 'Specialist',
    'clinic_name': 'Clinic',
    'phone': '',
    'profile_photo': null,
  };
  Map<String, dynamic> _stats = {
    'total': '0',
    'today': '0',
    'accuracy': '0%'
  };

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  int _currentPage = 1;
  int _itemsPerPage = 20; // Limited to 20
  bool _isLoading = true;
  DateTime? _selectedFilterDate; // Added for calendar filtering

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    _doctorId = await UserSession.getDoctorId() ?? 0;
    _doctorName = await UserSession.getDoctorName() ?? "Doctor";
    
    if (_doctorId != 0) {
      await Future.wait([
        _fetchStats(),
        _fetchPatients(),
        _fetchProfile(),
      ]);
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    final result = await DoctorService().getProfile(_doctorId);
    if (result['success'] == true) {
      setState(() {
        _doctorProfile = result['data'];
        _profilePhotoUrl = _doctorProfile['profile_photo'];
        
        // Populate controllers
        _nameController.text = _doctorProfile['fullname'] ?? '';
        _specController.text = _doctorProfile['specialization'] ?? '';
        _clinicController.text = _doctorProfile['clinic_name'] ?? '';
        _phoneController.text = _doctorProfile['phone'] ?? '';
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading profile photo...')),
    );

    final result = await DoctorService().uploadProfilePhoto(_doctorId, File(image.path));

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _profilePhotoUrl = result['profile_photo'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to upload photo')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final result = await DoctorService().updateProfile({
      'doctorid': _doctorId,
      'fullname': _nameController.text,
      'specialization': _specController.text,
      'clinic_name': _clinicController.text,
      'phone': _phoneController.text,
    });
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      await _fetchProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Update failed')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchStats() async {
    final result = await DoctorService().getDashboardStats(_doctorId);
    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _stats = {
          'total': data['total'].toString(),
          'today': data['today'].toString(),
          'accuracy': data['accuracy'].toString(),
        };
      });
    }
  }

  Future<void> _fetchPatients() async {
    if (_doctorId == 0) return;
    
    print('DEBUG: [DashboardScreen] FETCHING PATIENTS FOR DOCTOR ID: $_doctorId');
    final result = await PatientService().getPatients(_doctorId, limit: 500);
    
    if (mounted) {
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        print('DEBUG: [DashboardScreen] RECEIVED ${data.length} PATIENTS');
        setState(() {
          _allPatients = List<Map<String, dynamic>>.from(data);
          _applySearchAndPagination();
        });
      } else {
        print('DEBUG: [DashboardScreen] FETCH FAILED: ${result['message']}');
        setState(() {
          _allPatients = [];
          _filteredPatients = [];
        });
      }
    }
  }

  void _applySearchAndPagination() {
    String query = _searchController.text.toLowerCase();
    _filteredPatients = _allPatients.where((p) {
      // 1. Text Search Filter
      final name = (p['fullname'] ?? '').toString().toLowerCase();
      final id = (p['patientid'] ?? p['id'] ?? '').toString().toLowerCase();
      bool matchesText = name.contains(query) || id.contains(query);

      // 2. Date Filter
      bool matchesDate = true;
      if (_selectedFilterDate != null) {
        final lastScanDateStr = p['last_assessment_date'];
        if (lastScanDateStr != null && lastScanDateStr != "") {
          try {
            final DateTime dt = DateTime.parse(lastScanDateStr);
            matchesDate = dt.year == _selectedFilterDate!.year &&
                dt.month == _selectedFilterDate!.month &&
                dt.day == _selectedFilterDate!.day;
          } catch (e) {
            matchesDate = false;
          }
        } else {
          matchesDate = false;
        }
      }

      return matchesText && matchesDate;
    }).toList();
  }

  List<Map<String, dynamic>> get _pagedPatients {
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (start >= _filteredPatients.length) return [];
    return _filteredPatients.sublist(start, end > _filteredPatients.length ? _filteredPatients.length : end);
  }

  int get _totalPages => (_filteredPatients.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0 || index == 2) {
      _loadInitialData();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B2144),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedFilterDate = picked;
        _currentPage = 1;
        _applySearchAndPagination();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: (_selectedIndex == 0 || _selectedIndex == 1)
              ? AppBar(
                  backgroundColor: AppColors.editorialBackground,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false, // Removes the automatic back arrow
                  titleSpacing: 16, // Adjust this for "slight left" positioning
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/leaf_icon.png',
                        width: 24,
                        height: 24,
                        color: AppColors.editorialTextPrimary,
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'AnxiSense',
                          style: TextStyle(
                            color: AppColors.editorialTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: CircleAvatar(
                          backgroundColor: AppColors.editorialCardBackground,
                          backgroundImage: _profilePhotoUrl != null 
                              ? NetworkImage(_profilePhotoUrl!) 
                              : null,
                          child: _profilePhotoUrl == null 
                              ? const Icon(Icons.person_outline, color: AppColors.editorialTextPrimary)
                              : null,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.editorialBackground,
        selectedItemColor: AppColors.editorialTextPrimary,
        unselectedItemColor: AppColors.editorialTextSecondary,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_filled, 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.camera_alt, 1),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.assignment, 2),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person, 3),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: AppColors.editorialCardBackground,
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Icon(icon, size: 24),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildBeginAssessmentScreen();
      case 2:
        return _buildRecordsScreen();
      case 3:
        return _buildProfileScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildProfileScreen() {
    return Stack(
      children: [
        // Background Decoration Shape (Subtle curve like the image)
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.editorialCardBackground.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doctor Profile',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.editorialTextPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Account & System Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.editorialTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Profile Section Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.editorialCardBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      // Doctor Profile Photo (Interactive)
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickAndUploadPhoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.editorialCardBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.editorialDivider, width: 2),
                                ),
                                child: ClipOval(
                                  child: _profilePhotoUrl != null
                                      ? Image.network(
                                          _profilePhotoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                            const Icon(Icons.person_outline, size: 50, color: AppColors.editorialTextSecondary),
                                        )
                                      : const Icon(Icons.person_outline, size: 50, color: AppColors.editorialTextSecondary),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.editorialTextPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildProfileField('FULL NAME', '', controller: _nameController),
                      _buildProfileField('SPECIALIZATION', '', controller: _specController),
                      _buildProfileField('INSTITUTION / CLINIC', '', controller: _clinicController),
                      _buildProfileField('CONTACT NUMBER', '', controller: _phoneController),
                      _buildProfileField('EMAIL ADDRESS', _doctorProfile['email'] ?? 'N/A', isReadOnly: true),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: OutlinedButton(
                    onPressed: () async {
                      await UserSession.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Log Out Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField(String label, String value, {bool isReadOnly = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.editorialTextPrimary.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          if (isReadOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E9E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.editorialTextSecondary,
                ),
              ),
            )
          else
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.editorialTextPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordsScreen() {
    return Column(
      children: [
        // My Patients Header
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 48.0, bottom: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2144)),
                onPressed: () => _onItemTapped(0),
              ),
              const Expanded(
                child: Text(
                  'Patient Records',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.editorialTextPrimary,
                  ),
                ),
              ),
              if (_selectedFilterDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM d').format(_selectedFilterDate!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterDate = null;
                            _applySearchAndPagination();
                          });
                        },
                        child: const Icon(Icons.close, size: 14, color: Color(0xFF0D47A1)),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: _selectedFilterDate != null ? const Color(0xFF0D47A1) : const Color(0xFF1B2144),
                ),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: AppColors.editorialCardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _currentPage = 1;
                  _applySearchAndPagination();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search clinician database...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: AppColors.editorialTextPrimary, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Patient List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              if (_filteredPatients.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No results found', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                )
              else
                ..._pagedPatients.map((p) => _buildPatientCard(
                      context,
                      p['fullname'] ?? 'Generic Patient',
                      p['id']?.toString() ?? '0', // Database ID
                      p['latest_anxiety_score']?.toString() ?? '--',
                      p['latest_anxiety_level'] ?? 'New',
                      displayId: p['patientid']?.toString() ?? p['id'].toString(), // Clinical ID
                    )),
              const SizedBox(height: 24),
              
              // Pagination
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _currentPage > 1 ? _previousPage : null,
                      child: Text('Previous', style: TextStyle(color: _currentPage > 1 ? const Color(0xFF0D47A1) : const Color(0xFF94A3B8))),
                    ),
                    const SizedBox(width: 16),
                    Text('Page $_currentPage of $_totalPages', style: const TextStyle(color: Color(0xFF546E7A))),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _currentPage < _totalPages ? _nextPage : null,
                      child: Text('Next', style: TextStyle(color: _currentPage < _totalPages ? const Color(0xFF0D47A1) : const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, String name, String dbId, String percentage, String status, {String? displayId}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentHistoryScreen(
                patientName: name,
                patientId: displayId ?? dbId,
                patientDbId: int.tryParse(dbId) ?? 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                child: const Icon(Icons.person_outline, color: AppColors.editorialTextPrimary, size: 20),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${displayId ?? dbId}',
                      style: const TextStyle(
                        fontSize: 12,
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
                    percentage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.getAnxietyColor(status),
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

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Text(
              'Welcome, Dr. $_doctorName',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.editorialTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'CITY GENERAL HOSPITAL | CLINICIAN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w600,
                color: AppColors.editorialTextSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Assessment Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.editorialCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.editorialBackground,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/facial_analysis.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start New Assessment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.editorialTextPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AI-powered facial analysis',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.editorialTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientInfoScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.editorialTextPrimary,
                        foregroundColor: AppColors.editorialBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'BEGIN ASSESSMENT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Stats Header
            const Text(
              'QUICK STATS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.editorialTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats Cards
            Row(
              children: [
                _buildStatCard('Patients', _stats['today']!, 'Today', Colors.black),
                const SizedBox(width: 12),
                _buildStatCard('Accuracy', _stats['accuracy']!, 'Avg Score', AppColors.editorialTextPrimary),
                const SizedBox(width: 12),
                _buildStatCard('Total', _stats['total']!, 'Analyses', AppColors.editorialTextSecondary),
              ],
            ),
            const SizedBox(height: 32),

            // Monitoring Guidelines Header
            const Text(
              'MONITORING GUIDELINES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.editorialTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Guidelines List
            _buildGuidelineItem('Ensure patient is in neutral seated position'),
            _buildGuidelineItem('Adequate lighting for facial capture'),
            _buildGuidelineItem('Assessment before anesthetic administration'),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildBeginAssessmentScreen() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // White Card with Camera Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera body
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                  ),
                  // Lens
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  // Flash/Sparkle
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Transform.rotate(
                      angle: 0.5,
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Quick Scan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2144),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This automated scan provides a preliminary assessment based on facial expressions and psychological indicators.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanSessionScreen(
                      patientName: 'Quick Assessment',
                      patientId: 'TEMP-2464',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'BEGIN ASSESSMENT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60), // Add bottom spacing to center better visually
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2144),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00BFA5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF546E7A),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
