# M12 Capability Inventory

| Capability | Purpose | Owner | Depends on | Frozen public inputs |
|---|---|---|---|---|
| M12.1 Flutter Application Adapter | Translate Flutter lifecycle and interaction into Product/Application commands and render public projections | Product Application adapter | M12.2, M11 Freeze | ProductShellContract, ProductFeatureAssemblyPlan, EndToEndApplicationCompositionPlan |
| M12.2 Configuration Adapter | Read platform configuration and emit normalized versioned configuration input | Infrastructure Configuration | M11 Freeze | RuntimeConfigurationEnvironmentProjectionContract and public provenance rules |
| M12.3 Persistence Adapter | Implement future approved repository ports without exposing storage schemas to domain owners | Infrastructure Persistence | M12.2, M11 Freeze | Frozen public repository ports and serializable contracts only |
| M12.4 Transport Adapter | Translate HTTP, REST, WebSocket, and external API payloads at public application ports | Infrastructure Transport | M12.2, M11 Freeze | RuntimeDeliveryProjectionContract and public application service ports |
| M12.5 AI Provider Adapter | Translate frozen AI provider requests/results to a selected provider implementation | AI Infrastructure | M12.2, M11 Freeze | AIProvider, AIProviderRequestContract, AIProviderResult |
| M12.6 Observability Adapter | Export structured diagnostics, logs, metrics, and telemetry without becoming runtime truth | Runtime Operations adapter | M12.2, M11 Freeze | RuntimeHealthDiagnosticsProjectionContract, RuntimeObservabilityIntegrationPlan |
| M12.7 Packaging & Deployment Adapter | Package and deliver validated artifacts after accepted release gates | Release Infrastructure | M12.2, M11 Freeze | RuntimeActivationDeliveryGateContract, ProductionStartupValidationPlan, EndToEndApplicationCompositionPlan |
| M12.8 Infrastructure Integration Validation | Prove cross-adapter compatibility, ownership, startup readiness, and boundary conformance | Release Governance | M12.1-M12.7 | All accepted M12 adapter outputs and frozen M11 plans |

M12.0 authorizes no implementation of these capabilities. Each capability
requires a separately approved executable scope.

