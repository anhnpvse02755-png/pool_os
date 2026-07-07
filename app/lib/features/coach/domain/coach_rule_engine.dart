import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/shot/domain/models/practice_shot.dart';
import 'package:pool_os/features/shot/domain/models/practice_session.dart';

class CoachRule {
  final int priority;
  final String id;
  final String name;
  final String nameVi;
  final bool Function(CoachRuleContext) condition;
  final List<CoachRecommendation> Function(CoachRuleContext) actions;

  const CoachRule({
    required this.priority,
    required this.id,
    required this.name,
    required this.nameVi,
    required this.condition,
    required this.actions,
  });
}

class CoachRuleContext {
  final DailyReadinessModel? readiness;
  final Map<String, SkillMetric> skillMetrics;
  final Map<String, StatMetric> statistics;
  final int sessionCount;
  final int consecutiveTrainingDays;
  final List<String> recentDrillIds;
  final bool equipmentChanged;
  final String? currentTipId;
  
  // FIX-003: Include both Match and Practice data for Coach
  final List<PracticeSession> practiceSessions;
  final List<PracticeShot> recentShots;
  final Map<String, int> practiceShotCountsByType;
  final Map<MissType, int> practiceMissCountsByType;

  const CoachRuleContext({
    this.readiness,
    this.skillMetrics = const {},
    this.statistics = const {},
    this.sessionCount = 0,
    this.consecutiveTrainingDays = 0,
    this.recentDrillIds = const [],
    this.equipmentChanged = false,
    this.currentTipId,
    // FIX-003: Practice data
    this.practiceSessions = const [],
    this.recentShots = const [],
    this.practiceShotCountsByType = const {},
    this.practiceMissCountsByType = const {},
  });

  bool get hasEnoughData => sessionCount >= 3;
  int get readyScore => readiness?.overallScore ?? 0;
  
  // FIX-003: Combined data analysis
  double get practiceSuccessRate {
    if (recentShots.isEmpty) return 0;
    final successCount = recentShots.where((s) => s.success).length;
    return successCount / recentShots.length;
  }
}

class SkillMetric {
  final String skillId;
  final double currentValue;
  final double previousValue;
  final double target;
  final List<double> history;
  final TrendDirection trend;

  const SkillMetric({
    required this.skillId,
    required this.currentValue,
    this.previousValue = 0,
    this.target = 100,
    this.history = const [],
    this.trend = TrendDirection.stable,
  });
}

class StatMetric {
  final String statId;
  final double value;
  final double previousValue;
  final List<double> history;
  final TrendDirection trend;

  const StatMetric({
    required this.statId,
    required this.value,
    this.previousValue = 0,
    this.history = const [],
    this.trend = TrendDirection.stable,
  });
}

enum TrendDirection { improving, stable, declining }

class CoachRecommendation {
  final String id;
  final String category;
  final String observation;
  final String observationVi;
  final String evidence;
  final String evidenceVi;
  final List<RecommendedDrill> drills;
  final String expectedImprovement;
  final String expectedImprovementVi;
  final int priority;

  const CoachRecommendation({
    required this.id,
    required this.category,
    required this.observation,
    required this.observationVi,
    required this.evidence,
    required this.evidenceVi,
    required this.drills,
    required this.expectedImprovement,
    required this.expectedImprovementVi,
    this.priority = 5,
  });
}

class RecommendedDrill {
  final String drillId;
  final int durationMinutes;
  final String difficulty;
  final String? reason;
  final String? reasonVi;

  const RecommendedDrill({
    required this.drillId,
    required this.durationMinutes,
    this.difficulty = 'intermediate',
    this.reason,
    this.reasonVi,
  });
}

class CoachRuleEngine {
  static final List<CoachRule> _rules = [
    _rule01ReadinessScore(),
    _rule02SleepInsufficient(),
    _rule03HighStress(),
    _rule04LowConfidence(),
    _rule05WeakBreak(),
    _rule06WeakThinCut(),
    _rule07WeakLongPot(),
    _rule08WeakPosition(),
    _rule09HighScratchRate(),
    _rule10WeakSafety(),
    _rule11WeakKick(),
    _rule12WeakBank(),
    _rule13HillHillPerformance(),
    _rule14LowConsistency(),
    _rule15EquipmentImpact(),
    _rule16TrainingFatigue(),
    _rule17SkillRegression(),
    _rule18SkillImprovement(),
    _rule19TrainingDistribution(),
    _rule20NoRecommendation(),
  ];

  static List<CoachRecommendation> evaluate(CoachRuleContext context) {
    if (!context.hasEnoughData) {
      return [_createInsufficientDataRecommendation()];
    }

    final recommendations = <CoachRecommendation>[];
    final sortedRules = _rules.toList()..sort((a, b) => a.priority.compareTo(b.priority));

    for (final rule in sortedRules) {
      if (rule.condition(context)) {
        final ruleRecs = rule.actions(context);
        recommendations.addAll(ruleRecs);
      }
    }

    return _deduplicateAndPrioritize(recommendations);
  }

  static CoachRecommendation _createInsufficientDataRecommendation() {
    return const CoachRecommendation(
      id: 'insufficient_data',
      category: 'general',
      observation: 'Not enough data to generate personalized recommendations.',
      observationVi: 'Chưa có đủ dữ liệu để đưa ra khuyến nghị cá nhân hóa.',
      evidence: 'At least 3 sessions are required for meaningful analysis.',
      evidenceVi: 'Cần ít nhất 3 buổi chơi để có thể phân tích có ý nghĩa.',
      drills: [],
      expectedImprovement: 'Complete more sessions to receive personalized coaching.',
      expectedImprovementVi: 'Hoàn thành thêm buổi chơi để nhận huấn luyện cá nhân hóa.',
      priority: 1,
    );
  }

  static List<CoachRecommendation> _deduplicateAndPrioritize(
      List<CoachRecommendation> recommendations) {
    // FIX-006: Return only ONE primary focus per day
    final seen = <String>{};
    final deduplicated = <CoachRecommendation>[];

    for (final rec in recommendations) {
      if (!seen.contains(rec.category)) {
        seen.add(rec.category);
        deduplicated.add(rec);
      }
    }

    deduplicated.sort((a, b) => a.priority.compareTo(b.priority));
    // FIX-006: Only return top 1 priority recommendation
    return deduplicated.take(1).toList();
  }

  static CoachRule _rule01ReadinessScore() {
    return CoachRule(
      priority: 1,
      id: 'R01',
      name: 'Daily Readiness Score',
      nameVi: 'Điểm Sẵn Sàng Hàng Ngày',
      condition: (ctx) => ctx.readiness != null,
      actions: (ctx) {
        final score = ctx.readyScore;
        if (score >= 85) {
          return [
            CoachRecommendation(
              id: 'R01_heavy',
              category: 'readiness',
              observation: 'You are in excellent condition for training.',
              observationVi: 'Bạn đang ở tình trạng tuyệt vời để tập luyện.',
              evidence: 'Readiness score: $score/100',
              evidenceVi: 'Điểm sẵn sàng: $score/100',
              drills: [
                const RecommendedDrill(
                  drillId: 'P001',
                  durationMinutes: 20,
                  difficulty: 'advanced',
                  reason: 'High intensity position training',
                  reasonVi: 'Tập điều bi cường độ cao',
                ),
                const RecommendedDrill(
                  drillId: 'PR001',
                  durationMinutes: 15,
                  difficulty: 'advanced',
                  reason: 'Pressure drills for competition preparation',
                  reasonVi: 'Bài tập áp lực chuẩn bị thi đấu',
                ),
              ],
              expectedImprovement: 'Maintain high intensity training.',
              expectedImprovementVi: 'Duy trì tập luyện cường độ cao.',
              priority: 1,
            ),
          ];
        } else if (score >= 70) {
          return [
            CoachRecommendation(
              id: 'R01_normal',
              category: 'readiness',
              observation: 'Good condition for normal training.',
              observationVi: 'Tình trạng tốt cho tập luyện bình thường.',
              evidence: 'Readiness score: $score/100',
              evidenceVi: 'Điểm sẵn sàng: $score/100',
              drills: [
                const RecommendedDrill(
                  drillId: 'W001',
                  durationMinutes: 10,
                  difficulty: 'beginner',
                  reason: 'Standard warmup routine',
                  reasonVi: 'Khởi động tiêu chuẩn',
                ),
                const RecommendedDrill(
                  drillId: 'P002',
                  durationMinutes: 20,
                  difficulty: 'intermediate',
                  reason: 'Position control training',
                  reasonVi: 'Tập kiểm soát vị trí',
                ),
              ],
              expectedImprovement: 'Continue with normal training intensity.',
              expectedImprovementVi: 'Tiếp tục với cường độ tập bình thường.',
              priority: 2,
            ),
          ];
        } else if (score >= 50) {
          return [
            CoachRecommendation(
              id: 'R01_light',
              category: 'readiness',
              observation: 'Light training recommended today.',
              observationVi: 'Hôm nay nên tập nhẹ.',
              evidence: 'Readiness score: $score/100',
              evidenceVi: 'Điểm sẵn sàng: $score/100',
              drills: [
                const RecommendedDrill(
                  drillId: 'W001',
                  durationMinutes: 5,
                  difficulty: 'beginner',
                  reason: 'Gentle warmup only',
                  reasonVi: 'Khởi động nhẹ nhàng',
                ),
                const RecommendedDrill(
                  drillId: 'P001',
                  durationMinutes: 15,
                  difficulty: 'beginner',
                  reason: 'Basic position drills',
                  reasonVi: 'Bài tập vị trí cơ bản',
                ),
              ],
              expectedImprovement: 'Focus on fundamentals, avoid intense drills.',
              expectedImprovementVi: 'Tập trung cơ bản, tránh bài tập nặng.',
              priority: 3,
            ),
          ];
        } else {
          return [
            CoachRecommendation(
              id: 'R01_recovery',
              category: 'readiness',
              observation: 'Recovery day recommended.',
              observationVi: 'Nên nghỉ ngơi hôm nay.',
              evidence: 'Readiness score: $score/100',
              evidenceVi: 'Điểm sẵn sàng: $score/100',
              drills: [
                const RecommendedDrill(
                  drillId: 'R001',
                  durationMinutes: 10,
                  difficulty: 'beginner',
                  reason: 'Light stretching only',
                  reasonVi: 'Kéo giãn nhẹ',
                ),
              ],
              expectedImprovement: 'Rest and recover for better performance tomorrow.',
              expectedImprovementVi: 'Nghỉ ngơi và phục hồi để mai tập tốt hơn.',
              priority: 1,
            ),
          ];
        }
      },
    );
  }

  static CoachRule _rule02SleepInsufficient() {
    return CoachRule(
      priority: 2,
      id: 'R02',
      name: 'Sleep Duration',
      nameVi: 'Giờ Ngủ',
      condition: (ctx) {
        if (ctx.readiness == null) return false;
        final sleepHours = ctx.readiness!.sleepHours ?? 8;
        return sleepHours < 5;
      },
      actions: (ctx) {
        final sleepHours = ctx.readiness?.sleepHours ?? 0;
        if (sleepHours < 4) {
          return [
            CoachRecommendation(
              id: 'R02_critical',
              category: 'health',
              observation: 'Severe sleep deprivation detected.',
              observationVi: 'Phát hiện thiếu ngủ nghiêm trọng.',
              evidence: 'Sleep hours: $sleepHours (recommended: 7-9)',
              evidenceVi: 'Giờ ngủ: $sleepHours (khuyến nghị: 7-9)',
              drills: [],
              expectedImprovement: 'Avoid match practice. Focus on recovery.',
              expectedImprovementVi: 'Tránh đấu tập. Tập trung phục hồi.',
              priority: 1,
            ),
          ];
        } else {
          return [
            CoachRecommendation(
              id: 'R02_moderate',
              category: 'health',
              observation: 'Insufficient sleep detected.',
              observationVi: 'Phát hiện thiếu ngủ.',
              evidence: 'Sleep hours: $sleepHours (recommended: 7-9)',
              evidenceVi: 'Giờ ngủ: $sleepHours (khuyến nghị: 7-9)',
              drills: [
                const RecommendedDrill(
                  drillId: 'M002',
                  durationMinutes: 10,
                  difficulty: 'beginner',
                  reason: 'Relaxation and breathing techniques',
                  reasonVi: 'Kỹ thuật thư giãn và hít thở',
                ),
              ],
              expectedImprovement: 'Reduce training volume by 50%.',
              expectedImprovementVi: 'Giảm thể tích tập 50%.',
              priority: 2,
            ),
          ];
        }
      },
    );
  }

  static CoachRule _rule03HighStress() {
    return CoachRule(
      priority: 3,
      id: 'R03',
      name: 'High Stress Level',
      nameVi: 'Mức Stress Cao',
      condition: (ctx) {
        if (ctx.readiness == null) return false;
        return ctx.readiness!.stressLevel != null &&
            ctx.readiness!.stressLevel! >= 8;
      },
      actions: (ctx) {
        final stressLevel = ctx.readiness!.stressLevel ?? 0;
        return [
          CoachRecommendation(
            id: 'R03_high_stress',
            category: 'mental',
            observation: 'High stress level detected.',
            observationVi: 'Phát hiện mức stress cao.',
            evidence: 'Stress level: $stressLevel/10',
            evidenceVi: 'Mức stress: $stressLevel/10',
            drills: [
              const RecommendedDrill(
                drillId: 'M002',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Breathing and relaxation techniques',
                reasonVi: 'Kỹ thuật hít thở và thư giãn',
              ),
              const RecommendedDrill(
                drillId: 'M001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Pre-shot routine for mental focus',
                reasonVi: 'Thói quen trước cú đánh để tập trung',
              ),
              const RecommendedDrill(
                drillId: 'R001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Light stretching to reduce tension',
                reasonVi: 'Kéo giãn nhẹ để giảm căng thẳng',
              ),
            ],
            expectedImprovement: 'Reduce stress through relaxation techniques.',
            expectedImprovementVi: 'Giảm stress qua kỹ thuật thư giãn.',
            priority: 1,
          ),
        ];
      },
    );
  }

  static CoachRule _rule04LowConfidence() {
    return CoachRule(
      priority: 4,
      id: 'R04',
      name: 'Low Confidence',
      nameVi: 'Tự Tin Thấp',
      condition: (ctx) {
        if (ctx.readiness == null) return false;
        return ctx.readiness!.confidenceLevel != null &&
            ctx.readiness!.confidenceLevel! <= 2;
      },
      actions: (ctx) {
        final confidence = ctx.readiness!.confidenceLevel ?? 0;
        return [
          CoachRecommendation(
            id: 'R04_low_confidence',
            category: 'mental',
            observation: 'Low confidence level detected.',
            observationVi: 'Phát hiện mức tự tin thấp.',
            evidence: 'Confidence level: $confidence/10',
            evidenceVi: 'Mức tự tin: $confidence/10',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Build confidence with easy shots',
                reasonVi: 'Xây dựng tự tin với cú dễ',
              ),
              const RecommendedDrill(
                drillId: 'W002',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Stop shot mastery for confidence',
                reasonVi: 'Thành thạo stop shot để tự tin',
              ),
              const RecommendedDrill(
                drillId: 'M003',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Confidence reset techniques',
                reasonVi: 'Kỹ thuật reset tự tin',
              ),
            ],
            expectedImprovement: 'Build confidence with fundamental drills.',
            expectedImprovementVi: 'Xây dựng tự tin với bài tập cơ bản.',
            priority: 3,
          ),
        ];
      },
    );
  }

  static CoachRule _rule05WeakBreak() {
    return CoachRule(
      priority: 5,
      id: 'R05',
      name: 'Break Performance',
      nameVi: 'Phá Bàn',
      condition: (ctx) {
        final breakMetric = ctx.statistics['breakSuccess'];
        if (breakMetric == null) return false;
        return breakMetric.value < 50;
      },
      actions: (ctx) {
        final breakSuccess = ctx.statistics['breakSuccess']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R05_weak_break',
            category: 'skill_weakness',
            observation: 'Break performance needs improvement.',
            observationVi: 'Kỹ năng phá bàn cần cải thiện.',
            evidence: 'Break success rate: ${breakSuccess.toStringAsFixed(1)}% (target: 50%+)',
            evidenceVi: 'Tỷ lệ phá thành công: ${breakSuccess.toStringAsFixed(1)}% (mục tiêu: 50%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'B001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Power break technique',
                reasonVi: 'Kỹ thuật phá lực',
              ),
              const RecommendedDrill(
                drillId: 'B002',
                durationMinutes: 15,
                difficulty: 'intermediate',
                reason: 'Control break for accuracy',
                reasonVi: 'Phá kiểm soát để chính xác',
              ),
              const RecommendedDrill(
                drillId: 'B004',
                durationMinutes: 15,
                difficulty: 'advanced',
                reason: 'Cue ball control after break',
                reasonVi: 'Kiểm soát bi cue sau phá',
              ),
            ],
            expectedImprovement: 'Increase break success rate by 10-15%.',
            expectedImprovementVi: 'Tăng tỷ lệ phá thành công 10-15%.',
            priority: 4,
          ),
        ];
      },
    );
  }

  static CoachRule _rule06WeakThinCut() {
    return CoachRule(
      priority: 6,
      id: 'R06',
      name: 'Thin Cut Accuracy',
      nameVi: 'Độ Chính Xác Cắt Bi Mỏng',
      condition: (ctx) {
        final thinCutMetric = ctx.skillMetrics['thinCut'];
        if (thinCutMetric == null) return false;
        return thinCutMetric.currentValue < 60;
      },
      actions: (ctx) {
        final thinCutAcc = ctx.skillMetrics['thinCut']?.currentValue ?? 0;
        return [
          CoachRecommendation(
            id: 'R06_weak_thin_cut',
            category: 'skill_weakness',
            observation: 'Thin cut accuracy needs improvement.',
            observationVi: 'Độ chính xác cắt bi mỏng cần cải thiện.',
            evidence: 'Thin cut accuracy: ${thinCutAcc.toStringAsFixed(1)}% (target: 60%+)',
            evidenceVi: 'Độ chính xác cắt mỏng: ${thinCutAcc.toStringAsFixed(1)}% (mục tiêu: 60%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'TC001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Short thin cut practice',
                reasonVi: 'Luyện cắt mỏng gần',
              ),
              const RecommendedDrill(
                drillId: 'TC002',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Long thin cut technique',
                reasonVi: 'Kỹ thuật cắt mỏng xa',
              ),
              const RecommendedDrill(
                drillId: 'TC003',
                durationMinutes: 15,
                difficulty: 'intermediate',
                reason: 'Rail thin cut positioning',
                reasonVi: 'Cắt mỏng gần đệm',
              ),
            ],
            expectedImprovement: 'Improve thin cut accuracy by 8-12%.',
            expectedImprovementVi: 'Cải thiện độ chính xác cắt mỏng 8-12%.',
            priority: 4,
          ),
        ];
      },
    );
  }

  static CoachRule _rule07WeakLongPot() {
    return CoachRule(
      priority: 7,
      id: 'R07',
      name: 'Long Pot Accuracy',
      nameVi: 'Đánh Bi Xa',
      condition: (ctx) {
        final longPotMetric = ctx.skillMetrics['longPot'];
        if (longPotMetric == null) return false;
        return longPotMetric.currentValue < 55;
      },
      actions: (ctx) {
        final longPotAcc = ctx.skillMetrics['longPot']?.currentValue ?? 0;
        return [
          CoachRecommendation(
            id: 'R07_weak_long_pot',
            category: 'skill_weakness',
            observation: 'Long pot accuracy needs improvement.',
            observationVi: 'Đánh bi xa cần cải thiện.',
            evidence: 'Long pot accuracy: ${longPotAcc.toStringAsFixed(1)}% (target: 55%+)',
            evidenceVi: 'Độ chính xác đánh xa: ${longPotAcc.toStringAsFixed(1)}% (mục tiêu: 55%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'LP001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Long straight shot practice',
                reasonVi: 'Luyện đánh thẳng xa',
              ),
              const RecommendedDrill(
                drillId: 'LP002',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Long cut angle technique',
                reasonVi: 'Kỹ thuật cắt xa',
              ),
              const RecommendedDrill(
                drillId: 'LP003',
                durationMinutes: 15,
                difficulty: 'intermediate',
                reason: 'Distance control with follow',
                reasonVi: 'Kiểm soát khoảng cách với follow',
              ),
            ],
            expectedImprovement: 'Improve long pot accuracy by 10-15%.',
            expectedImprovementVi: 'Cải thiện đánh bi xa 10-15%.',
            priority: 4,
          ),
        ];
      },
    );
  }

  static CoachRule _rule08WeakPosition() {
    return CoachRule(
      priority: 8,
      id: 'R08',
      name: 'Position Play',
      nameVi: 'Điều Bi',
      condition: (ctx) {
        final positionMetric = ctx.skillMetrics['position'];
        if (positionMetric == null) return false;
        return positionMetric.currentValue < 65;
      },
      actions: (ctx) {
        final positionAcc = ctx.skillMetrics['position']?.currentValue ?? 0;
        return [
          CoachRecommendation(
            id: 'R08_weak_position',
            category: 'skill_weakness',
            observation: 'Position play needs significant improvement.',
            observationVi: 'Kỹ năng điều bi cần cải thiện đáng kể.',
            evidence: 'Position accuracy: ${positionAcc.toStringAsFixed(1)}% (target: 65%+)',
            evidenceVi: 'Độ chính xác vị trí: ${positionAcc.toStringAsFixed(1)}% (mục tiêu: 65%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'P001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Stop shot for position control',
                reasonVi: 'Stop shot để kiểm soát vị trí',
              ),
              const RecommendedDrill(
                drillId: 'P002',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Follow shot position practice',
                reasonVi: 'Tập vị trí với follow shot',
              ),
              const RecommendedDrill(
                drillId: 'P003',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Draw shot position control',
                reasonVi: 'Kiểm soát vị trí với draw shot',
              ),
              const RecommendedDrill(
                drillId: 'P004',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Position ladder progression',
                reasonVi: 'Bài tập thang vị trí',
              ),
            ],
            expectedImprovement: 'Improve position accuracy by 8-12%.',
            expectedImprovementVi: 'Cải thiện độ chính xác vị trí 8-12%.',
            priority: 4,
          ),
        ];
      },
    );
  }

  static CoachRule _rule09HighScratchRate() {
    return CoachRule(
      priority: 9,
      id: 'R09',
      name: 'High Scratch Rate',
      nameVi: 'Tỷ Lệ Cấn Bi Cao',
      condition: (ctx) {
        final scratchMetric = ctx.statistics['scratchRate'];
        if (scratchMetric == null) return false;
        return scratchMetric.value > 10;
      },
      actions: (ctx) {
        final scratchRate = ctx.statistics['scratchRate']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R09_high_scratch',
            category: 'skill_weakness',
            observation: 'Cue ball control needs improvement.',
            observationVi: 'Kiểm soát bi cue cần cải thiện.',
            evidence: 'Scratch rate: ${scratchRate.toStringAsFixed(1)}% (target: <10%)',
            evidenceVi: 'Tỷ lệ cấn bi: ${scratchRate.toStringAsFixed(1)}% (mục tiêu: <10%)',
            drills: [
              const RecommendedDrill(
                drillId: 'CB001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Speed control training',
                reasonVi: 'Tập kiểm soát tốc độ',
              ),
              const RecommendedDrill(
                drillId: 'CB002',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Cue ball position ladder',
                reasonVi: 'Thang vị trí bi cue',
              ),
              const RecommendedDrill(
                drillId: 'P001',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Stop shot for center ball control',
                reasonVi: 'Stop shot để kiểm soát bi giữa',
              ),
            ],
            expectedImprovement: 'Reduce scratch rate by 5-8%.',
            expectedImprovementVi: 'Giảm tỷ lệ cấn bi 5-8%.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule10WeakSafety() {
    return CoachRule(
      priority: 10,
      id: 'R10',
      name: 'Safety Performance',
      nameVi: 'Chơi An Toàn',
      condition: (ctx) {
        final safetyMetric = ctx.statistics['safetySuccess'];
        if (safetyMetric == null) return false;
        return safetyMetric.value < 60;
      },
      actions: (ctx) {
        final safetyRate = ctx.statistics['safetySuccess']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R10_weak_safety',
            category: 'skill_weakness',
            observation: 'Safety play needs improvement.',
            observationVi: 'Chơi an toàn cần cải thiện.',
            evidence: 'Safety success rate: ${safetyRate.toStringAsFixed(1)}% (target: 60%+)',
            evidenceVi: 'Tỷ lệ an toàn thành công: ${safetyRate.toStringAsFixed(1)}% (mục tiêu: 60%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'S001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Distance safety technique',
                reasonVi: 'Kỹ thuật an toàn khoảng cách',
              ),
              const RecommendedDrill(
                drillId: 'S002',
                durationMinutes: 15,
                difficulty: 'advanced',
                reason: 'Thin safety positioning',
                reasonVi: 'Vị trí an toàn mỏng',
              ),
              const RecommendedDrill(
                drillId: 'S003',
                durationMinutes: 15,
                difficulty: 'advanced',
                reason: 'Two rail safety practice',
                reasonVi: 'Tập an toàn 2 đệm',
              ),
            ],
            expectedImprovement: 'Improve safety success rate by 10-15%.',
            expectedImprovementVi: 'Cải thiện tỷ lệ an toàn 10-15%.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule11WeakKick() {
    return CoachRule(
      priority: 11,
      id: 'R11',
      name: 'Kick Shot Success',
      nameVi: 'Đá Bi',
      condition: (ctx) {
        final kickMetric = ctx.statistics['kickSuccess'];
        if (kickMetric == null) return false;
        return kickMetric.value < 50;
      },
      actions: (ctx) {
        final kickRate = ctx.statistics['kickSuccess']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R11_weak_kick',
            category: 'skill_weakness',
            observation: 'Kick shot success needs improvement.',
            observationVi: 'Đá bi cần cải thiện.',
            evidence: 'Kick success rate: ${kickRate.toStringAsFixed(1)}% (target: 50%+)',
            evidenceVi: 'Tỷ lệ đá thành công: ${kickRate.toStringAsFixed(1)}% (mục tiêu: 50%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'K001',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'One rail kick technique',
                reasonVi: 'Kỹ thuật đá 1 đệm',
              ),
              const RecommendedDrill(
                drillId: 'K002',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Two rail kick practice',
                reasonVi: 'Tập đá 2 đệm',
              ),
              const RecommendedDrill(
                drillId: 'K003',
                durationMinutes: 15,
                difficulty: 'expert',
                reason: 'Diamond system application',
                reasonVi: 'Áp dụng hệ thống kim cương',
              ),
            ],
            expectedImprovement: 'Improve kick success rate by 8-12%.',
            expectedImprovementVi: 'Cải thiện tỷ lệ đá 8-12%.',
            priority: 6,
          ),
        ];
      },
    );
  }

  static CoachRule _rule12WeakBank() {
    return CoachRule(
      priority: 12,
      id: 'R12',
      name: 'Bank Shot Success',
      nameVi: 'Đánh Ghiên',
      condition: (ctx) {
        final bankMetric = ctx.statistics['bankSuccess'];
        if (bankMetric == null) return false;
        return bankMetric.value < 40;
      },
      actions: (ctx) {
        final bankRate = ctx.statistics['bankSuccess']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R12_weak_bank',
            category: 'skill_weakness',
            observation: 'Bank shot success needs improvement.',
            observationVi: 'Đánh ghiên cần cải thiện.',
            evidence: 'Bank success rate: ${bankRate.toStringAsFixed(1)}% (target: 40%+)',
            evidenceVi: 'Tỷ lệ ghiên thành công: ${bankRate.toStringAsFixed(1)}% (mục tiêu: 40%+)',
            drills: [
              const RecommendedDrill(
                drillId: 'BK001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Cross bank technique',
                reasonVi: 'Kỹ thuật ghiên chéo',
              ),
              const RecommendedDrill(
                drillId: 'BK002',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Long bank distance control',
                reasonVi: 'Kiểm soát khoảng cách ghiên xa',
              ),
              const RecommendedDrill(
                drillId: 'BK003',
                durationMinutes: 15,
                difficulty: 'intermediate',
                reason: 'Short bank precision',
                reasonVi: 'Độ chính xác ghiên gần',
              ),
            ],
            expectedImprovement: 'Improve bank success rate by 8-12%.',
            expectedImprovementVi: 'Cải thiện tỷ lệ ghiên 8-12%.',
            priority: 6,
          ),
        ];
      },
    );
  }

  static CoachRule _rule13HillHillPerformance() {
    return CoachRule(
      priority: 13,
      id: 'R13',
      name: 'Hill-Hill Performance',
      nameVi: 'Hiệu Suất Hill-Hill',
      condition: (ctx) {
        final hillHillMetric = ctx.statistics['hillHillLose'];
        if (hillHillMetric == null) return false;
        final hillHillWin = ctx.statistics['hillHillWin']?.value ?? 0;
        return hillHillMetric.value > hillHillWin;
      },
      actions: (ctx) {
        final hillHillWin = ctx.statistics['hillHillWin']?.value ?? 0;
        final hillHillLose = ctx.statistics['hillHillLose']?.value ?? 0;
        return [
          CoachRecommendation(
            id: 'R13_hill_hill',
            category: 'mental',
            observation: 'Hill-Hill performance needs improvement.',
            observationVi: 'Hiệu suất hill-hill cần cải thiện.',
            evidence: 'Hill-Hill: $hillHillWin wins / $hillHillLose losses',
            evidenceVi: 'Hill-Hill: $hillHillWin thắng / $hillHillLose thua',
            drills: [
              const RecommendedDrill(
                drillId: 'PR001',
                durationMinutes: 15,
                difficulty: 'advanced',
                reason: 'Hill-Hill pressure simulation',
                reasonVi: 'Mô phỏng áp lực hill-hill',
              ),
              const RecommendedDrill(
                drillId: 'M001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Pre-shot routine for pressure situations',
                reasonVi: 'Thói quen trước cú trong tình huống áp lực',
              ),
              const RecommendedDrill(
                drillId: 'M002',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Breathing routine for calm',
                reasonVi: 'Thói quen hít thở để bình tĩnh',
              ),
            ],
            expectedImprovement: 'Improve hill-hill win rate by 15-20%.',
            expectedImprovementVi: 'Cải thiện tỷ lệ thắng hill-hill 15-20%.',
            priority: 3,
          ),
        ];
      },
    );
  }

  static CoachRule _rule14LowConsistency() {
    return CoachRule(
      priority: 14,
      id: 'R14',
      name: 'Low Consistency',
      nameVi: 'Ổn Định Thấp',
      condition: (ctx) {
        final consistencyMetric = ctx.skillMetrics['consistency'];
        if (consistencyMetric == null) return false;
        return consistencyMetric.currentValue < 70;
      },
      actions: (ctx) {
        final consistency = ctx.skillMetrics['consistency']?.currentValue ?? 0;
        return [
          CoachRecommendation(
            id: 'R14_low_consistency',
            category: 'skill_weakness',
            observation: 'Consistency needs improvement.',
            observationVi: 'Sự ổn định cần cải thiện.',
            evidence: 'Consistency score: ${consistency.toStringAsFixed(1)} (target: 70+)',
            evidenceVi: 'Điểm ổn định: ${consistency.toStringAsFixed(1)} (mục tiêu: 70+)',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Repetitive fundamental practice',
                reasonVi: 'Luyện lặp lại cơ bản',
              ),
              const RecommendedDrill(
                drillId: 'P001',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Simple position drills',
                reasonVi: 'Bài tập vị trí đơn giản',
              ),
              const RecommendedDrill(
                drillId: 'P004',
                durationMinutes: 15,
                difficulty: 'intermediate',
                reason: 'Progressive difficulty ladder',
                reasonVi: 'Thang độ khó tăng dần',
              ),
            ],
            expectedImprovement: 'Increase consistency by reducing variance.',
            expectedImprovementVi: 'Tăng ổn định bằng cách giảm biến động.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule15EquipmentImpact() {
    return CoachRule(
      priority: 15,
      id: 'R15',
      name: 'Equipment Change Impact',
      nameVi: 'Tác Động Thay Đổi Dụng Cụ',
      condition: (ctx) => ctx.equipmentChanged,
      actions: (ctx) {
        return [
          CoachRecommendation(
            id: 'R15_equipment_change',
            category: 'equipment',
            observation: 'Equipment change detected.',
            observationVi: 'Phát hiện thay đổi dụng cụ.',
            evidence: 'New tip or equipment was recently changed.',
            evidenceVi: 'Đầu cơ hoặc dụng cụ mới đã được thay đổi gần đây.',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Calibration with new equipment',
                reasonVi: 'Hiệu chỉnh với dụng cụ mới',
              ),
              const RecommendedDrill(
                drillId: 'W002',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Feel assessment with new tip',
                reasonVi: 'Đánh giá cảm giác với đầu mới',
              ),
            ],
            expectedImprovement: 'Allow 3-5 sessions to adapt to new equipment.',
            expectedImprovementVi: 'Cần 3-5 buổi để thích nghi với dụng cụ mới.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule16TrainingFatigue() {
    return CoachRule(
      priority: 16,
      id: 'R16',
      name: 'Training Fatigue',
      nameVi: 'Mệt Mỏi Tập Luyện',
      condition: (ctx) => ctx.consecutiveTrainingDays > 5,
      actions: (ctx) {
        return [
          CoachRecommendation(
            id: 'R16_fatigue',
            category: 'recovery',
            observation: 'Training fatigue detected.',
            observationVi: 'Phát hiện mệt mỏi tập luyện.',
            evidence: 'Consecutive training days: ${ctx.consecutiveTrainingDays} (recommended: max 5)',
            evidenceVi: 'Ngày tập liên tiếp: ${ctx.consecutiveTrainingDays} (khuyến nghị: tối đa 5)',
            drills: [
              const RecommendedDrill(
                drillId: 'R001',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Active recovery stretching',
                reasonVi: 'Kéo giãn phục hồi chủ động',
              ),
              const RecommendedDrill(
                drillId: 'R002',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Back and shoulder relief',
                reasonVi: 'Giảm căng lưng và vai',
              ),
            ],
            expectedImprovement: 'Take a rest day to prevent overtraining.',
            expectedImprovementVi: 'Nghỉ một ngày để tránh tập quá sức.',
            priority: 1,
          ),
        ];
      },
    );
  }

  static CoachRule _rule17SkillRegression() {
    return CoachRule(
      priority: 17,
      id: 'R17',
      name: 'Skill Regression',
      nameVi: 'Kỹ Năng Suy Giảm',
      condition: (ctx) {
        for (final metric in ctx.skillMetrics.values) {
          if (metric.trend == TrendDirection.declining &&
              metric.history.length >= 3) {
            return true;
          }
        }
        return false;
      },
      actions: (ctx) {
        final decliningSkills = ctx.skillMetrics.entries
            .where((e) => e.value.trend == TrendDirection.declining)
            .map((e) => e.key)
            .toList();

        return [
          CoachRecommendation(
            id: 'R17_regression',
            category: 'skill_weakness',
            observation: 'Skill regression detected.',
            observationVi: 'Phát hiện kỹ năng suy giảm.',
            evidence: 'Declining skills: ${decliningSkills.join(", ")}',
            evidenceVi: 'Kỹ năng suy giảm: ${decliningSkills.join(", ")}',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Return to fundamentals',
                reasonVi: 'Quay lại cơ bản',
              ),
              const RecommendedDrill(
                drillId: 'P001',
                durationMinutes: 20,
                difficulty: 'intermediate',
                reason: 'Reinforce declining skill',
                reasonVi: 'Củng cố kỹ năng suy giảm',
              ),
              const RecommendedDrill(
                drillId: 'P004',
                durationMinutes: 15,
                difficulty: 'beginner',
                reason: 'Progressive skill building',
                reasonVi: 'Xây dựng kỹ năng từ từ',
              ),
            ],
            expectedImprovement: 'Address regression before it becomes habit.',
            expectedImprovementVi: 'Khắc phục suy giảm trước khi thành thói quen.',
            priority: 3,
          ),
        ];
      },
    );
  }

  static CoachRule _rule18SkillImprovement() {
    return CoachRule(
      priority: 18,
      id: 'R18',
      name: 'Skill Improvement',
      nameVi: 'Kỹ Năng Cải Thiện',
      condition: (ctx) {
        for (final metric in ctx.skillMetrics.values) {
          if (metric.trend == TrendDirection.improving &&
              metric.history.length >= 5) {
            return true;
          }
        }
        return false;
      },
      actions: (ctx) {
        final improvingSkills = ctx.skillMetrics.entries
            .where((e) => e.value.trend == TrendDirection.improving)
            .map((e) => e.key)
            .toList();

        return [
          CoachRecommendation(
            id: 'R18_improvement',
            category: 'training_plan',
            observation: 'Great progress detected!',
            observationVi: 'Phát hiện tiến bộ tuyệt vời!',
            evidence: 'Improving skills: ${improvingSkills.join(", ")}',
            evidenceVi: 'Kỹ năng cải thiện: ${improvingSkills.join(", ")}',
            drills: [
              const RecommendedDrill(
                drillId: 'PR002',
                durationMinutes: 20,
                difficulty: 'advanced',
                reason: 'Challenge yourself with competition format',
                reasonVi: 'Thử thách bản thân với định dạng thi đấu',
              ),
            ],
            expectedImprovement: 'Maintain momentum and move to harder variations.',
            expectedImprovementVi: 'Duy trì đà tiến và chuyển sang biến thể khó hơn.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule19TrainingDistribution() {
    return CoachRule(
      priority: 19,
      id: 'R19',
      name: 'Training Distribution',
      nameVi: 'Phân Bổ Tập Luyện',
      condition: (ctx) {
        return ctx.sessionCount > 0 && ctx.hasEnoughData;
      },
      actions: (ctx) {
        final sortedSkills = ctx.skillMetrics.entries.toList()
          ..sort((a, b) => a.value.currentValue.compareTo(b.value.currentValue));

        if (sortedSkills.length < 3) return [];

        final weakest = sortedSkills.take(1).first.key;
        final middle = sortedSkills.length > 2 ? sortedSkills[1].key : null;
        final strongest = sortedSkills.last.key;

        return [
          CoachRecommendation(
            id: 'R19_distribution',
            category: 'training_plan',
            observation: 'Training time should be distributed based on skill levels.',
            observationVi: 'Thời gian tập nên được phân bổ theo cấp độ kỹ năng.',
            evidence: 'Weakest: $weakest, Medium: ${middle ?? strongest}, Strongest: $strongest',
            evidenceVi: 'Yếu nhất: $weakest, Trung bình: ${middle ?? strongest}, Mạnh nhất: $strongest',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Standard warmup for all sessions',
                reasonVi: 'Khởi động tiêu chuẩn cho mọi buổi',
              ),
            ],
            expectedImprovement:
                'Focus 50% on weak, 30% on medium, 20% on strong skills.',
            expectedImprovementVi:
                'Tập trung 50% vào yếu, 30% vào trung bình, 20% vào mạnh.',
            priority: 5,
          ),
        ];
      },
    );
  }

  static CoachRule _rule20NoRecommendation() {
    return CoachRule(
      priority: 20,
      id: 'R20',
      name: 'No Specific Recommendation',
      nameVi: 'Không Có Khuyến Nghị Cụ Thể',
      condition: (ctx) => true,
      actions: (ctx) {
        return [
          CoachRecommendation(
            id: 'R20_general',
            category: 'general',
            observation: 'Continue with balanced training.',
            observationVi: 'Tiếp tục tập luyện cân bằng.',
            evidence: 'All metrics are within acceptable ranges.',
            evidenceVi: 'Tất cả các chỉ số đều trong phạm vi chấp nhận được.',
            drills: [
              const RecommendedDrill(
                drillId: 'W001',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Standard warmup routine',
                reasonVi: 'Khởi động tiêu chuẩn',
              ),
              const RecommendedDrill(
                drillId: 'W002',
                durationMinutes: 10,
                difficulty: 'beginner',
                reason: 'Basic cue ball control',
                reasonVi: 'Kiểm soát bi cue cơ bản',
              ),
            ],
            expectedImprovement: 'Maintain current performance levels.',
            expectedImprovementVi: 'Duy trì mức hiệu suất hiện tại.',
            priority: 5,
          ),
        ];
      },
    );
  }
}
