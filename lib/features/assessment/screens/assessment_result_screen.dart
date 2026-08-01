import 'package:flutter/material.dart';
import '../../../core/models/assessment.dart';
import '../../../core/theme/app_theme.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)!.settings.arguments as AssessmentResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coach greeting
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coach',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'AI Coach',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chào bạn!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dựa trên câu trả lời, mình đã hiểu về bạn:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Player info
              _buildInfoCard(
                context,
                icon: Icons.person,
                title: 'Trình độ',
                value: _getLevelName(result.playerLevel),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                icon: Icons.warning_amber,
                title: 'Vấn đề chính',
                value: _getPainName(result.painType),
                subtitle: 'Mức độ: ${result.painIntensity}/10',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                icon: Icons.flag,
                title: 'Mục tiêu đề xuất',
                value: result.goalName,
                subtitle: 'Bước đầu tiên để tiến bộ',
              ),
              const Spacer(),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/coach');
                  },
                  child: const Text('Tiếp tục'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelName(String level) {
    switch (level) {
      case 'beginner':
        return 'Người mới bắt đầu';
      case 'casual':
        return 'Người chơi thỉnh thoảng';
      case 'regular':
        return 'Người chơi thường xuyên';
      default:
        return 'Người mới bắt đầu';
    }
  }

  String _getPainName(String pain) {
    switch (pain) {
      case 'miss_despite_aim':
        return 'Khó đánh trúng bi';
      case 'inconsistent_potting':
        return 'Đánh không ổn định';
      default:
        return 'Khó đánh trúng bi';
    }
  }
}
