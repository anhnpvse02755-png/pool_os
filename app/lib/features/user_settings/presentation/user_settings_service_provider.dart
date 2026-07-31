// EPIC 09 — User Settings Riverpod providers (Track A — mobile app).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_pipeline.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_service.dart';

final userSettingsPipelineProvider = Provider<UserSettingsPipeline>(
  (ref) => defaultUserSettingsPipeline(),
);

final userSettingsServiceProvider = Provider<UserSettingsService>(
  (ref) => UserSettingsService(ref.watch(userSettingsPipelineProvider)),
);