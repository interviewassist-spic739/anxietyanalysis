import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Leaf Icon Logo - Styled to match the black minimalist leaf
                    Image.asset(
                      'assets/images/leaf_icon.png',
                      height: 80, // Slightly larger and only one dimension to keep aspect ratio
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    // Title - AnxietySense
                    const Text(
                      'AnxietySense',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.editorialTextPrimary,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle - CLINICAL ANALYSIS SUITE
                    Text(
                      'CLINICAL ANALYSIS SUITE',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.editorialTextSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Login Card - Light grey container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      decoration: BoxDecoration(
                        color: AppColors.editorialCardBackground,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Professional Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Email Field - White, rounded, bold hint
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: AppColors.editorialTextPrimary, 
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: 'doctor@hospital.org',
                              hintStyle: TextStyle(
                                color: AppColors.editorialTextSecondary.withOpacity(0.3), 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Continue Button - Solid black, large radius
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () async {
                                String email = _emailController.text.trim();
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter your email')),
                                  );
                                  return;
                                }

                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator()),
                                );

                                final result = await AuthService().sendOtp(email);
                                
                                if (mounted) Navigator.pop(context); // Hide loading

                                if (result['success'] == true) {
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtpScreen(email: email),
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
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Continue Securely',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Footer - Colored Icons as seen in the image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, color: Color(0xFFFFC107), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'HIPAA Compliant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.editorialTextSecondary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.medical_services, color: Color(0xFF9C27B0), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Medical Grade',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.editorialTextSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
