# Roadmap V3 — Release Hardening

Status:
In Progress

Roadmap:
V3 (Beta → Release Candidate)

Phase:
H — Release Hardening

Objective:
Transform 9 completed EPICs into a production-ready application.
Not a single new feature shall be added. All effort goes to quality.

---

# H0 — Philosophy

## Why "Hardening" not "More EPICs"?

9 EPICs closed does NOT mean a production-ready app.

A project with perfect architecture and zero regression can still be:

- Full of dead UI navigation
- Missing empty/error/loading states
- Plagued by memory leaks
- Operating on stale or broken knowledge data
- Running AI with incomplete context
- Slower than a web page from 2010

The value of Pool OS lives in three pillars:

1. **Knowledge Base** — deep enough for a player to learn something new
2. **AI Coach** — using real player data to give useful analysis and suggestions
3. **Training System** — connected to statistics and knowledge in a loop:
   play → record → analyze → train → improve

If these three pillars don't work in practice, no amount of new screens will matter.

---

# H1 — Architecture Audit

## Goal: Verify the architecture holds under inspection.

### Dependency Graph

- Map all inter-feature dependencies
- Identify circular dependencies
- Verify each feature only touches its own domain

### Code Purity

- **Repository purity** — does each feature use only its own repository?
- **Service purity** — are Service/Engine/Pipeline boundaries respected?
- **Provider purity** — no cross-feature Riverpod providers leaking state
- **Capability purity** — no feature imports another feature's capability

### Code Quality

- Dead code (never called, never exported)
- Duplicate logic across features
- Naming consistency (PascalCase, camelCase, kebab-case rules)
- Folder structure consistency

### Baseline

- Lock the regression suite at its current passing count
- Any hardening change must not decrease the test count

---

# H2 — Feature Audit

## Goal: Verify every feature has its complete deliverable surface.

For each feature, verify it has:

### Equipment

- Add / Edit / Delete
- History / Usage / Maintenance
- Statistic display
- Marketplace listing
- Comparison
- Inventory management
- AI integration

### Knowledge

- Articles / Videos
- Categories
- Search
- Learning paths
- Bookmarks
- Reading progress
- Pattern library

### Training

- Session creation / completion
- Drill library
- Connection to statistics
- Connection to knowledge
- Progress tracking

### AI Coach

- All 7 surfaces operational
- Context reads from: Knowledge / Statistics / Training / Equipment / Pattern / History / Match / Video / Article
- No hardcoded responses
- No fake/mock responses in production

### Community

- Friends / Feed / Sharing
- Challenge / Notification
- No spam / no dead links
- No placeholder content

### Marketplace

- Listings / Search / Filter / Sort
- Reviews / Ratings
- Wishlist
- Inventory

### Tournament

- Bracket generation
- Match recording
- Handicap resolution
- Results

---

# H3 — UX Audit

## Goal: Every screen handles all states.

Every screen MUST have:

| State | Requirement |
|---|---|
| **Loading** | Skeleton or spinner, never blank |
| **Empty** | Friendly empty state with action |
| **Error** | Error message + retry action |
| **Success** | Proper data display |
| **Pull Refresh** | Swipe-to-refresh where applicable |
| **Search** | Functional search with results |
| **Sort** | Sort controls where applicable |
| **Filter** | Filter controls where applicable |
| **Pagination** | Lazy loading / infinite scroll for long lists |

---

# H4 — Performance Audit

## Goal: App is fast and stable.

### Widget Rebuilds

- Verify `watch` vs `select` usage in Riverpod
- No unnecessary rebuilds on the critical path

### Memory Management

- No `dispose()` missing on StatefulWidgets
- No StreamSubscription left open
- No listener leaks

### Data Loading

- Image cache configuration (size limits)
- Lazy loading for long lists
- List virtualization for 100+ items
- `Isolate` for heavy computation (e.g., statistics calculation)

### App Size

- Verify no unnecessary assets bundled
- Proguard / tree shaking applied

---

# H5 — Knowledge Audit

## Goal: Knowledge base is deep, accurate, and alive.

### Content Inventory

Current estimate: ~900 knowledge items across articles, videos, patterns, and learning paths.

### Verify

- [ ] No duplicate entries
- [ ] Correct category placement
- [ ] No broken internal links
- [ ] Videos: no dead URLs
- [ ] Articles: no dead external references
- [ ] Learning paths: logical progression
- [ ] Tags and aliases: consistent naming
- [ ] Relationships between items: accurate

### AI Context

- AI Coach prompt reads from: Knowledge / Statistics / Training / Equipment / Pattern / History / Match / Video / Article
- Verify the prompt has sufficient context for each surface
- No hallucinated responses in production mode

---

# H6 — AI Audit

## Goal: AI Coach uses real player data, not placeholders.

### Coach surfaces (EPIC 06)

For each surface, verify:

- Coach / Recommendation / Strategy / Pattern Analysis / Equipment Suggestion / Training Suggestion / Match Review

### Context verification

AI must read from ALL of these sources (not a subset):

```
Knowledge
  ↓
Statistics
  ↓
Training
  ↓
Equipment
  ↓
Pattern
  ↓
History
  ↓
Match
  ↓
Video
  ↓
Article
```

### Production mode

- MockAI replaced by real provider (or capability-closed)
- No "Not implemented" in production responses
- No hallucinated statistics

---

# H7 — Beta Readiness Checklist

## Gate: Nothing ships until all pass.

### Core Stability

- [ ] No crash on cold start
- [ ] No crash on network failure
- [ ] No crash on empty database
- [ ] Regression suite: current count maintained

### Navigation

- [ ] No dead navigation routes
- [ ] No placeholder screens
- [ ] No TODO comments in UI
- [ ] Back button works correctly everywhere

### Data Integrity

- [ ] No fake data in production builds
- [ ] No mock responses in production
- [ ] No placeholder text ("Lorem ipsum", "TBD", "Coming soon")
- [ ] All export/import functions tested end-to-end

### Feature Completeness

- [ ] Tournament: full bracket → results flow
- [ ] Training: session creation → drill → completion → statistics
- [ ] Knowledge: browse → read → bookmark → progress tracking
- [ ] AI Coach: all 7 surfaces return meaningful responses
- [ ] Marketplace: create listing → browse → purchase → history
- [ ] Community: friend → share → comment → notification

### Performance

- [ ] Cold start < 3 seconds on mid-range device
- [ ] No UI jank during list scrolling
- [ ] No memory growth over 10-minute session
- [ ] Image loading does not block UI

### Backup / Restore

- [ ] User can export all personal data
- [ ] User can restore from backup
- [ ] Checksum validation works
- [ ] Rollback on corruption works

---

# H8 — Release Criteria

## Before V3 Release Candidate tag:

1. H1 (Architecture) — 0 critical issues
2. H2 (Feature) — all features complete per spec
3. H3 (UX) — all screens have all states
4. H4 (Performance) — all benchmarks pass
5. H5 (Knowledge) — audit complete, broken links fixed
6. H6 (AI) — AI uses all data sources, no hallucinations
7. H7 (Beta Checklist) — 100% green

**No new Epic. No new feature. No new screen.**

The goal of H8 is a single, stable, shippable application.

---

# Timeline (PO defines)

Hardening is not a sprint. PO defines the timeline.

Priority order:
1. H5 (Knowledge) — highest value to players
2. H6 (AI) — highest differentiation
3. H3 (UX) — most visible to players
4. H1 (Architecture) — foundation confidence
5. H4 (Performance) — stability
6. H2 (Feature) — completeness verification
7. H7 (Beta Checklist) — final gate

---

*Roadmap authored by PO 2026-07-31. Hardening phases H1–H8 defined by PO.
Engineering ready to execute at PO direction.*