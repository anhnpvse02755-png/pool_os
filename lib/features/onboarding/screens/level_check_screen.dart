import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LevelCheckScreen extends StatefulWidget {
  const LevelCheckScreen({super.key});

  @override
  State<LevelCheckScreen> createState() => _LevelCheckScreenState();
}

class _LevelCheckScreenState extends State<LevelCheckScreen> {
  String? _selectedLevel;

  final List<Map<String, dynamic>> _levels = [
    {
      'value': 'newbie',
      'label': 'Mới tập chơi',
      'icon': Icons.emoji_people,
      'desc': 'Chưa biết đánh hoặc đánh được vài cú',
    },
    {
      'value': 'casual',
      'label': 'Chơi giải trí',
      'icon': Icons.sports_bar,
      'desc': 'Đánh được nhưng chưa chuyên',
    },
    {
      'value': 'regular',
      'label': 'Chơi thường xuyên',
      'icon': Icons.emoji_events,
      'desc': 'Đánh tốt, muốn cải thiện kỹ năng',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác định trình độ'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn là ai?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn trình độ phù hợp để Coach đưa ra bài tập phù hợp với bạn.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final isSelected = _selectedLevel == level['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLevel = level['value'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                level['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['label'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level['desc'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/assessment',
                            arguments: {'level': _selectedLevel},
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 18),
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
