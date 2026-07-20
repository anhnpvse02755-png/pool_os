# BKM - Naming Convention Standard

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document defines the naming conventions for all files, folders, and assets within the BKM Knowledge Graph. Consistent naming ensures:

- **Discoverability** - Easy to locate resources
- **Consistency** - Predictable patterns across the system
- **SEO** - Human-readable URLs and file paths
- **Cross-Platform** - Compatible with all operating systems

---

## 2. Case Styles Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CASE STYLES                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────┬────────────────────────────────┬─────────────────┐
    │ STYLE               │ EXAMPLE                         │ USE CASE        │
    ├─────────────────────┼────────────────────────────────┼─────────────────┤
    │ kebab-case          │ draw-shot                       │ File names      │
    │ snake_case          │ draw_shot                       │ Database fields │
    │ PascalCase          │ DrawShot                        │ Class names     │
    │ camelCase           │ drawShot                        │ Variable names  │
    │ SCREAMING_SNAKE     │ DRAW_SHOT                      │ Constants       │
    │ lowercase           │ drawshot                        │ URLs, slugs     │
    │ Title Case          │ Draw Shot                       │ Headings        │
    └─────────────────────┴────────────────────────────────┴─────────────────┘
```

---

## 3. File Naming Conventions

### 3.1 Format Specification

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FILE NAME STRUCTURE                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    {slug}.{extension}

    │       └── dot + lowercase extension
    │
    └── lowercase letters, numbers, hyphens only
```

### 3.2 Rules Summary

| Rule | Description | Example |
|------|-------------|---------|
| **Lowercase** | All lowercase letters | `draw-shot.md` |
| **Hyphens** | Use hyphens between words | `follow-shot.md` |
| **No spaces** | Never use spaces | ✗ `draw shot.md` |
| **No underscores** | Never use underscores | ✗ `draw_shot.md` |
| **No special chars** | Only a-z, 0-9, hyphens | ✗ `draw-shot_v2.md` |
| **No consecutive hyphens** | Max one hyphen at a time | ✗ `draw--shot.md` |
| **No leading/trailing hyphens** | Clean start and end | ✗ `-draw-shot.md` |

### 3.3 Extension Rules

| File Type | Extension | Example |
|-----------|-----------|---------|
| Markdown | `.md` | `draw-shot.md` |
| JSON | `.json` | `draw-shot.json` |
| Image (lossy) | `.webp` / `.jpg` | `draw-shot.webp` |
| Image (lossless) | `.png` | `draw-shot-diagram.png` |
| Animation | `.gif` | `draw-shot-demo.gif` |
| Video | `.mp4` | `draw-shot-tutorial.mp4` |
| Audio | `.mp3` | `draw-shot-tip.mp3` |
| SVG | `.svg` | `draw-shot-diagram.svg` |

---

## 4. Entity Type Naming

### 4.1 Terms

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TERM NAMING                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Rule: Use the canonical term name in kebab-case
    Source: English primary name (convert to lowercase, hyphenate)
    
    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ English Name                           │ File Name                      │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Draw Shot                              │ draw-shot.md                   │
    │ Follow Shot                            │ follow-shot.md                 │
    │ Cut Shot                               │ cut-shot.md                    │
    │ Jump Shot                              │ jump-shot.md                   │
    │ English (Side Spin)                    │ english-side-spin.md           │
    │ Massé                                  │ masse.md                       │
    │ 3-Cushion Billiards                   │ three-cushion-billiards.md     │
    │ Safety Play                            │ safety-play.md                 │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

### 4.2 Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CATEGORY NAMING                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Rule: Use category name in kebab-case
    Source: English category name
    
    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Category Name                           │ Folder Name                   │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Pool Shots                              │ pool-shots/                   │
    │ Fundamentals                            │ fundamentals/                 │
    │ Advanced Techniques                     │ advanced-techniques/          │
    │ Safety Play                             │ safety-play/                  │
    │ Equipment                                │ equipment/                    │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

### 4.3 Tags

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TAG NAMING                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Rule: Use tag name in kebab-case
    Source: English tag name
    
    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Tag Name                                │ Tag Slug                       │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Beginner                                │ beginner                       │
    │ Intermediate                            │ intermediate                   │
    │ Advanced                                │ advanced                       │
    │ Pro Level                               │ pro-level                      │
    │ Competition                             │ competition                    │
    │ Drill                                   │ drill                          │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

### 4.4 Media Assets

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            MEDIA NAMING                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Pattern: {term-slug}-{role}-{variant}.{extension}
    
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Component          │ Description        │ Example                      │
    ├─────────────────────┼────────────────────┼──────────────────────────────┤
    │ term-slug           │ Term identifier    │ draw-shot                    │
    │ role                │ Media purpose      │ hero, thumb, diagram, demo   │
    │ variant             │ Optional variant   │ v1, v2, alt, dark, light     │
    │ extension           │ File type          │ webp, mp4, svg               │
    └─────────────────────┴────────────────────┴──────────────────────────────┘

    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Description                             │ File Name                     │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Draw shot hero image                    │ draw-shot-hero.webp           │
    │ Draw shot thumbnail                     │ draw-shot-thumb.webp           │
    │ Draw shot diagram                       │ draw-shot-diagram.svg         │
    │ Draw shot tutorial video                │ draw-shot-tutorial.mp4        │
    │ Draw shot demo animation                │ draw-shot-demo.mp4            │
    │ Draw shot position v1                   │ draw-shot-position-v1.webp   │
    │ Draw shot position v2                   │ draw-shot-position-v2.webp   │
    │ Draw shot diagram alternate             │ draw-shot-diagram-alt.svg     │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

---

## 5. Folder Naming Conventions

### 5.1 Directory Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FOLDER NAMING RULES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Rule: Same as file naming - kebab-case, lowercase, hyphens
    
    ✓ CORRECT
    ├── content/
    │   ├── pool-shots/
    │   ├── fundamentals/
    │   └── safety-play/
    ├── media/
    │   ├── images/
    │   └── videos/
    
    ✗ INCORRECT
    ├── Content/          (Title Case)
    ├── pool_shots/       (snake_case)
    ├── pool shots/       (spaces)
    ├── Pool_Shots/       (Pascal + underscore)
```

### 5.2 Folder Hierarchy

```
content/
├── {category-slug}/
│   ├── index.json
│   ├── {term-slug}.md
│   ├── {term-slug}.json
│   └── media/
│       ├── {term-slug}-{role}.webp
│       └── {term-slug}-{role}.mp4
├── _categories/
│   └── {category-slug}.json
└── _shared/
    └── {shared-asset}.{ext}
```

---

## 6. URL Slug Conventions

### 6.1 URL Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             URL SLUGS                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    Base URL: https://bkm.app/terms/{slug}
    
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Term Name                               │ URL Slug                      │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Draw Shot                               │ /terms/draw-shot              │
    │ Follow Shot                             │ /terms/follow-shot            │
    │ 3-Cushion Billiards                     │ /terms/three-cushion-billiards│
    │ Massé                                   │ /terms/masse                  │
    │ Safety Play                             │ /terms/safety-play            │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

### 6.2 Slug Generation Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SLUG GENERATION                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    1. Convert to lowercase
    2. Remove special characters
    3. Replace spaces with hyphens
    4. Remove consecutive hyphens
    5. Trim leading/trailing hyphens
    6. Limit to 60 characters if needed
    
    Algorithm:
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │  input: "Draw Shot (Billiards)"                                        │
    │                                                                         │
    │  Step 1: lowercase     → "draw shot (billiards)"                      │
    │  Step 2: remove special → "draw shot billiards"                        │
    │  Step 3: spaces→hyphens → "draw-shot-billiards"                        │
    │  Step 4: no consecutive  → "draw-shot-billiards"                      │
    │  Step 5: trim hyphens    → "draw-shot-billiards"                       │
    │  Step 6: length check    → "draw-shot-billiards" (OK)                  │
    │                                                                         │
    │  output: "draw-shot-billiards"                                          │
    └─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Code Naming Conventions

### 7.1 TypeScript / JavaScript

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CODE NAMING (JS/TS)                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Type                │ Style     │ Example                             │
    ├─────────────────────┼───────────┼─────────────────────────────────────┤
    │ Class               │ PascalCase│ class DrawShotService              │
    │ Interface           │ PascalCase│ interface ShotDefinition            │
    │ Type                │ PascalCase│ type ShotType = 'draw' | 'follow'  │
    │ Enum                │ PascalCase│ enum ShotDifficulty                │
    │ Function            │ camelCase │ function calculateAngle()          │
    │ Variable            │ camelCase │ let isBeginner = true              │
    │ Constant            │ SCREAMING │ const MAX_ATTEMPTS = 3            │
    │ Private property    │ _camelCase│ private _cache: Map                │
    │ React Component     │ PascalCase│ const DrawShotCard: React.FC       │
    │ React Hook          │ camelCase │ function useDrawShot()            │
    │ File (component)    │ PascalCase│ DrawShotCard.tsx                  │
    │ File (utility)      │ kebab-case│ draw-shot-utils.ts                 │
    │ File (type)          │ kebab-case│ shot-types.ts                      │
    └─────────────────────┴───────────┴─────────────────────────────────────┘
```

### 7.2 Database

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       DATABASE NAMING (SQL)                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Type                │ Style     │ Example                             │
    ├─────────────────────┼───────────┼─────────────────────────────────────┤
    │ Table               │ snake_case│ terms, pool_shots                  │
    │ Column              │ snake_case│ term_name, created_at               │
    │ Primary Key         │ snake_case│ term_id, category_id               │
    │ Foreign Key         │ snake_case│ term_id, category_id               │
    │ Index               │ snake_case│ idx_terms_slug                     │
    │ Constraint          │ snake_case│ uk_terms_slug                      │
    │ Trigger             │ snake_case│ trg_update_timestamp               │
    │ Function            │ snake_case│ allocate_id()                      │
    │ View                │ snake_case│ v_active_terms                    │
    └─────────────────────┴───────────┴─────────────────────────────────────┘
```

### 7.3 JSON Fields

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           JSON NAMING                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Rule: camelCase for all JSON keys
    
    ✓ CORRECT
    {
      "termId": "TERM-000001",
      "termName": "Draw Shot",
      "createdAt": "2026-07-17T00:00:00Z",
      "relatedTerms": []
    }
    
    ✗ INCORRECT
    {
      "term_id": "TERM-000001",           // snake_case
      "TermName": "Draw Shot",            // PascalCase
      "term-name": "Draw Shot",           // kebab-case
      "TERMID": "TERM-000001"            // SCREAMING
    }
```

---

## 8. Special Naming Rules

### 8.1 Multi-Language Content

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       MULTI-LANGUAGE NAMING                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    For localized content, use language suffix:
    
    Pattern: {slug}-{language}.{ext}
    
    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Content                                 │ File Name                     │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Draw Shot (English)                     │ draw-shot-en.md               │
    │ Draw Shot (Vietnamese)                  │ draw-shot-vi.md               │
    │ Draw Shot JSON (English)                │ draw-shot-en.json             │
    │ Draw Shot JSON (Vietnamese)             │ draw-shot-vi.json             │
    └─────────────────────────────────────────┴───────────────────────────────┘
    
    Language Codes:
    ┌─────────────────────────────────────────┐
    │ en - English                            │
    │ vi - Vietnamese                         │
    │ zh - Chinese                            │
    │ ja - Japanese                          │
    └─────────────────────────────────────────┘
```

### 8.2 Versioning

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            VERSIONING                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Pattern: {slug}-v{number}.{ext}
    
    Examples:
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Content                                 │ File Name                     │
    ├─────────────────────────────────────────┼───────────────────────────────┤
    │ Term definition v1                      │ draw-shot-v1.md               │
    │ Term definition v2                      │ draw-shot-v2.md               │
    │ Term definition v3                      │ draw-shot-v3.md               │
    │ Media asset v1                          │ draw-shot-hero-v1.webp       │
    │ Media asset v2                          │ draw-shot-hero-v2.webp       │
    └─────────────────────────────────────────┴───────────────────────────────┘
```

### 8.3 Variants

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             VARIANTS                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    Pattern: {slug}-{variant}.{ext}
    
    ┌─────────────────────────────────────────┬───────────────────────────────┐
    │ Variant Type        │ Suffix            │ Example                       │
    ├─────────────────────┼───────────────────┼───────────────────────────────┤
    │ Dark mode           │ dark              │ draw-shot-diagram-dark.svg    │
    │ Light mode          │ light             │ draw-shot-diagram-light.svg   │
    │ Simplified          │ simple            │ draw-shot-simple.svg          │
    │ Detailed            │ detailed          │ draw-shot-detailed.svg        │
    │ Thumbnail           │ thumb             │ draw-shot-thumb.webp          │
    │ High resolution     │ hd                │ draw-shot-hero-hd.webp        │
    └─────────────────────┴───────────────────┴───────────────────────────────┘
```

---

## 9. Forbidden Patterns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FORBIDDEN PATTERNS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    ✗ NO SPACES
    draw shot.md              → draw-shot.md
    
    ✗ NO UNDERSCORES IN FILENAMES
    draw_shot.md              → draw-shot.md
    
    ✗ NO UPPERCASE
    Draw-Shot.md              → draw-shot.md
    
    ✗ NO SPECIAL CHARACTERS
    draw-shot_v2.md           → draw-shot-v2.md
    draw-shot(v1).md          → draw-shot-v1.md
    draw&shot.md              → draw-and-shot.md
    
    ✗ NO CONSECUTIVE HYPHENS
    draw--shot.md             → draw-shot.md
    
    ✗ NO LEADING/TRAILING HYPHENS
    -draw-shot.md             → draw-shot.md
    draw-shot-.md             → draw-shot.md
    
    ✗ NO NUMERIC ONLY NAMES
    12345.md                  → term-12345.md
```

---

## 10. Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      NAMING QUICK REFERENCE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    FILE NAMES     → kebab-case:    draw-shot.md
    FOLDER NAMES   → kebab-case:    pool-shots/
    URL SLUGS      → kebab-case:    /terms/draw-shot
    DATABASE       → snake_case:    term_name, term_id
    JSON KEYS      → camelCase:     termName, termId
    CLASS NAMES    → PascalCase:    class DrawShotService
    CONSTANTS      → SCREAMING:     MAX_ATTEMPTS
    GIT BRANCHES   → kebab-case:    feature/draw-shot-tutorial
    COMMIT MSGS    → imperative:    Add draw shot documentation
    
    CHARACTERS     → lowercase a-z, 0-9, hyphens only
    SEPARATOR      → hyphens (-) for files/URLs, underscores (_) for DB
    LANGUAGE       → lowercase ISO codes: -en, -vi, -zh
    VERSION        → lowercase v prefix: -v1, -v2
```

---

## 11. Related Documents

- [ID Standard](./id_standard.md)
- [Term Schema](./term_schema.md)
- [Database Schema](./03_Database.md)

---

## 12. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial standard |

---

**Standard Owner:** Architecture Team
**Review Cycle:** Annual
