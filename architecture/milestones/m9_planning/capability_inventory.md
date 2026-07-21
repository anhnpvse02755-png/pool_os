# M9 Capability Inventory

| Capability | Purpose | Owner | Depends on | Primary frozen inputs |
|---|---|---|---|---|
| M9.1 Product Shell & Navigation | Organize product destinations and feature entry points | Product Application | M8 Freeze | public projections |
| M9.2 Player Profile & Progress | Present player identity and progress projections | Product Experience | M9.1 | M3 Player, M2 Experience |
| M9.3 Training Session Workspace | Present session setup, execution references, and outcomes | Product Experience | M9.1, M9.2 | M3 Execution, M6 Runtime |
| M9.4 Coach Context & Decision View | Present structured context, decisions, and traces | Product Coach Experience | M9.2, M9.3 | M3 Coach Context/Decision |
| M9.5 Plan & Recommendation Inbox | Present plan steps and recommendation lifecycle | Product Coach Experience | M9.4 | M3 Plan/Recommendation |
| M9.6 Execution & Outcome Tracking | Present accepted/deferred/completed execution records | Product Experience | M9.3, M9.5 | M3 Execution |
| M9.7 AI Coach Interaction Surface | Present AI request/response boundaries as structured product surface | Product AI Experience | M9.4, M9.5, M9.6 | M3.9-M3.13 AI boundaries |
| M9.8 Product Analytics & Feedback Loop | Observe product usage and route feedback to owned policies/knowledge | Product Operations | M9.2, M9.3, M9.6, M9.7 | public projections only |

M9.0 authorizes no implementation of these rows.
