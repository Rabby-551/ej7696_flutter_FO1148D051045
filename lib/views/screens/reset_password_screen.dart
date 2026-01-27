import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? otp;

  const ResetPasswordScreen({super.key, this.email, this.otp});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;



  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Content on top of background
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go('/verify-otp');
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Logo and App Name
                    const AppLogoHeader(),

                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Reset password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Set New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your Password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirm Password Field
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Enter your Password',
                      prefixIcon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    PrimaryButton(
                      text: 'Continue',
                      onPressed:() async {
                 
                      },
                      isLoading: false,
                      borderRadius: 30,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
