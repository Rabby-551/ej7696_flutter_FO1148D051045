import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if user has token and is logged in
    final token = await _storageService.getToken();
    final isLoggedIn = await _storageService.isLoggedIn();
    
    debugPrint('🔍 Splash Screen - Auth Check:');
    debugPrint('   Token: ${token != null ? "Exists" : "Not found"}');
    debugPrint('   Is Logged In: $isLoggedIn');
    
    if (mounted) {
      if (token != null && token.isNotEmpty && isLoggedIn) {
        // User is authenticated, go to home screen
        debugPrint('✅ User authenticated - Navigating to home screen');
        context.go('/home');
      } else {
        // User is not authenticated, go to login screen
        debugPrint('❌ User not authenticated - Navigating to login screen');
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_screen.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient background if image not found
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundGradientStart,
                        AppColors.backgroundGradientEnd,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
  
      
      
        ],
      ),
    );
  }
}
