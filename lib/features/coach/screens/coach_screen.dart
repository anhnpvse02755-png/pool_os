import 'package:flutter/material.dart';
import '../../../core/models/assessment.dart';
import '../../../core/models/recommendation.dart';
import '../../../core/theme/app_theme.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get assessment result from previous screen
    final result = ModalRoute.of(context)!.settings.arguments as AssessmentResult;

    // Sprint 1: Hardcoded recommendation
    final recommendation = Recommendation(
      goalId: 'pot_first_ball',
      goalName: 'Pot First Ball',
      knowledgeId: 'know_ghost_ball',
      knowledgeName: 'Ghost Ball',
      drillId: 'drill_pot_basic',
      drillName: 'Pot cơ bản',
      videoId: 'video_ghost_ball',
      videoSegment: '0:00-2:00',
      durationMinutes: _getDuration(result.answers.q5Time),
      confidence: 0.9,
      reason: 'Đây là bước đầu tiên để học đánh bi-a. '
          'Bạn cần biết cách nhắm và đánh trúng bi trước.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coach card
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                      recommendation.reason,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Goal
              _buildRecommendationCard(
                context,
                icon: Icons.flag,
                title: 'Mục tiêu',
                value: recommendation.goalName,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              // Drill
              _buildRecommendationCard(
                context,
                icon: Icons.fitness_center,
                title: 'Bài tập',
                value: recommendation.drillName,
                subtitle: '${recommendation.durationMinutes} phút',
                color: AppTheme.success,
              ),
              const SizedBox(height: 12),
              // Knowledge
              _buildRecommendationCard(
                context,
                icon: Icons.lightbulb,
                title: 'Kiến thức',
                value: recommendation.knowledgeName,
                subtitle: 'Hiểu trước khi tập',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              // Video
              _buildRecommendationCard(
                context,
                icon: Icons.play_circle,
                title: 'Video',
                value: 'Ghost Ball Demo',
                subtitle: 'Xem trước 2 phút',
                color: Colors.purple,
              ),
              const Spacer(),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/session',
                      arguments: recommendation,
                    );
                  },
                  child: const Text('Bắt đầu tập'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  int _getDuration(String q5Time) {
    switch (q5Time) {
      case '5-10m':
        return 10;
      case '15-20m':
        return 15;
      case '30m+':
        return 30;
      default:
        return 15;
    }
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
}
