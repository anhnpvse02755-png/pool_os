// EPIC 09 — UserSettingsEngine abstract base. Barrel for engines.

import 'package:pool_os/features/user_settings/domain/capability.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_request.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_response.dart';

export 'capability.dart';
export 'user_settings_request.dart';
export 'user_settings_response.dart';

abstract class UserSettingsEngine {
  String get engineId;
  Future<UserSettingsContribution> run(UserSettingsRequest request);
}