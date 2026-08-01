import 'package:flutter/material.dart';
import '../../../core/models/assessment.dart';
import '../../../core/services/assessment_service.dart';
import '../../../core/theme/app_theme.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _assessmentService = AssessmentService();
  int _currentQuestion = 0;

  // Answers
  String? _q1Experience;
  String? _q2Accuracy;
  String? _q3Duration;
  String? _q4Motivation;
  String? _q5Time;

  final List<_Question> _questions = [
    _Question(
      question: 'Bạn đã từng chơi bi-a chưa?',
      options: [
        _Option(value: 'never', label: 'Chưa bao giờ'),
        _Option(value: 'some', label: 'Chơi vài lần'),
        _Option(value: 'regular', label: 'Chơi thường xuyên'),
      ],
      onSelect: (value, state) => state._q1Experience = value,
    ),
    _Question(
      question: 'Bạn đánh trúng khoảng bao nhiêu bi trong 10 cú?',
      options: [
        _Option(value: '0-2', label: '0-2 bi'),
        _Option(value: '3-5', label: '3-5 bi'),
        _Option(value: '6-8', label: '6-8 bi'),
        _Option(value: '9-10', label: '9-10 bi'),
      ],
      onSelect: (value, state) => state._q2Accuracy = value,
    ),
    _Question(
      question: 'Bạn chơi bi-a được bao lâu rồi?',
      options: [
        _Option(value: 'under_1m', label: 'Dưới 1 tháng'),
        _Option(value: '1-6m', label: '1-6 tháng'),
        _Option(value: '6-12m', label: '6-12 tháng'),
        _Option(value: 'over_1y', label: 'Hơn 1 năm'),
      ],
      onSelect: (value, state) => state._q3Duration = value,
    ),
    _Question(
      question: 'Bạn muốn học để làm gì?',
      options: [
        _Option(value: 'fun', label: 'Vui chơi với bạn bè'),
        _Option(value: 'beat_friends', label: 'Thắng bạn bè'),
        _Option(value: 'club', label: 'Thi đấu club'),
        _Option(value: 'tournament', label: 'Thi đấu giải'),
      ],
      onSelect: (value, state) => state._q4Motivation = value,
    ),
    _Question(
      question: 'Hôm nay bạn có khoảng bao lâu?',
      options: [
        _Option(value: '5-10m', label: '5-10 phút'),
        _Option(value: '15-20m', label: '15-20 phút'),
        _Option(value: '30m+', label: '30+ phút'),
      ],
      onSelect: (value, state) => state._q5Time = value,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá'),
        leading: _currentQuestion > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousQuestion,
              )
            : null,
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
        return _q1Experience == value;
      case 1:
        return _q2Accuracy == value;
      case 2:
        return _q3Duration == value;
      case 3:
        return _q4Motivation == value;
      case 4:
        return _q5Time == value;
      default:
        return false;
    }
  }

  bool _canProceed() {
    switch (_currentQuestion) {
      case 0:
        return _q1Experience != null;
      case 1:
        return _q2Accuracy != null;
      case 2:
        return _q3Duration != null;
      case 3:
        return _q4Motivation != null;
      case 4:
        return _q5Time != null;
      default:
        return false;
    }
  }

  void _selectOption(String value) {
    setState(() {
      switch (_currentQuestion) {
        case 0:
          _q1Experience = value;
          break;
        case 1:
          _q2Accuracy = value;
          break;
        case 2:
          _q3Duration = value;
          break;
        case 3:
          _q4Motivation = value;
          break;
        case 4:
          _q5Time = value;
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
      _completeAssessment();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _completeAssessment() {
    final answers = AssessmentAnswer(
      q1Experience: _q1Experience ?? 'never',
      q2Accuracy: _q2Accuracy ?? '0-2',
      q3Duration: _q3Duration ?? 'under_1m',
      q4Motivation: _q4Motivation ?? 'fun',
      q5Time: _q5Time ?? '15-20m',
    );

    final result = _assessmentService.processAssessment(answers);

    Navigator.pushNamed(
      context,
      '/assessment/result',
      arguments: result,
    );
  }
}

class _Question {
  final String question;
  final List<_Option> options;
  final void Function(String value, _AssessmentScreenState state) onSelect;

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
