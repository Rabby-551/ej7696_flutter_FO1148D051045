
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/app_logo_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint('=== Login Started ===');
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed');
      return;
    }
    debugPrint('✅ Form validation passed');

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    debugPrint('📤 Login Request Data:');
    debugPrint('   Email: $email');
    debugPrint('   Password: ${password.length} characters');

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Calling API: /api/v1/auth/login');
      
      final response = await _apiService.login(
        email: email,
        password: password,
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
        debugPrint('✅ Login successful!');
        debugPrint('   Access Token: ${response.data?.accessToken != null ? "Saved" : "Missing"}');
        debugPrint('   Refresh Token: ${response.data?.refreshToken != null ? "Saved" : "Missing"}');
        debugPrint('   User ID: ${response.data?.userId}');
        debugPrint('   Role: ${response.data?.role}');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home screen
        if (context.mounted) {
          debugPrint('🔄 Navigating to home screen...');
          context.go('/home');
        }
      } else {
        debugPrint('❌ Login failed');
        debugPrint('   Error Message: ${response.message}');
        debugPrint('   Error Details: ${response.error}');
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Login failed. Please check your credentials.'),
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
      
      debugPrint('❌ Exception occurred during login:');
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
    
    debugPrint('=== Login Completed ===');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GradientBackground(
        useImage: false,
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

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Login',
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
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

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

                  const SizedBox(height: 16),

                  // Remember me and Forgot password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.primaryBlue,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Forgot password link
                      GestureDetector(
                        onTap: () => context.go('/forget-password'),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.textLink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign in Button
                  PrimaryButton(
                    text: 'Sign in',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                    borderRadius: 30,
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/sign-up'),
                        child: const Text(
                          'Sign Up Here',
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
