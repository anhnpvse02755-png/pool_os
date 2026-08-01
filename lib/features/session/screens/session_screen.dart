import 'package:flutter/material.dart';
import '../../../core/models/recommendation.dart';
import '../../../core/theme/app_theme.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _currentStep = 0; // 0=Opening, 1=Knowledge, 2=Warmup, 3=Drill, 4=Verify

  // Drill tracking
  int _attempts = 0;
  int _successes = 0;
  final List<bool> _attemptResults = [];

  // Get recommendation from arguments
  Recommendation get _recommendation =>
      ModalRoute.of(context)!.settings.arguments as Recommendation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bài tập ${_recommendation.goalName}'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentStep,
          children: [
            _buildOpening(),
            _buildKnowledge(),
            _buildWarmup(),
            _buildDrill(),
            _buildVerify(),
          ],
        ),
      ),
    );
  }

  // Step 0: Opening
  Widget _buildOpening() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào bạn!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hôm nay chúng ta sẽ tập "${_recommendation.goalName}".',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thời gian: ${_recommendation.durationMinutes} phút',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            '📋 Chuẩn bị:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem('Đặt bàn bi-a sẵn sàng'),
          _buildCheckItem('Có cue và phấn'),
          _buildCheckItem('Đủ ánh sáng'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _nextStep(),
              child: const Text('Bắt đầu'),
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Knowledge
  Widget _buildKnowledge() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Kiến thức',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ghost Ball',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ghost Ball là kỹ thuật nhắm bằng cách tưởng tượng '
                  'một quả bóng ảo (ghost ball) ở vị trí bi sẽ rơi vào.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Cách làm:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1. Nhìn vị trí túi muốn đánh bi vào'),
                      Text('2. Tưởng tượng ghost ball ở đó'),
                      Text('3. Nhắm cue vào ghost ball'),
                      Text('4. Đánh thẳng vào ghost ball'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Video placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Video Demo (2 phút)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _nextStep(),
              child: const Text('Đã hiểu'),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Warmup
  Widget _buildWarmup() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_walk, color: AppTheme.success),
                    SizedBox(width: 8),
                    Text(
                      'Khởi động',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trước khi tập chính, hãy thử 3 cú nhắm thẳng:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text('🎯 Đặt 1 bi ở giữa bàn'),
                      Text('👀 Nhắm thẳng vào túi'),
                      Text('💪 Đánh nhẹ, tập trung'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '3 cú warmup',
              style: TextStyle(fontSize: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '(Tap để đánh dấu hoàn thành)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _nextStep(),
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Drill
  Widget _buildDrill() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Bài tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pot 10 bi vào túi!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đánh từng bi một. Tập trung vào Ghost Ball.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Progress
          Center(
            child: Column(
              children: [
                Text(
                  '$_attempts / 10',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('bi đã đánh'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Tap area to simulate pot
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _potBall,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap để đánh',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          if (_attempts >= 10)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nextStep(),
                child: const Text('Kiểm tra'),
              ),
            ),
        ],
      ),
    );
  }

  // Step 4: Verify
  Widget _buildVerify() {
    final passed = _successes >= 5;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: passed ? AppTheme.success.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.warning,
                  size: 64,
                  color: passed ? AppTheme.success : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Đạt!' : 'Cố gắng thêm!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: passed ? AppTheme.success : Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kết quả: $_successes / $_attempts bi',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            passed
                ? 'Bạn đã vượt qua bài tập! Tiếp tục phát huy nhé!'
                : 'Đừng nản! Thực hành thêm sẽ giỏi hơn.',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reflection');
              },
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppTheme.success),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _potBall() {
    if (_attempts < 10) {
      setState(() {
        _attempts++;
        // Sprint 1: Random success for demo (70% success rate)
        final success = DateTime.now().millisecond % 10 < 7;
        _attemptResults.add(success);
        if (success) _successes++;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
  }
}
