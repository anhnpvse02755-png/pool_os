# BKM - Term Validation Rules

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document defines validation rules for all terms in the BKM Knowledge Graph. Validation ensures data quality, consistency, and completeness across the entire knowledge base.

---

## 2. Validation Levels

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VALIDATION LEVELS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │                    VALIDATION GATES                          │   │
    │   │                                                              │   │
    │   │   ┌───────────┐    ┌───────────┐    ┌───────────┐           │   │
    │   │   │   SAVE   │───►│  REVIEW  │───►│ PUBLISH  │           │   │
    │   │   │  GATE    │    │  GATE    │    │   GATE    │           │   │
    │   │   └───────────┘    └───────────┘    └───────────┘           │   │
    │   │       │                │                │                   │   │
    │   │       ▼                ▼                ▼                   │   │
    │   │   Required Only    + Warnings      + Suggestions           │   │
    │   │                                                              │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    Level 1: REQUIRED (Save Gate)
    ─────────────────────────────────
    • Minimum required fields must be valid
    • Blocks saving if failed
    • No exceptions

    Level 2: WARNINGS (Review Gate)
    ─────────────────────────────────
    • Quality checks that should pass
    • Shows warnings in review interface
    • Blocks publishing if failed

    Level 3: SUGGESTIONS (Publish Gate)
    ────────────────────────────────────
    • Best practice recommendations
    • Shown as suggestions
    • Does not block any action
```

---

## 3. Required Fields

### 3.1 Field Requirements Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         REQUIRED FIELDS MATRIX                               │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Required │ Type    │ Validation              │
    │   ──────────────────┼──────────┼─────────┼────────────────────────  │
    │                                                                      │
    │   ID                 │   YES    │ String  │ Must exist, valid format│
    │   Slug               │   YES    │ String  │ Unique, kebab-case      │
    │   English Name       │   YES    │ String  │ Min 1 char              │
    │   Vietnamese Name     │   YES    │ String  │ Min 1 char              │
    │   Category           │   YES    │ ID      │ Must exist              │
    │   Tags               │   YES    │ Array   │ At least 1 tag          │
    │                                                                      │
    │   ────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   definition_short   │   YES    │ Object  │ EN required, 50-150 chars│
    │   definition_full    │   YES    │ Object  │ EN required, 500-2000   │
    │   difficulty         │   YES    │ Enum    │ beginner|intermediate   │
    │                      │          │         │   |advanced|professional│
    │   status             │   YES    │ Enum    │ draft|review|published  │
    │                      │          │         │   |deprecated            │
    │                                                                      │
    │   ────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   aliases            │   NO     │ Object  │ Max 20 per language     │
    │   notes              │   NO     │ Object  │ Structured if present   │
    │   pronunciation      │   NO     │ Object  │ IPA format for EN       │
    │   media              │   NO     │ Array   │ Valid media IDs         │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

### 3.2 ID Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ID VALIDATION                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Format: TERM-NNNNNN
    Example: TERM-000001, TERM-000002, TERM-123456
    
    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Must start with "TERM-"
    ✓ Followed by exactly 6 digits
    ✓ Digits must be zero-padded (000001, not 1)
    ✓ Must be unique across all terms
    ✓ Cannot be reused after deletion (soft delete only)
    
    Valid IDs:
    ─────────────────────────────────────────────────────────────────────────
    • TERM-000001  ✓
    • TERM-000010  ✓
    • TERM-123456  ✓
    
    Invalid IDs:
    ─────────────────────────────────────────────────────────────────────────
    • term-000001  ✗ (lowercase)
    • TERM-1       ✗ (not 6 digits)
    • TERM-0000001 ✗ (7 digits)
    • TERM_000001  ✗ (underscore instead of dash)
    • term000001    ✗ (missing dash)
```

### 3.3 Slug Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            SLUG VALIDATION                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Format: kebab-case (lowercase with hyphens)
    Example: draw-shot, stop-shot, follow-through
    
    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Must be lowercase only (a-z, 0-9)
    ✓ Words separated by hyphens (-)
    ✓ No consecutive hyphens (--)
    ✓ No leading or trailing hyphens
    ✓ No special characters (!@#$%^&*())
    ✓ Maximum 255 characters
    ✓ Must be unique across all terms
    ✓ Cannot be reused after deletion
    
    Valid Slugs:
    ─────────────────────────────────────────────────────────────────────────
    • draw-shot              ✓
    • stop-shot              ✓
    • follow-through         ✓
    • 8-ball                 ✓ (numbers allowed)
    • jump-shot-123          ✓
    
    Invalid Slugs:
    ─────────────────────────────────────────────────────────────────────────
    • DrawShot              ✗ (camelCase)
    • draw_shot             ✗ (underscore)
    • Draw-Shot             ✗ (uppercase)
    • draw--shot            ✗ (consecutive hyphens)
    • -draw-shot            ✗ (leading hyphen)
    • draw-shot-             ✗ (trailing hyphen)
    • draw shot             ✗ (space)
```

### 3.4 Name Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           NAME VALIDATION                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   English Name (names.en)                                            │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Required: YES                                                  │
    │   • Minimum length: 1 character                                     │
    │   • Maximum length: 500 characters                                  │
    │   • Must not be empty or whitespace only                           │
    │   • Should be title case (recommended)                             │
    │   • Should not contain HTML or markdown                            │
    │   • Cannot be same as another term's name                          │
    │                                                                      │
    │   Valid Examples:                                                   │
    │   • "Draw Shot"                                                    │
    │   • "Stop Shot"                                                    │
    │   • "Bank Shot"                                                    │
    │   • "English"                                                     │
    │                                                                      │
    │   Invalid Examples:                                                │
    │   • "" (empty)                                                     │
    │   • "   " (whitespace only)                                       │
    │   • "<script>" (HTML)                                              │
    │   │                                                                  │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Vietnamese Name (names.vi)                                        │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Required: YES                                                  │
    │   • Minimum length: 1 character                                     │
    │   • Maximum length: 500 characters                                  │
    │   • Must not be empty or whitespace only                           │
    │   • Should use proper Vietnamese diacritics                        │
    │   • Should not contain HTML or markdown                            │
    │   • Can be same as English name for loanwords                       │
    │                                                                      │
    │   Valid Examples:                                                   │
    │   • "Đường Cắt Đít"                                               │
    │   • "Đường Dừng"                                                  │
    │   • "Băng Thường"                                                  │
    │   • "English" (loanword - acceptable)                               │
    │                                                                      │
    │   Invalid Examples:                                                 │
    │   • "" (empty)                                                     │
    │   • "   " (whitespace only)                                       │
    │   • "Duong Cat Dit" (missing diacritics - warning only)            │
    │   │                                                                  │
    └─────────────────────────────────────────────────────────────────────┘
```

### 3.5 Category Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CATEGORY VALIDATION                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Must reference a valid category ID
    ✓ Category must exist and be active
    ✓ Category cannot be the root "bkm" category
    ✓ Only one primary category allowed per term
    ✓ Secondary categories can be added via junction table
    
    Valid Category References:
    ─────────────────────────────────────────────────────────────────────────
    • CAT-000001 (Fundamentals)
    • CAT-000010 (Pool Shots)
    • CAT-000020 (Basic Shots)
    • CAT-000030 (Safety Play)
    
    Invalid Category References:
    ─────────────────────────────────────────────────────────────────────────
    • CAT-000000 (Root category - not allowed)
    • CAT-INVALID (Non-existent)
    • null / "" (empty)
    • "random-id" (wrong format)
```

### 3.6 Tag Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TAG VALIDATION                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Minimum: 1 tag per term (required)
    ✓ Maximum: 10 tags per term
    ✓ Each tag must exist in the tag vocabulary
    ✓ Tags must be lowercase
    ✓ Tags cannot contain spaces (use hyphens)
    ✓ Duplicate tags are not allowed
    
    Valid Tag Array:
    ─────────────────────────────────────────────────────────────────────────
    {
      "tags": [
        "fundamentals",      ✓ lowercase
        "stance",            ✓
        "beginner-friendly", ✓ hyphen allowed
        "must-know"          ✓
      ]
    }
    
    Invalid Tag Array:
    ─────────────────────────────────────────────────────────────────────────
    {
      "tags": [
        "",                  ✗ empty not allowed
        "Stance",            ✗ uppercase
        "beginner friendly", ✗ space not allowed
        "fundamentals",      ✗ duplicate
        "fundamentals"       ✗ duplicate
      ]
    }
    
    Common Tags:
    ─────────────────────────────────────────────────────────────────────────
    • technique
    • fundamentals
    • advanced
    • beginner-friendly
    • equipment
    • rules
    • safety
    • strategy
    • mental-game
    • physics
```

---

## 4. Definition Validation

### 4.1 Short Definition

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SHORT DEFINITION VALIDATION                            │
└─────────────────────────────────────────────────────────────────────────────┘

    Field: definition_short
    Type: JSONB (multilingual object)
    
    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ English (en) is required
    ✓ Vietnamese (vi) is required
    ✓ Each language value: 50-150 characters
    ✓ Must not be empty or whitespace only
    ✓ Must not exceed character limit
    
    Valid Example:
    ─────────────────────────────────────────────────────────────────────────
    {
      "en": "A shot using backspin to bring the cue ball back after contact",
      "vi": "Đòn đánh tạo lực ngược khiến bóng cơ quay về sau khi chạm"
    }
    // EN: 78 chars ✓
    // VI: 85 chars ✓
    
    Invalid Examples:
    ─────────────────────────────────────────────────────────────────────────
    // Empty English
    { "en": "", "vi": "Một số ví dụ" }                    ✗
    
    // Too short
    { "en": "Draw shot", "vi": "Đường cắt đít" }          ✗ (too short)
    
    // Too long (>150 chars)
    { 
      "en": "A shot using backspin to bring the cue ball back towards the player after it contacts the object ball with a precise downward strike on the cue ball",
      "vi": "Đường cắt đít" 
    }                                                        ✗ (too long)
```

### 4.2 Full Definition

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FULL DEFINITION VALIDATION                            │
└─────────────────────────────────────────────────────────────────────────────┘

    Field: definition_full
    Type: JSONB (multilingual object)
    
    Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ English (en) is required
    ✓ Vietnamese (vi) is required
    ✓ Each language value: 500-2000 characters
    ✓ Must include: what, how, when/where
    ✓ Supports markdown formatting
    ✓ Must be more detailed than short definition
    
    Valid Example:
    ─────────────────────────────────────────────────────────────────────────
    {
      "en": "## Draw Shot\n\nA **draw shot** (also called a screw shot or pull shot) is executed by striking the cue ball below center with a forward-follow-through motion.\n\n### How to Execute\n1. Position your tip below center\n2. Accelerate through the ball\n3. Follow through toward the table\n\n### When to Use\nUse draw shot when you need to control cue ball position behind the object ball. Essential for position play.",
      "vi": "## Đường Cắt Đít\n\n**Đường cắt đít** (còn gọi là screw shot hoặc pull shot) được thực hiện bằng cách đánh vào phần dưới tâm bóng cơ với chuyển động đẩy về phía trước.\n\n### Cách Thực Hiện\n1. Đặt đầu cơ dưới tâm bóng\n2. Tăng tốc xuyên qua bóng\n3. Theo đuổi hướng về phía bàn\n\n### Khi Nào Sử Dụng\nSử dụng đường cắt đít khi cần kiểm soát vị trí bóng cơ phía sau bóng mục tiêu."
    }
    // EN: 620 chars ✓
    // VI: 650 chars ✓
    
    Invalid Examples:
    ─────────────────────────────────────────────────────────────────────────
    // Too short (<500 chars)
    { 
      "en": "A draw shot uses backspin to bring the cue ball back.",
      "vi": "Đường cắt đít dùng lực ngược."
    }                                                        ✗
    
    // Missing section
    { 
      "en": "Draw shot. Strike below center. Use backspin.",
      "vi": "Cắt đít. Đánh dưới tâm. Dùng lực ngược."
    }                                                        ✗ (too short + missing structure)
```

---

## 5. Status Validation

### 5.1 Status Values

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STATUS VALIDATION                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Valid Status Values:
    ─────────────────────────────────────────────────────────────────────────
    ┌─────────────┬────────────────────────────────────────────────────────┐
    │   Status    │                        Rules                          │
    ├─────────────┼────────────────────────────────────────────────────────┤
    │   draft     │ • Initial status for new terms                        │
    │             │ • Visible only to editors                             │
    │             │ • Can be edited freely                               │
    ├─────────────┼────────────────────────────────────────────────────────┤
    │   review    │ • Submitted for review                               │
    │             │ • Visible to reviewers                               │
    │             │ • Requires at least 1 reviewer approval               │
    ├─────────────┼────────────────────────────────────────────────────────┤
    │   published │ • Live and visible to all users                       │
    │             │ • Requires: all validations passed                    │
    │             │ • Requires: all required fields complete             │
    │             │ • Edit requires status change to draft              │
    ├─────────────┼────────────────────────────────────────────────────────┤
    │ deprecated  │ • Hidden from users                                  │
    │             │ • Cannot be assigned to new terms                    │
    │             │ • Preserved for historical reference                 │
    └─────────────┴────────────────────────────────────────────────────────┘
    
    Status Transition Rules:
    ─────────────────────────────────────────────────────────────────────────
    
        draft ──────► review ──────► published
           ▲            │               │
           │            ▼               │
           └─────── (rejected)          │
                                        ▼
                                   deprecated
    
    Valid Transitions:
    ─────────────────────────────────────────────────────────────────────────
    • draft → review (submit for review)
    • review → draft (request changes)
    • review → published (approve)
    • published → draft (request edit)
    • published → deprecated (archive)
    • draft → draft (save draft)
```

---

## 6. Difficulty Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DIFFICULTY VALIDATION                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Valid Difficulty Values:
    ─────────────────────────────────────────────────────────────────────────
    ┌───────────────┬────────────────────────────────────────────────────────┐
    │  Difficulty   │                        Description                    │
    ├───────────────┼────────────────────────────────────────────────────────┤
    │  beginner     │ Fundamental concepts, basic techniques               │
    │               │ No prerequisites required                             │
    ├───────────────┼────────────────────────────────────────────────────────┤
    │  intermediate │ Advanced fundamentals, common techniques             │
    │               │ Requires basic understanding                          │
    ├───────────────┼────────────────────────────────────────────────────────┤
    │  advanced     │ Complex techniques, strategic concepts               │
    │               │ Requires solid foundation                             │
    ├───────────────┼────────────────────────────────────────────────────────┤
    │  professional │ Expert-level, tournament strategies                  │
    │               │ Requires extensive experience                         │
    └───────────────┴────────────────────────────────────────────────────────┘
    
    Difficulty-Content Consistency:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Beginner content: Basic terminology, stance, grip, simple shots
    ✓ Intermediate: Common techniques, position play, basic safety
    ✓ Advanced: Complex banks, english, advanced strategy
    ✓ Professional: Tournament tactics, pro-level techniques
    
    Category-Difficulty Mapping (Recommended):
    ─────────────────────────────────────────────────────────────────────────
    • fundamentals.* → beginner, intermediate
    • pool-shots.basic-* → beginner, intermediate
    • pool-shots.spin-* → intermediate, advanced
    • pool-shots.advanced-* → advanced, professional
    • competition.* → advanced, professional
```

---

## 7. Quality Validation (Warnings)

### 7.1 Content Quality Checks

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CONTENT QUALITY VALIDATION                              │
└─────────────────────────────────────────────────────────────────────────────┘

    These checks generate WARNINGS but do not block saving.
    
    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Alias Check                                                       │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Should have at least 1 alias (warning if none)                  │
    │   • Maximum 20 aliases per language                                 │
    │   • Aliases should be unique across term                           │
    │                                                                      │
    │   Example Warning:                                                  │
    │   "Consider adding aliases for better searchability"                │
    │                                                                      │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Pronunciation Check                                               │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • English terms should have IPA pronunciation                     │
    │   • Vietnamese terms should have phonetic guide                     │
    │                                                                      │
    │   Example Warning:                                                   │
    │   "IPA pronunciation missing for English name"                      │
    │                                                                      │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Notes Check                                                       │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Should include 'when_to_use' guidance                          │
    │   • Should include 'common_mistakes' if applicable                  │
    │   • Should include 'professional_tips' for advanced terms           │
    │                                                                      │
    │   Example Warning:                                                   │
    │   "'when_to_use' guidance missing in notes"                         │
    │                                                                      │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Definition Length Check                                            │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Short definition should be within 50-150 char range            │
    │   • Full definition should be 500-2000 chars                       │
    │                                                                      │
    │   Example Warning:                                                   │
    │   "Full definition is 480 chars (recommended: 500-2000)"           │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Completeness Checks

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COMPLETENESS VALIDATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Cross-Reference Check                                              │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Terms should have at least 2 related terms                      │
    │   • Recommended Next should exist for learnable concepts            │
    │   • Related terms should have weight > 0.5                         │
    │                                                                      │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Category Consistency                                               │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Term difficulty should match category expectations             │
    │   • Tags should be relevant to category                             │
    │                                                                      │
    │   ─────────────────────────────────────────────────────────────────  │
    │                                                                      │
    │   Media Check                                                        │
    │   ─────────────────────────────────────────────────────────────────  │
    │   • Advanced/Professional terms should have demo images            │
    │   • Technique terms should have demonstration video (suggested)   │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Validation Error Messages

### 8.1 Error Message Format

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ERROR MESSAGE FORMAT                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    {
      "field": "names.en",
      "code": "REQUIRED_FIELD_MISSING",
      "message": "English name is required",
      "severity": "error",
      "value": null
    }
    
    {
      "field": "tags",
      "code": "MINIMUM_NOT_MET",
      "message": "At least 1 tag is required",
      "severity": "error",
      "value": []
    }
```

### 8.2 Error Codes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ERROR CODES                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    REQUIRED ERRORS (Block Save):
    ─────────────────────────────────────────────────────────────────────────
    • REQUIRED_FIELD_MISSING     - A required field is empty or null
    • INVALID_FORMAT             - Value format is incorrect
    • INVALID_ENUM_VALUE         - Value not in allowed enum list
    • REFERENCE_NOT_FOUND        - Referenced entity does not exist
    • DUPLICATE_VALUE            - Value already exists (unique constraint)
    • MINIMUM_NOT_MET            - Array or string below minimum
    • MAXIMUM_EXCEEDED           - Array or string above maximum
    • INVALID_CHARACTERS         - Contains disallowed characters
    
    WARNING ERRORS (Block Publish):
    ─────────────────────────────────────────────────────────────────────────
    • RECOMMENDED_FIELD_MISSING  - Recommended field is empty
    • LOW_QUALITY_CONTENT        - Content below quality threshold
    • INCONSISTENT_DATA          - Related fields do not match
    • MISSING_CROSS_REFERENCE    - No related terms defined
    
    SUGGESTION CODES (No Block):
    ─────────────────────────────────────────────────────────────────────────
    • ADD_ALIAS                 - Consider adding an alias
    • ADD_PRONUNCIATION         - Consider adding pronunciation
    • ADD_NOTES                 - Consider adding guidance notes
    • ADD_MEDIA                 - Consider adding images/video
    • CONSIDER_SPLITTING        - Term may be too broad
    • CONSIDER_MERGING          - Multiple terms may overlap
```

---

## 9. Validation Implementation

### 9.1 Validation Functions

```dart
// Validation Result
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final List<ValidationWarning> warnings;
  final List<ValidationSuggestion> suggestions;
}

// Validation Error
class ValidationError {
  final String field;
  final String code;
  final String message;
  final dynamic value;
}

// Validate Term
ValidationResult validateTerm(Term term) {
  final errors = <ValidationError>[];
  final warnings = <ValidationWarning>[];
  final suggestions = <ValidationSuggestion>[];

  // Required Field Validations
  errors.addAll(validateRequiredFields(term));
  
  // Format Validations
  errors.addAll(validateFormats(term));
  
  // Reference Validations
  errors.addAll(validateReferences(term));
  
  // Quality Validations (Warnings)
  warnings.addAll(validateQuality(term));
  
  // Completeness Validations (Suggestions)
  suggestions.addAll(validateCompleteness(term));

  return ValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
    suggestions: suggestions,
  );
}
```

### 9.2 Validation Rules Engine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VALIDATION FLOW                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │                        USER INPUTS TERM                              │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Pre-processing    │                           │
    │                    │  • Trim whitespace │                           │
    │                    │  • Normalize case  │                           │
    │                    │  • Parse JSON      │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Required Field     │                           │
    │                    │  Validation         │                           │
    │                    │  (LEVEL 1)          │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                    ┌─────────────────────┐                           │
    │                    │     PASS?           │                           │
    │                    │                     │                           │
    │                    │   YES ─────► CONTINUE                           │
    │                    │                     │                           │
    │                    │   NO  ─────► RETURN ERRORS                      │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Format Validation   │                           │
    │                    │  (LEVEL 1)          │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Reference Check    │                           │
    │                    │  (LEVEL 1)          │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Quality Check      │                           │
    │                    │  (LEVEL 2)          │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  Completeness       │                           │
    │                    │  Check (LEVEL 3)    │                           │
    │                    └─────────────────────┘                           │
    │                              │                                       │
    │                              ▼                                       │
    │                    ┌─────────────────────┐                           │
    │                    │  VALIDATION RESULT  │                           │
    │                    │  + ERRORS/WARNINGS  │                           │
    │                    │  + SUGGESTIONS      │                           │
    │                    └─────────────────────┘                           │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 10. Validation API

### 10.1 Endpoint

```
POST /v1/terms/validate
Content-Type: application/json

{
  "term": { ... term object ... },
  "level": "all"  // "required" | "all" | "publish"
}
```

### 10.2 Response

```json
{
  "isValid": false,
  "canSave": true,
  "canPublish": false,
  "results": {
    "errors": [
      {
        "field": "names.en",
        "code": "REQUIRED_FIELD_MISSING",
        "message": "English name is required"
      }
    ],
    "warnings": [
      {
        "field": "aliases",
        "code": "RECOMMENDED_FIELD_MISSING",
        "message": "Consider adding at least one alias"
      }
    ],
    "suggestions": [
      {
        "field": "media",
        "code": "ADD_MEDIA",
        "message": "Consider adding a demonstration image"
      }
    ]
  }
}
```

---

## 11. Related Documents

- [Term Schema](./term_schema.md)
- [Category Tree](./category_tree.md)
- [Tag System](./tag_schema.md)
- [Content Workflow](./12_Content_Workflow.md)

---

## 12. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial validation rules |

---

**Standard Owner:** Content Team
**Next Review:** Quarterly
