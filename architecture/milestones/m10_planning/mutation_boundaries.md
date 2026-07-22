# M10 Mutation Boundaries

M10.0 introduces no mutation. The table defines constraints for later
capability implementation.

| Capability | Reads | Future authorized effect | Must not mutate |
|---|---|---|---|
| M10.1 Bootstrap | delivery/shell identity, explicit startup input | emit bootstrap result | Runtime Core or domain state |
| M10.2 Composition Root | bootstrap result, service registry/dependencies | construct and dispose owned adapter instances | contracts, decisions, projections |
| M10.3 Activation | composition binding, public activation contracts | issue activation command through Runtime port | runtime tables or service internals directly |
| M10.4 Lifecycle Host | bootstrap/activation results, lifecycle projection | issue start/stop through public host/runtime ports | historical transitions or projections |
| M10.5 Health | public validation/state/exposure projections | emit diagnostic projection | runtime state or alert policy |
| M10.6 Configuration | adapter-provided environment values | emit normalized immutable configuration | process environment or domain contracts |
| M10.7 Readiness | activation, lifecycle, health, configuration, freeze proof | emit immutable pass/fail proof | any input or deployment target |
| M10.8 Delivery Gate | readiness proof and delivery identity | emit authorization record | Runtime Core, artifacts, deployment infrastructure |

All effects must be explicit commands or immutable records through public
ports. Direct database, filesystem, process, network, provider, or UI mutation
inside deterministic Runtime Core is prohibited.
