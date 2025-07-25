import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iu_job_assessment/main.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // trigger form validation on input change
    _nameController.addListener(_validateForm);
    _roleController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  // Basic form validation
  void _validateForm() {
    final bool isValid =
        _nameController.text.isNotEmpty && _roleController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.surface,
                child: SvgPicture.asset(
                  'assets/svgs/Avatar Wrapper.svg',
                  height: 96,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome! Let’s set up your account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "If you upload an avatar image above, it won’t preview here, it will appear only after form is submitted.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary),
              ),

              const SizedBox(height: 32),

              // Name field
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Name", style: _labelStyle),
              ),
              const SizedBox(height: 8),
              _buildTextField(_nameController),

              const SizedBox(height: 24),

              // Role field
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Role", style: _labelStyle),
              ),
              const SizedBox(height: 8),
              _buildTextField(_roleController),

              const SizedBox(height: 12),
              const Text(
                "Demo only – in real example, this would be manually\nassigned / controlled via Workspace or admin interface.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isFormValid
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  // Dirty hack for state managment for now
                  backgroundColor: _isFormValid
                      ? AppColors.primary
                      : AppColors.surface,
                  foregroundColor: _isFormValid
                      ? AppColors.background
                      : AppColors.textSecondary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 48),
                ),

                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Value',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
