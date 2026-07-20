# Billiard Knowledge Module (BKM) - Project Vision

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Module Purpose and Vision

### 1.1 Mission Statement

The Billiard Knowledge Module (BKM) is a comprehensive, multi-disciplinary knowledge base designed to serve as the definitive reference for billiards terminology, techniques, strategies, and domain knowledge. BKM powers Pool OS with authoritative content that elevates players, coaches, referees, and enthusiasts across all skill levels.

**Core Vision:** democratize billiards expertise by providing structured, searchable, and interconnected knowledge that was previously scattered across books, videos, forums, and expert minds.

### 1.2 Strategic Objectives

| Objective | Description | Target Outcome |
|-----------|-------------|----------------|
| **Authoritative Knowledge** | Create the single source of truth for billiards terminology and techniques | 95%+ accuracy verified by domain experts |
| **Universal Accessibility** | Make knowledge available in multiple languages | 4 languages at launch, 8+ by v3 |
| **Intelligent Discovery** | Enable AI-powered learning paths and recommendations | 80%+ user engagement with AI features |
| **Offline-First** | Ensure knowledge availability without internet | Full functionality on mobile devices |
| **Cross-Discipline Integration** | Connect concepts across billiards variants | Minimum 3 relationships per term |

### 1.3 Target Users

| User Type | Primary Use Case | Knowledge Needs |
|-----------|------------------|-----------------|
| **Beginner Player** | Learning fundamentals | Basic terminology, simple techniques |
| **Intermediate Player** | Improving skills | Advanced techniques, tactical thinking |
| **Professional Player** | Elite competition preparation | Edge-case rules, mental strategies |
| **Coach** | Teaching and training | Methodologies, drill designs |
| **Referee** | Match officiating | Complete rule references, edge cases |
| **Enthusiast/Fan** | General knowledge | History, famous shots, tournaments |
| **Content Creator** | Producing educational material | Structured references, media assets |
| **AI/Developer** | Building on Pool OS | API access, structured data |

---

## 2. Supported Disciplines

### 2.1 Pool (Pocket Billiards)

**Discipline Code:** `pool`
**Variants Supported:**

| Variant | Code | Special Characteristics |
|---------|------|-------------------------|
| 8-Ball | `pool_8ball` | 8-ball pocketed last, balls 1-7 (solids), 9-15 (stripes) |
| 9-Ball | `pool_9ball` | Must contact lowest ball first, any ball can be pocketed |
| 10-Ball | `pool_10ball` | Similar to 9-ball, 10 balls, called ball rules |
| Straight Pool | `pool_straight` | Any ball in any pocket, 100+ balls required to win |
| 14.1 Continuous | `pool_14_1` | Former world standard, 15 balls + cue ball |
| One-Pocket | `pool_one_pocket` | Each player assigned two pockets |
| Banks Pool | `pool_banks` | Primary scoring via bank shots |
| Chicago | `pool_chicago` | Balls worth predetermined points |
| Cowboy Pool | `pool_cowboy` | Call-shot, any ball pocketed |
| Kill the 8 | `pool_kill_8` | 8-ball must be pocketed last |
| Rotation | `pool_rotation` | Lowest ball must be hit first |

### 2.2 Snooker

**Discipline Code:** `snooker`
**Special Characteristics:**

- 22 balls total (15 reds, 6 colors, 1 cue ball)
- Points accumulate from ball values (red = 1, colors = 2-7)
- Baulk line and D formation
- Snookered position rules
- Maximum break: 147 (15 reds × 7 + all colors)

### 2.3 Carom Billiards

**Discipline Code:** `carom`
**Variants Supported:**

| Variant | Code | Special Characteristics |
|---------|------|-------------------------|
| Three-Cushion | `carom_3cushion` | Ball must contact 3 cushions before hitting object ball |
| Straight Rail | `carom_straight` | Carom off both object balls on single rail |
| Balkline | `carom_balkline` | Restriction on where caroms can be made |
| Artistic Billiards | `carom_artistic` | Multiple prescribed shots for points |

### 2.4 Chinese Eight Ball

**Discipline Code:** `chinese_8ball`
**Special Characteristics:**

- Combines pool and snooker elements
- 21 object balls + cue ball
- Balls divided into groups by color (6 colors × 3 balls + 8-ball)
- Baulk area with baulk line and D
- More complex safety play than traditional 8-ball

---

## 3. Supported Languages

### 3.1 Language Support Matrix

| Language | Code | Native Name | Status | Coverage Target |
|----------|------|-------------|--------|-----------------|
| **English** | `en` | English | ✅ Primary | 100% |
| **Vietnamese** | `vi` | Tiếng Việt | ✅ Primary | 100% |
| **Japanese** | `ja` | 日本語 | 🔄 v2 | 90% |
| **Korean** | `ko` | 한국어 | 🔄 v2 | 90% |
| **Simplified Chinese** | `zh_CN` | 简体中文 | 🔄 v2 | 90% |
| **Traditional Chinese** | `zh_TW` | 繁體中文 | 🔄 v3 | 85% |
| **Thai** | `th` | ภาษาไทย | 📋 Planned | 80% |
| **German** | `de` | Deutsch | 📋 Planned | 80% |
| **French** | `fr` | Français | 📋 Planned | 80% |
| **Spanish** | `es` | Español | 📋 Planned | 80% |

### 3.2 Language-Specific Considerations

#### 3.2.1 English (Primary)

- All terms originate in English
- Technical vocabulary often remains untranslated
- International standard for competition

#### 3.2.2 Vietnamese (Primary)

- Growing billiards community in Vietnam
- Strong 3-Cushion Carom tradition
- Terminology blends French influences with local adaptations
- **Key Challenge:** Technical terms often used in English

#### 3.2.3 Japanese, Korean, Chinese (v2)

- CJK character support required
- Directional text (LTR/RTL considerations for Arabic in future)
- Cultural context for teaching methodologies
- **Key Challenge:** Unified Han characters across variants

---

## 4. Integration with Pool OS

### 4.1 System Context

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Pool OS Ecosystem                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐   ┌──────────────┐   ┌────────────────────────┐  │
│  │  BKM Module  │◄──│  Coach AI    │◄──│  Statistics Engine     │  │
│  │              │   │              │   │                        │  │
│  │  • Terms     │   │  • Explain   │   │  • Shot Analysis       │  │
│  │  • Drills    │   │  • Recommend │   │  • Pattern Detection   │  │
│  │  • Rules     │   │  • Quiz      │   │  • Progress Tracking   │  │
│  │  • Media     │   │  • Paths     │   │  • Performance Metrics │  │
│  └──────────────┘   └──────────────┘   └────────────────────────┘  │
│         │                  │                       │               │
│         └──────────────────┼───────────────────────┘               │
│                            │                                       │
│                   ┌────────▼────────┐                               │
│                   │   Intelligence  │                               │
│                   │     Engine      │                               │
│                   └────────┬────────┘                               │
│                            │                                       │
│  ┌──────────────┐   ┌──────▼──────┐   ┌────────────────────────┐  │
│  │   Database   │◄──│  API Layer  │──►│     Flutter App       │  │
│  │  (Supabase)  │   │             │   │                        │  │
│  │  + SQLite    │   │  • REST     │   │  • iOS                 │  │
│  │              │   │  • GraphQL  │   │  • Android             │  │
│  └──────────────┘   └─────────────┘   │  • Web                 │  │
│                                        └────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Integration Points

| Integration | Description | Data Flow |
|-------------|-------------|-----------|
| **Coach AI** | BKM provides domain knowledge for AI explanations | BKM → AI Context |
| **Statistics Engine** | Technique definitions link to statistical analysis | Bidirectional |
| **Learning Hub** | Drills and content sourced from BKM | BKM → Learning Hub |
| **Tournament Module** | Rule definitions for match management | BKM → Tournament |
| **Search System** | Unified search across all modules | BKM → Global Search |

### 4.3 Data Sharing Contracts

```
BKM provides structured JSON responses via API:

{
  "module": "bkm",
  "version": "v2",
  "term": {
    "id": "uuid",
    "slug": "draw-shot",
    "language": "en",
    "content": {...}
  },
  "related_terms": [...],
  "media": [...],
  "ai_context": {...}
}
```

---

## 5. Design Philosophy

### 5.1 Core Principles

#### 5.1.1 Accuracy First

> "In billiards, precision is everything. Our knowledge must reflect that precision."

- Every term verified by certified coaches or official rulebooks
- Cross-references validated for consistency
- Version history tracks all changes
- Expert review before publication

#### 5.1.2 Interconnected Knowledge

Knowledge exists in context, not isolation:

```
Term A ──uses──► Technique B ──prerequisite──► Technique C
    │                                           ▲
    │                                           │
    └───related_to─────────────────────────────┘
```

#### 5.1.3 Language-Agnostic Structure

The schema supports any language without modification:

```json
{
  "term": {
    "translations": {
      "en": { "name": "Draw Shot", "definition": "..." },
      "vi": { "name": "Úp Bóng", "definition": "..." }
    }
  }
}
```

#### 5.1.4 Offline-First Architecture

- All content available without internet
- SQLite for local storage
- Sync when connectivity available
- Conflict resolution for concurrent edits

#### 5.1.5 AI-Ready Design

- Vector embeddings for semantic search
- Structured prompts for consistent AI responses
- Context injection for domain-specific generation

### 5.2 Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Term Duplication** | Same concept with different names | Single source with aliases |
| **Inconsistent Definitions** | Contradictory explanations | Expert review workflow |
| **Flat Structure** | No relationships between terms | Graph-based relationships |
| **Language Siloing** | Translations not linked | Unified entity with translations |
| **Media Decoupling** | Images separate from content | Embedded references with CDN |

---

## 6. Success Metrics

### 6.1 Content Quality Metrics

| Metric | Definition | Target | Measurement |
|--------|------------|--------|-------------|
| **Accuracy Rate** | % of content verified by experts | >98% | Expert review score |
| **Completeness** | Terms with full definitions | >95% | Automated checks |
| **Cross-Reference Coverage** | Terms with related terms | >90% | Relationship count |
| **Translation Coverage** | Primary language parity | 100% EN→VI | Translation audit |
| **Media Attachments** | Terms with relevant media | >75% | Media presence |

### 6.2 System Performance Metrics

| Metric | Definition | Target | SLA |
|--------|------------|--------|-----|
| **Search Latency (p50)** | Time to first result | <100ms | 99th percentile |
| **API Response Time** | Full term retrieval | <200ms | 99th percentile |
| **Offline Sync Time** | Full knowledge sync | <30s | On WiFi |
| **Vector Search Accuracy** | Relevance score | >0.85 | NDCG@10 |

### 6.3 User Engagement Metrics

| Metric | Definition | Target | Tracking |
|--------|------------|--------|----------|
| **Search Success Rate** | % of searches with results | >95% | Analytics |
| **Term View Depth** | Average related terms visited | >3 | Session tracking |
| **AI Feature Usage** | % using AI explanations | >60% | Feature flags |
| **Learning Path Completion** | % completing recommended paths | >40% | Cohort analysis |

### 6.4 Growth Metrics

| Metric | Definition | v1 Target | v2 Target | v3 Target |
|--------|------------|-----------|-----------|-----------|
| **Term Count** | Total knowledge terms | 500 | 2,000 | 5,000 |
| **Language Pairs** | Supported translations | 2 | 5 | 10 |
| **Media Assets** | Images, videos, animations | 1,000 | 5,000 | 15,000 |
| **API Calls/Month** | External integrations | 100K | 1M | 10M |

---

## 7. Versioning Strategy

### 7.1 Version Lifecycle

```
v1.0 (Launch) ──► v1.1 ──► v1.2 ──► ...
       │                          │
       │                          ▼
       │                    v2.0 (Major Release)
       │                          │
       ▼                          ▼
  Foundation                  Expansion
  - Core terms                 - New languages
  - EN + VI                   - Advanced features
  - Basic search               - Enhanced AI
```

### 7.2 Compatibility Guarantees

| Version | API Stability | Data Migration | Support Period |
|---------|--------------|----------------|----------------|
| **v1.x** | Stable | Automatic | 24 months |
| **v2.x** | Stable | Auto + Manual | 24 months |
| **v3.x** | Current | Guided | 36 months |

### 7.3 Breaking Changes

Breaking changes are communicated via:

1. **6 months advance notice** in release notes
2. **Deprecation warnings** in API responses
3. **Migration guides** for data transformation
4. **Dual support** for old and new formats during transition

---

## 8. Governance

### 8.1 Content Governance

| Role | Responsibility | Authority |
|------|---------------|-----------|
| **Domain Expert Council** | Accuracy verification | Final approval |
| **Language Leads** | Translation quality | Language-specific changes |
| **Technical Lead** | System architecture | Technical decisions |
| **Community Manager** | User feedback | Content prioritization |

### 8.2 Change Management

1. **Proposal** → Anyone can suggest content changes
2. **Review** → Domain expert validates accuracy
3. **Translation** → Language lead verifies quality
4. **Publication** → Automated release after approval
5. **Monitoring** → User feedback and analytics

---

## 9. Appendix

### 9.1 Related Documents

- [BKM Architecture](./02_Architecture.md)
- [BKM Database Schema](./03_Database.md)
- [BKM Search System](./05_Search_System.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

### 9.2 External References

- WPA (World Pool-Billiard Association) Rules
- World Professional Billiards and Snooker Association (WPBSA)
- Union Mondiale de Billard (UMB) - Carom
- Chinese Billiards Association Standards

### 9.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | July 2026 | Pool OS Team | Initial specification |

---

**End of Document**
