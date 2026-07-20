# Billiard Knowledge Module (BKM) - Glossary Guideline

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Glossary Purpose and Scope

### 1.1 What Is a Glossary

A glossary is a curated collection of billiards terms with authoritative definitions, designed to serve as a reliable reference for players, coaches, referees, and enthusiasts at all skill levels.

### 1.2 Purpose Statement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GLOSSARY PURPOSE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   EDUCATE          →           STANDARDIZE          →           CONNECT      │
│                                                                              │
│   Help learners          Ensure consistent          Link related concepts   │
│   understand              terminology across                   for better     │
│   billiards terms         all Pool OS content           understanding       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Scope Definition

| Included | Excluded |
|----------|----------|
| ✅ Technical billiards terms | ❌ General English words |
| ✅ Techniques and shots | ❌ Slang without wide usage |
| ✅ Rules and regulations | ❌ Marketing jargon |
| ✅ Equipment terminology | ❌ Brand-specific names |
| ✅ Tournament terminology | ❌ Offensive language |
| ✅ Historical terms | ❌ Highly regional slang |

### 1.4 Coverage Areas

| Category | Examples | Priority |
|----------|----------|----------|
| **Shot Types** | Draw, Follow, Stun, Massé | P0 |
| **Techniques** | Aiming, Bridging, Stance | P0 |
| **Rules** | Fouls, Penalties, Procedures | P0 |
| **Equipment** | Cue, Table, Balls, Cloth | P1 |
| **Strategy** | Position, Safety, Pattern | P1 |
| **Tournament** | Formats, Scoring, Etiquette | P2 |
| **History** | Historical terms, Origins | P3 |

---

## 2. Term Selection Criteria

### 2.1 Inclusion Criteria

A term should be included if it meets **ALL** of the following:

| Criterion | Description | Verification |
|-----------|-------------|---------------|
| **Relevance** | Directly related to billiards | Domain expert review |
| **Usage** | Used by players/community | Source documentation |
| **Need** | Fills a knowledge gap | Gap analysis |
| **Accuracy** | Can be defined correctly | Expert verification |
| **Stability** | Established, not trending | Usage history |

### 2.2 Term Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TERM CATEGORIES                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   CORE TERMS                                                                 │
│   ├── Fundamental techniques, rules, equipment                              │
│   └── Must be in every learner's vocabulary                                 │
│                                                                              │
│   SPECIALIZED TERMS                                                          │
│   ├── Advanced techniques, tournament rules                                  │
│   └── Important for intermediate+ players                                  │
│                                                                              │
│   HISTORICAL TERMS                                                           │
│   ├── Obsolete but significant terms                                        │
│   └── Important for understanding historical context                        │
│                                                                              │
│   REGIONAL TERMS                                                             │
│   ├── Region-specific terminology                                           │
│   └── Cross-referenced to standard terms                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Priority Matrix

| Priority | Criteria | Timeline |
|----------|----------|----------|
| **P0** | Core to every discipline | Phase 1 |
| **P1** | Important but not universal | Phase 2 |
| **P2** | Specialized, niche use | Phase 3 |
| **P3** | Historical, reference only | Phase 4+ |

### 2.4 Term Evaluation Questions

For each potential term, answer:

1. **Is it billiards-specific?** (Not general sports)
2. **Is it used by practitioners?** (Not just coaches)
3. **Would a learner encounter it?** (Practical relevance)
4. **Can it be defined unambiguously?** (Clarity)
5. **Does it add value over existing terms?** (Uniqueness)

---

## 3. Definition Structure

### 3.1 Required Definition Components

```json
{
  "term": "draw-shot",
  "name": {
    "en": "Draw Shot",
    "vi": "Úp Bóng"
  },
  
  "definition": {
    "primary": "A shot where the cue ball is struck below center...",
    "formal": "Technical definition from official sources...",
    "concise": "Short definition for search results..."
  },
  
  "components": {
    "what": "Description of the technique",
    "how": "Mechanics of execution",
    "why": "Purpose and application"
  }
}
```

### 3.2 Definition Template

```markdown
## [Term Name]

### Quick Definition
[One sentence, accessible to beginners]

### Full Definition
[2-3 paragraphs, progressive complexity]

### Technical Details
[Physics, mechanics, precision requirements]

### Related Concepts
[Linked terms with brief notes]

### Examples in Context
[Real-world usage examples]

### Common Mistakes
[What to avoid]
```

### 3.3 Definition Quality Standards

| Standard | Requirement | Example |
|----------|-------------|---------|
| **Clear** | No jargon without explanation | "Strike below center" not "inferior contact" |
| **Accurate** | Matches official definitions | Verified by rulebooks |
| **Complete** | All aspects covered | What, how, why, when |
| **Concise** | No unnecessary words | Direct language |
| **Neutral** | No bias | "is" not "should be" |
| **Accessible** | Appropriate for audience | Beginner level first |

### 3.4 Definition Examples

#### Good Definition

```markdown
### Draw Shot

**Quick Definition:** A shot where the cue ball is struck below center, 
causing it to reverse direction after contacting an object ball.

**Full Definition:** The draw shot is executed by striking the cue ball 
below its center point, which imparts backspin. When this spinning ball 
contacts an object ball, the backspin reverses the cue ball's forward 
momentum, causing it to roll back toward the player.

**Technical Detail:** The amount of backspin (and thus the distance the 
cue ball rolls back) depends on:
- How far below center the cue tip contacts
- The speed of the shot
- The condition of the cloth and balls
```

#### Poor Definition

```markdown
### Draw Shot

A type of shot. You hit the ball low. It goes back.
(Too vague, missing details)

or

### Draw Shot

Contact point below center axis creates angular velocity vector opposing 
linear momentum, resulting in negative displacement post-collision.
(Too technical, inaccessible)
```

---

## 4. Cross-Referencing Standards

### 4.1 When to Cross-Reference

| Situation | Action | Example |
|-----------|--------|---------|
| **Related Technique** | Link | Draw Shot → Follow Shot |
| **Prerequisite** | Link | Power Draw → Draw Shot |
| **Opposite** | Link | Draw Shot ↔ Follow Shot |
| **Part of Larger Concept** | Link | Bridge → Stroke Mechanics |
| **Same Concept** | Link via Alias | Draw Shot → Pull Shot |
| **Confusable** | Link with Note | Draw Shot ←→ Stop Shot |

### 4.2 Cross-Reference Format

```markdown
### Related Terms

**See Also:**
- [Follow Shot](./follow-shot.md) - Opposite technique using top spin
- [Backspin](./backspin.md) - The spin applied in a draw shot
- [Stop Shot](./stop-shot.md) - Similar setup, different result

**Prerequisites:**
- [Stance](./stance.md) - Foundation for all shots
- [Basic Aiming](./basic-aiming.md) - Required skill

**Confused With:**
- [Stop Shot](./stop-shot.md) - Often mistaken; see differences
```

### 4.3 Cross-Reference Types

| Type | Symbol | Usage |
|------|--------|-------|
| **See Also** | → | Related but not required |
| **Prerequisite** | ⬅ | Must understand first |
| **Leads To** | ➜ | Next concept to learn |
| **Opposite** | ↔ | Contrasting concept |
| **Part Of** | ⊂ | Component of larger |
| **Similar To** | ≈ | Nearly the same |

### 4.4 Bidirectional Linking

Every cross-reference should be reciprocated:

```
Draw Shot.md includes:
  → Links to: Follow Shot, Backspin, Stop Shot

Follow Shot.md must include:
  → Links to: Draw Shot (as opposite)

Backspin.md must include:
  → Links to: Draw Shot (as applied spin)
```

---

## 5. Maintenance Procedures

### 5.1 Content Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CONTENT LIFECYCLE                                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Draft  │ ──► │ Review │ ──► │Publish  │ ──► │ Monitor │ ──► │ Update  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘     └─────────┘
     │               │               │               │               │
     ▼               ▼               ▼               ▼               ▼
  Create         Expert         Make Live      Track         Revise as
  content        validate       with status    metrics       needed
                                   │
                                   ▼
                              ┌─────────┐
                              │ Archive │
                              └─────────┘
```

### 5.2 Review Schedule

| Content Type | Review Frequency | Reviewer |
|--------------|-----------------|----------|
| **Core Terms** | Every 6 months | Domain Expert |
| **Technical Terms** | Every 12 months | Domain Expert |
| **Rules Terms** | With rulebook updates | Referee Council |
| **Historical Terms** | Every 24 months | Historian |
| **Regional Terms** | Every 12 months | Regional Expert |

### 5.3 Update Triggers

| Trigger | Action |
|---------|--------|
| Official rule change | Update all rule-related terms |
| New technique emerges | Add new term |
| Technology changes | Update equipment terms |
| User feedback | Investigate and fix |
| Quality audit | Revise flagged content |
| Translation update | Sync across languages |

### 5.4 Version Control

| Version | Changes | Date |
|---------|---------|------|
| 1.0 | Initial publication | Jul 2026 |
| 1.1 | Added examples, cross-refs | Aug 2026 |
| 1.2 | Updated for v2 terminology | Oct 2026 |

---

## 6. Quality Standards

### 6.1 Quality Dimensions

| Dimension | Description | Target |
|-----------|-------------|--------|
| **Accuracy** | Correct information | 99% |
| **Completeness** | All aspects covered | 95% |
| **Clarity** | Easy to understand | 90% |
| **Consistency** | Uniform style and format | 100% |
| **Currency** | Up-to-date content | 95% |
| **Accessibility** | Available in all languages | 80% |

### 6.2 Quality Checklist

```markdown
## Quality Checklist for Each Term

### Content
- [ ] Definition is accurate (verified)
- [ ] All required fields populated
- [ ] Examples are relevant and correct
- [ ] Common mistakes identified
- [ ] Cross-references are bidirectional

### Format
- [ ] Follows definition template
- [ ] Uses proper heading hierarchy
- [ ] Code blocks have language specified
- [ ] Links are functional
- [ ] Tables are properly formatted

### Style
- [ ] Consistent voice (formal but accessible)
- [ ] Appropriate reading level
- [ ] No redundancy
- [ ] Clear, concise language

### Metadata
- [ ] Status is current
- [ ] Dates are accurate
- [ ] Tags are relevant
- [ ] Difficulty level is appropriate
```

### 6.3 Quality Review Process

```
Submitter creates/updates term
           │
           ▼
┌─────────────────────────┐
│   Automated Checks      │
│   • Schema validation   │
│   • Format check        │
│   • Link verification   │
└───────────┬─────────────┘
            │
            ▼ Pass?
      ┌─────┴─────┐
     Fail        Pass
      │            │
      ▼            ▼
┌──────────┐  ┌─────────────────┐
│ Fix      │  │ Domain Expert   │
│ errors   │  │ Review          │
└──────────┘  └────────┬────────┘
                       │
                       ▼ Pass?
                 ┌─────┴─────┐
                Fail        Pass
                 │            │
                 ▼            ▼
           ┌──────────┐  ┌─────────────────┐
           │ Revise   │  │ Language Lead   │
           │ content  │  │ Review          │
           └──────────┘  └────────┬────────┘
                                   │
                                   ▼ Pass?
                             ┌─────┴─────┐
                            Fail        Pass
                             │            │
                             ▼            ▼
                       ┌──────────┐  ┌─────────────────┐
                       │ Revise   │  │ Editor Final    │
                       │ content  │  │ Review          │
                       └──────────┘  └────────┬────────┘
                                               │
                                               ▼ Pass?
                                         ┌─────┴─────┐
                                        Fail        Pass
                                         │            │
                                         ▼            ▼
                                   ┌──────────┐  ┌─────────────────┐
                                   │ Revise   │  │ PUBLISHED        │
                                   └──────────┘  └─────────────────┘
```

### 6.4 Error Categories

| Category | Severity | Response Time |
|----------|----------|---------------|
| **Factual Error** | Critical | 24 hours |
| **Incomplete Definition** | High | 1 week |
| **Broken Link** | Medium | 2 weeks |
| **Style Issue** | Low | Next update |
| **Outdated Content** | Medium | 1 month |

---

## 7. Multi-Language Considerations

### 7.1 Translation Requirements

| Element | Translation Required | Notes |
|---------|--------------------|----|
| Term Name | Yes | Primary translation |
| Definition | Yes | Full translation |
| Examples | Yes | Context preserved |
| Common Mistakes | Yes | Context preserved |
| Cross-References | No | Keep original slugs |
| Technical Terms | Evaluate | May remain in English |

### 7.2 Language-Specific Guidelines

#### Vietnamese (vi)

```markdown
### Úp Bóng (Draw Shot)

**Định nghĩa nhanh:** Đòn đánh mà bóng cơ được đánh phía dưới tâm, 
khiến bóng quay ngược lại sau khi chạm bóng đối tượng.

**Giải thích chi tiết:** ...
```

#### Japanese (ja)

```markdown
### ドローショット (Draw Shot)

**クイック定義:** キューボールの中央より下を撞くことで、的球衝突後に
進行方向とは逆に回転しながら戻るショット。
```

### 7.3 Handling Missing Translations

When full translation is not available:

```markdown
### Draw Shot

**Name:** Draw Shot (Úp Bóng - *Vietnamese pending*)

**Definition:** [English definition only]

*[Full Vietnamese translation in progress - expected: August 2026]*
```

---

## 8. Appendix

### 8.1 Term Creation Checklist

```markdown
## New Term Submission

### Basic Information
- [ ] Unique slug generated
- [ ] All name translations provided
- [ ] Discipline assigned
- [ ] Difficulty level set

### Content
- [ ] Quick definition (1 sentence)
- [ ] Full definition (2-3 paragraphs)
- [ ] Technical details (if applicable)
- [ ] At least 2 examples
- [ ] Common mistakes (if applicable)

### Structure
- [ ] Category assigned
- [ ] Tags applied (3-5 relevant)
- [ ] Aliases identified
- [ ] Prerequisites listed
- [ ] Related terms linked

### Quality
- [ ] Spell-checked
- [ ] Grammar reviewed
- [ ] Links verified
- [ ] Format compliant

### Review
- [ ] Self-review complete
- [ ] Expert review scheduled
- [ ] Translation planned
```

### 8.2 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Database Schema](./03_Database.md)
- [BKM Category System](./06_Category_System.md)
- [BKM Tag System](./13_Tag_System.md)

---

**End of Document**
