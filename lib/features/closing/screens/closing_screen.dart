import 'package:flutter/material.dart';
import '../../../core/models/reflection.dart';
import '../../../core/theme/app_theme.dart';

class ClosingScreen extends StatelessWidget {
  const ClosingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reflection = ModalRoute.of(context)!.settings.arguments as ReflectionResult;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 60,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hoàn thành! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn đã hoàn thành bài tập đầu tiên!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Next Best Action
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ngày mai',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tiếp tục Pot First Ball',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '10 phút thôi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tập trung vào Ghost Ball, '
                              'đừng nản nếu chưa quen.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem(
                    icon: Icons.emoji_events,
                    value: '7/10',
                    label: 'Kết quả',
                  ),
                  _buildSummaryItem(
                    icon: Icons.sentiment_satisfied,
                    value: _getEnjoymentEmoji(reflection.enjoymentScore),
                    label: _getEnjoymentText(reflection.enjoyment),
                  ),
                  _buildSummaryItem(
                    icon: Icons.repeat,
                    value: '1',
                    label: 'Ngày streak',
                  ),
                ],
              ),
              const Spacer(),
              // Do you want to continue
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save to memory and close
                    _showCompletionDialog(context);
                  },
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Cảm ơn bạn đã tập cùng Pool OS! 💪',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getEnjoymentEmoji(int score) {
    switch (score) {
      case 5:
        return '😍';
      case 4:
        return '😊';
      case 3:
        return '😐';
      case 2:
        return '😕';
      default:
        return '😐';
    }
  }

  String _getEnjoymentText(String? enjoyment) {
    switch (enjoyment) {
      case 'love':
        return 'Rất thích';
      case 'like':
        return 'Thích';
      case 'neutral':
        return 'Bình thường';
      case 'dislike':
        return 'Không thích';
      default:
        return 'Bình thường';
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành!'),
        content: const Text(
          'Buổi tập đã được lưu. Hẹn gặp bạn ngày mai!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to home
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
