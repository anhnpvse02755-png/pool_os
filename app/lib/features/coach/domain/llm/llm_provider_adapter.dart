// EPIC 06 — LLM Provider Adapter.
//
// PO 2026-07-31 — architecture:
//
//   UI → CoachService → 6 Engines → LlmProviderAdapter → (provider)
//
// Single file surface for the LLM lane. Engine code ONLY depends on
// the `LlmProviderAdapter` interface; concrete providers (MockAI,
// OpenAI, Claude, Gemini) are registered through the `LlmProviderRegistry`.
//
// Capability pattern (EPIC 04 standard):
//   - MockAI         : implemented   (Beta default, offline)
//   - OpenAI/Claude/Gemini : notAvailable (PO authorization required)
//
// Engines call `LlmProviderAdapter.complete(request)` and receive a
// `CapabilityResult<LlmResponse>` — never an exception (EPIC 04
// Capability Pattern).

import 'package:pool_os/features/coach/domain/llm/capability.dart';

/// Conversation request shaped by an engine. Self-contained so the
/// provider has zero coupling to engines.
class LlmRequest {
  final String capabilityId;
  final String prompt;
  final Map<String, Object?> context;

  const LlmRequest({
    required this.capabilityId,
    required this.prompt,
    this.context = const <String, Object?>{},
  });
}

/// Conversation response from a provider.
class LlmResponse {
  final String providerId;
  final String providerContractVersion;
  final String text;
  final Map<String, Object?> structured;
  final Duration latency;

  const LlmResponse({
    required this.providerId,
    required this.providerContractVersion,
    required this.text,
    this.structured = const <String, Object?>{},
    this.latency = Duration.zero,
  });
}

/// Adapter that engines depend on. Returns a CapabilityResult so the
/// UI never has to handle exceptions for capability-closed providers.
abstract class LlmProviderAdapter {
  String get providerId;
  String get providerContractVersion;
  bool get isImplemented;

  CapabilityResult<LlmResponse> complete(LlmRequest request);
}

/// In-process mock that answers from a deterministic function. Default
/// provider for Beta; offline, no API key, no exceptions.
class MockAIAdapter implements LlmProviderAdapter {
  const MockAIAdapter();

  @override
  String get providerId => 'mock_ai';

  @override
  String get providerContractVersion => 'v1';

  @override
  bool get isImplemented => true;

  @override
  CapabilityResult<LlmResponse> complete(LlmRequest request) {
    final text = _mockFor(request);
    return CapabilityResult<LlmResponse>.withValue(
      LlmResponse(
        providerId: providerId,
        providerContractVersion: providerContractVersion,
        text: text,
        structured: <String, Object?>{
          'capabilityId': request.capabilityId,
          'echoPrompt': request.prompt.length > 100
              ? '${request.prompt.substring(0, 100)}…'
              : request.prompt,
        },
        latency: Duration.zero,
      ),
    );
  }

  String _mockFor(LlmRequest req) {
    switch (req.capabilityId) {
      case 'recommendation.summary':
        return 'Mock recommendation: focus on cut-shot mechanics this session.';
      case 'strategy.race':
        return 'Mock strategy: keep the cue ball in the rail after the 6-ball.';
      case 'pattern.detect':
        return 'Mock pattern: 3-of-4 missed position play after the break.';
      case 'equipment.suggest':
        return 'Mock equipment: keep current tip; rotate chalk more often.';
      case 'training.suggest':
        return 'Mock program: 3× cut-shot drills + 2× position drills this week.';
      case 'match.review':
        return 'Mock review: strengths = break, weaknesses = position play.';
      default:
        return 'Mock AI Coach acknowledges: ${req.prompt}';
    }
  }
}

/// Capability-gated OpenAI provider stub. Returns NotAvailable unless
/// PO authorization key set; mirrors EPIC 04 pattern.
class OpenAIAdapter implements LlmProviderAdapter {
  const OpenAIAdapter();

  @override
  String get providerId => 'openai';

  @override
  String get providerContractVersion => 'v1';

  @override
  bool get isImplemented => false;

  @override
  CapabilityResult<LlmResponse> complete(LlmRequest request) {
    return CapabilityResult<LlmResponse>.notAvailable(
      const CapabilityReason(
        code: 'openai_capability_closed_beta',
        message:
            'OpenAI LLM capability is closed in Pool OS Beta. PO '
            'authorization required. See LlmProviderAdapter registry.',
      ),
    );
  }
}

class ClaudeAIAdapter implements LlmProviderAdapter {
  const ClaudeAIAdapter();

  @override
  String get providerId => 'claude';

  @override
  String get providerContractVersion => 'v1';

  @override
  bool get isImplemented => false;

  @override
  CapabilityResult<LlmResponse> complete(LlmRequest request) {
    return CapabilityResult<LlmResponse>.notAvailable(
      const CapabilityReason(
        code: 'claude_capability_closed_beta',
        message:
            'Claude LLM capability is closed in Pool OS Beta. PO '
            'authorization required.',
      ),
    );
  }
}

class GeminiAIAdapter implements LlmProviderAdapter {
  const GeminiAIAdapter();

  @override
  String get providerId => 'gemini';

  @override
  String get providerContractVersion => 'v1';

  @override
  bool get isImplemented => false;

  @override
  CapabilityResult<LlmResponse> complete(LlmRequest request) {
    return CapabilityResult<LlmResponse>.notAvailable(
      const CapabilityReason(
        code: 'gemini_capability_closed_beta',
        message:
            'Gemini LLM capability is closed in Pool OS Beta. PO '
            'authorization required.',
      ),
    );
  }
}

/// Registry — sole place that maps the provider id to its adapter.
class LlmProviderRegistry {
  static const Map<String, LlmProviderAdapter> _byId = <String, LlmProviderAdapter>{
    'mock_ai': MockAIAdapter(),
    'openai': OpenAIAdapter(),
    'claude': ClaudeAIAdapter(),
    'gemini': GeminiAIAdapter(),
  };

  static const String defaultProviderId = 'mock_ai';

  static LlmProviderAdapter get defaultProvider =>
      _byId[defaultProviderId] ?? const MockAIAdapter();

  static LlmProviderAdapter byId(String providerId) {
    final adapter = _byId[providerId];
    if (adapter == null) {
      throw ArgumentError('Unknown LLM provider: $providerId');
    }
    return adapter;
  }

  static List<LlmProviderAdapter> get allProviders =>
      _byId.values.toList(growable: false);
}

/// Provider health summary surfaced in UI banner. Mirrors the
/// RecommendationCapability shape used in EPIC 05.
class LlmProviderHealth {
  final String providerId;
  final bool implemented;
  final String? reasonCode;
  final String? reasonMessage;

  const LlmProviderHealth({
    required this.providerId,
    required this.implemented,
    this.reasonCode,
    this.reasonMessage,
  });

  static List<LlmProviderHealth> summary() {
    return LlmProviderRegistry.allProviders
        .map((adapter) => LlmProviderHealth(
              providerId: adapter.providerId,
              implemented: adapter.isImplemented,
            ))
        .toList(growable: false);
  }
}