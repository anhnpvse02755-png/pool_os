// EPIC 08 — Marketplace Service Riverpod providers.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_pipeline.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_service.dart';

final marketplacePipelineProvider = Provider<MarketplacePipeline>(
  (ref) => defaultMarketplacePipeline(),
);

final marketplaceServiceProvider = Provider<MarketplaceService>(
  (ref) => MarketplaceService(ref.watch(marketplacePipelineProvider)),
);
