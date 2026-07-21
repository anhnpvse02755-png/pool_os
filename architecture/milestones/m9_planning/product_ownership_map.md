# M9 Product Ownership Map

| Concern | Authoritative owner | Product layer responsibility |
|---|---|---|
| Player identity/projection | M3 Player Model | Render and navigate |
| Experience/progress | M2/M3 projections | Compare and explain structured values |
| Coach context/decision | M3 Coach contracts | Present trace and lifecycle |
| Plan/recommendation/execution | M3 contracts | Coordinate user workflow and commands |
| Runtime composition/delivery | M6/M8 contracts | Show readiness metadata only |
| AI session/response/provider | M3 AI contracts | Display structured boundary results |
| Knowledge content | Knowledge authoring/runtime | Link to published content through ports |
| Product feedback | Product Operations | Route observations to approved owners |

The product layer never becomes source of truth for any row above.
