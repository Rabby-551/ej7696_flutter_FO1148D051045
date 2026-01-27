import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/app_logo_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    debugPrint('=== Sign Up Started ===');
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed');
      return;
    }
    debugPrint('✅ Form validation passed');

    // Check terms agreement
    if (!_agreeToTerms) {
      debugPrint('❌ Terms & Conditions not agreed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    debugPrint('✅ Terms & Conditions agreed');

    // Prepare request data
    final requestData = {
      'phone': _phoneController.text.trim(),
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
    };
    
    debugPrint('📤 Registration Request Data:');
    debugPrint('   Phone: ${requestData['phone']}');
    debugPrint('   Name: ${requestData['name']}');
    debugPrint('   Email: ${requestData['email']}');
    debugPrint('   Password: ${requestData['password']?.length} characters');
    debugPrint('   Confirm Password: ${requestData['confirmPassword']?.length} characters');

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Calling API: /api/v1/auth/register');
      
      final response = await _apiService.register(
        phone: requestData['phone']!,
        name: requestData['name']!,
        email: requestData['email']!,
        password: requestData['password']!,
        confirmPassword: requestData['confirmPassword']!,
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
        debugPrint('✅ Registration successful!');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login screen
        if (context.mounted) {
          debugPrint('🔄 Navigating to login screen...');
          context.go('/login');
        }
      } else {
        debugPrint('❌ Registration failed');
        debugPrint('   Error Message: ${response.message}');
        debugPrint('   Error Details: ${response.error}');
        
        // Show error message with better formatting
        final errorMessage = response.message ?? 'Registration failed. Please try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontSize: 14),
            ),
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
      
      debugPrint('❌ Exception occurred during registration:');
      debugPrint('   Error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    debugPrint('=== Sign Up Completed ===');
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
                          context.go('/onboarding');
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

                  // Name Field
                  CustomTextField(
                    label: 'Name',
                    hint: 'Enter your Full Name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 24),

                  // Phone Number Field
                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'Enter your Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

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
                    hint: 'Confirm a Password',
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

                  const SizedBox(height: 16),

                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms Conditions & Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.textLink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: AppColors.textLink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Button
                  PrimaryButton(
                    text: 'Sign up',
                    onPressed: _isLoading ? null : _handleSignUp,
                    isLoading: _isLoading,
                    borderRadius: 30,
                  ),

                  const SizedBox(height: 24),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Sign in Here',
                          style: TextStyle(
                            color: AppColors.textLink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
