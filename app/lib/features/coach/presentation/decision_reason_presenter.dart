import 'package:pool_os/contracts/stop_shot_contracts.dart';

String presentDecisionReason(DecisionReason reason) {
  return switch (reason.code) {
    DecisionReasonCodes.outcomeMeasured =>
      'Đã đo ${reason.parameters['successes']}/'
          '${reason.parameters['attempts']} lượt',
    DecisionReasonCodes.belowMasteryThreshold =>
      'Chưa đạt ngưỡng ${reason.parameters['requiredSuccesses']}/'
          '${reason.parameters['requiredAttempts']}',
    DecisionReasonCodes.outcomeAchieved =>
      'Đã đạt ngưỡng ${reason.parameters['requiredSuccesses']}/'
          '${reason.parameters['requiredAttempts']}',
    DecisionReasonCodes.correctionCandidate =>
      'Đã cân nhắc nội dung sửa lỗi ${reason.parameters['recommendationId']}',
    DecisionReasonCodes.recommendationSelected =>
      'Đã chọn ${reason.parameters['recommendationId']}',
    DecisionReasonCodes.mistakeObserved => 'Chưa có quan sát lỗi',
    DecisionReasonCodes.mistakePersistent =>
      'Lỗi ${reason.parameters['mistakeId']} vẫn còn xuất hiện',
    DecisionReasonCodes.mistakeResolved =>
      'Lỗi ${reason.parameters['mistakeId']} đã được giải quyết',
    DecisionReasonCodes.activeCorrectionBlocksUnlock =>
      'Correction ${reason.parameters['category']} đang chặn '
          '${reason.parameters['recommendationId']}',
    _ => 'Reason ${reason.code}',
  };
}
