import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_bar,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Pool OS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'HLV cá nhân cho người chơi Bi-a',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Features
              _buildFeature(
                context,
                Icons.psychology,
                'AI Coach thông minh',
              ),
              const SizedBox(height: 12),
              _buildFeature(
                context,
                Icons.trending_up,
                'Theo dõi tiến bộ',
              ),
              const SizedBox(height: 12),
              _buildFeature(
                context,
                Icons.schedule,
                'Tập 15 phút mỗi ngày',
              ),
              const Spacer(),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/assessment');
                  },
                  child: const Text('Bắt đầu'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
