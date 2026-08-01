import 'package:flutter/material.dart';
import '../../../core/models/reflection.dart';
import '../../../core/theme/app_theme.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  int _currentQuestion = 0;

  // Answers
  String? _difficulty;
  String? _enjoyment;
  String? _continueReason;

  final List<_Question> _questions = [
    _Question(
      question: 'Hôm nay bạn thấy dễ hay khó?',
      options: [
        _Option(value: 'very_easy', label: 'Rất dễ'),
        _Option(value: 'easy', label: 'Dễ'),
        _Option(value: 'normal', label: 'Bình thường'),
        _Option(value: 'hard', label: 'Khó'),
        _Option(value: 'very_hard', label: 'Rất khó'),
      ],
      onSelect: (value, state) => state._difficulty = value,
    ),
    _Question(
      question: 'Bạn có thích bài tập hôm nay không?',
      options: [
        _Option(value: 'love', label: 'Rất thích'),
        _Option(value: 'like', label: 'Thích'),
        _Option(value: 'neutral', label: 'Bình thường'),
        _Option(value: 'dislike', label: 'Không thích'),
      ],
      onSelect: (value, state) => state._enjoyment = value,
    ),
    _Question(
      question: 'Bạn có muốn học tiếp ngày mai không?',
      options: [
        _Option(value: 'definitely', label: 'Rất muốn'),
        _Option(value: 'yes', label: 'Muốn'),
        _Option(value: 'maybe', label: 'Có thể'),
        _Option(value: 'no', label: 'Không'),
      ],
      onSelect: (value, state) => state._continueReason = value,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản hồi'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Text(
                    'Câu ${_currentQuestion + 1}/${_questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Question text
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  // Options
                  ...question.options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OptionCard(
                        label: option.label,
                        isSelected: _isOptionSelected(option.value),
                        onTap: () => _selectOption(option.value),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _nextQuestion : null,
                      child: Text(
                        _currentQuestion == _questions.length - 1
                            ? 'Hoàn thành'
                            : 'Tiếp tục',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOptionSelected(String value) {
    switch (_currentQuestion) {
      case 0:
        return _difficulty == value;
      case 1:
        return _enjoyment == value;
      case 2:
        return _continueReason == value;
      default:
        return false;
    }
  }

  bool _canProceed() {
    switch (_currentQuestion) {
      case 0:
        return _difficulty != null;
      case 1:
        return _enjoyment != null;
      case 2:
        return _continueReason != null;
      default:
        return false;
    }
  }

  void _selectOption(String value) {
    setState(() {
      switch (_currentQuestion) {
        case 0:
          _difficulty = value;
          break;
        case 1:
          _enjoyment = value;
          break;
        case 2:
          _continueReason = value;
          break;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _completeReflection();
    }
  }

  void _completeReflection() {
    final enjoymentScore = _getEnjoymentScore(_enjoyment ?? 'neutral');

    final reflection = ReflectionResult(
      sessionId: 'session_001', // TODO: Get from session
      difficulty: _difficulty ?? 'normal',
      enjoyment: _enjoyment ?? 'neutral',
      continueReason: _continueReason ?? 'maybe',
      enjoymentScore: enjoymentScore,
    );

    Navigator.pushNamed(
      context,
      '/closing',
      arguments: reflection,
    );
  }

  int _getEnjoymentScore(String enjoyment) {
    switch (enjoyment) {
      case 'love':
        return 5;
      case 'like':
        return 4;
      case 'neutral':
        return 3;
      case 'dislike':
        return 2;
      default:
        return 3;
    }
  }
}

class _Question {
  final String question;
  final List<_Option> options;
  final void Function(String value, _ReflectionScreenState state) onSelect;

  _Question({
    required this.question,
    required this.options,
    required this.onSelect,
  });
}

class _Option {
  final String value;
  final String label;

  _Option({required this.value, required this.label});
}

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
