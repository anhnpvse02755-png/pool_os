// EPIC 08 — MarketplaceEngine abstract base. Barrel for engines.

import 'package:pool_os/features/marketplace/domain/capability.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_request.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_response.dart';
import 'package:pool_os/features/marketplace/domain/models/marketplace_models.dart';

export 'capability.dart';
export 'marketplace_request.dart';
export 'marketplace_response.dart';
export 'models/marketplace_models.dart';

abstract class MarketplaceEngine {
  String get engineId;
  Future<MarketplaceContribution> run(MarketplaceRequest request);
}