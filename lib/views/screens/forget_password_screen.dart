import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/app_logo_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    debugPrint('=== Forgot Password Started ===');
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed');
      return;
    }
    debugPrint('✅ Form validation passed');

    final email = _emailController.text.trim();
    debugPrint('📤 Forgot Password Request Data:');
    debugPrint('   Email: $email');

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Calling API: /api/v1/auth/forget');
      
      final response = await _apiService.forgotPassword(
        email: email,
      );

      setState(() {
        _isLoading = false;
      });

      debugPrint('📥 API Response Received:');
      debugPrint('   Success: ${response.success}');
      debugPrint('   Message: ${response.message}');
      debugPrint('   Data: ${response.data}');
      debugPrint('   Error: ${response.error}');

      if (response.success) {
        debugPrint('✅ OTP sent successfully!');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'OTP sent to your email successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to verify OTP screen with email and password reset flag
        if (context.mounted) {
          debugPrint('🔄 Navigating to verify OTP screen...');
          debugPrint('   Email: $email');
          debugPrint('   IsForPasswordReset: true');
          
          context.go('/verify-otp', extra: {
            'email': email,
            'isForPasswordReset': true,
          });
        }
      } else {
        debugPrint('❌ Forgot password failed');
        debugPrint('   Error Message: ${response.message}');
        debugPrint('   Error Details: ${response.error}');
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to send OTP. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      
      debugPrint('❌ Exception occurred during forgot password:');
      debugPrint('   Error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
    
    debugPrint('=== Forgot Password Completed ===');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
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
                          context.go('/login');
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Logo and App Name
                  const AppLogoHeader(),

                  const SizedBox(height: 60),

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

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Enter your email to receive the OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your Email',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 50),

                  // Send OTP Button
                  PrimaryButton(
                    text: 'Send OTP',
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    isLoading: _isLoading,
                    borderRadius: 30,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
