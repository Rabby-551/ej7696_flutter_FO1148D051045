import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Manas!',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              Text(
                'manas@gmail.com',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is your home screen. You can add your content here.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
