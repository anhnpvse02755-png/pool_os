import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';

class CoachContextBuilder {
  const CoachContextBuilder();

  CoachContextContract build({
    required PlayerProfileContract profile,
    required PlayerProgressSnapshot progress,
    required ExperienceSnapshot experience,
  }) =>
      CoachContextContract.create(
        profile: profile,
        progress: progress,
        experience: experience,
      );
}
