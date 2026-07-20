# BKM - Terminology Consistency Rules

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document establishes rules for maintaining terminology consistency across the entire BKM Knowledge Base. Consistent terminology ensures clarity, prevents confusion, and enables effective knowledge management.

---

## 2. Core Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CORE PRINCIPLES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   1. ONE CONCEPT = ONE TERM                                          │
    │      Each concept must have exactly one canonical name               │
    │                                                                      │
    │   2. ONE TRANSLATION = ONE MEANING                                   │
    │      Each translation must map to exactly one concept                 │
    │                                                                      │
    │   3. PREFERRED TERM = CANONICAL                                       │
    │      All content must use the preferred/canonical term               │
    │                                                                      │
    │   4. ALIASES ARE SECONDARY                                           │
    │      Alternative names are documented, not used in content           │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Term Selection Rules

### 3.1 Preferred Term Selection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TERM SELECTION HIERARCHY                             │
└─────────────────────────────────────────────────────────────────────────────┘

    When selecting the preferred term for a concept, apply this priority:

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Priority │ Source                  │ Example                        │
    │   ────────┼────────────────────────┼─────────────────────────────── │
    │                                                                      │
    │   1st      │ International standard │ WPA/BCA terminology            │
    │   2nd      │ English native usage  │ "cue ball" vs "white ball"     │
    │   3rd      │ Vietnamese common use │ Established loanwords           │
    │   4th      │ Technical accuracy    │ Most precise definition         │
    │   5th      │ Simplicity           │ Shortest clear term             │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    Rule Examples:
    ─────────────────────────────────────────────────────────────────────────

    ✓ CORRECT (International Standard)
    "cue ball" over "white ball" or "cueball"

    ✓ CORRECT (English Native Usage)
    "draw shot" over "screw shot" or "pull shot" as primary term
    (All alternatives documented as aliases)

    ✓ CORRECT (Vietnamese Established)
    "break" remains as "break (đánh phá)" because it's established

    ✓ CORRECT (Technical Accuracy)
    "below center" over "down on the ball" (more precise)

    ✓ CORRECT (Simplicity)
    "english" over "side spin application technique"
```

### 3.2 Term Rejection Criteria

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TERM REJECTION CRITERIA                             │
└─────────────────────────────────────────────────────────────────────────────┘

    Reject a term if it:

    ─────────────────────────────────────────────────────────────────────────

    ✗ Is Regionally Ambiguous
    ─────────────────────────────────────────────────────────────────────────
    "ball" could mean cue ball, object ball, or 8-ball
    → Use: "cue ball", "object ball", "8-ball"

    ✗ Has Multiple Common Meanings
    ─────────────────────────────────────────────────────────────────────────
    "bridge" could mean hand bridge or score bridge
    → Use: "hand bridge" or "score bridge"

    ✗ Is Obscure or Unfamiliar
    ─────────────────────────────────────────────────────────────────────────
    "screw" for backspin (UK term not commonly known)
    → Use: "draw" as primary, "screw" as alias

    ✗ Contradicts Standard Usage
    ─────────────────────────────────────────────────────────────────────────
    "pocket" for object ball pocket vs sponsor pocket
    → Use: "pocket (object ball pocket)" contextually

    ✗ Is Informal Without Benefit
    ─────────────────────────────────────────────────────────────────────────
    "nuking" the ball for power shots
    → Use: "power shot" or "forceful shot"
```

---

## 4. One Concept = One Term Rules

### 4.1 The Canonical Term

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CANONICAL TERM RULES                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Definition:
    ─────────────────────────────────────────────────────────────────────────
    The canonical term is the ONE official term for a concept used 
    throughout all BKM content.

    Rules:
    ─────────────────────────────────────────────────────────────────────────

    4.1.1  SINGLE SOURCE OF TRUTH
    ─────────────────────────────────────────────────────────────────────────
    Every concept MUST have exactly one canonical term.

    Rule: Create a concept once, use its term everywhere.

    ✓ CORRECT
    "Draw shot is the technique of applying backspin..."
    (Always uses "draw shot" for this concept)

    ✗ INCORRECT
    "Draw shot is the technique of applying backspin..."
    "The pull shot uses backspin to reverse direction..."
    (Two terms for same concept)

    ─────────────────────────────────────────────────────────────────────────

    4.1.2  UNIVERSAL APPLICATION
    ─────────────────────────────────────────────────────────────────────────
    The canonical term MUST be used in ALL content types.

    Rule: Content writers cannot choose alternative terms.

    ✓ CORRECT
    All content: "draw shot"
    Quick summary: "A shot using backspin to reverse cue ball direction"
    Full definition: "The draw shot applies backspin..."

    ✗ INCORRECT
    Article A: "draw shot"
    Article B: "screw shot"
    Article C: "backspin shot"

    ─────────────────────────────────────────────────────────────────────────

    4.1.3  NO TERM SUBSTITUTION
    ─────────────────────────────────────────────────────────────────────────
    Even if synonyms are valid, use the canonical term.

    Rule: Never substitute a synonym for the canonical term.

    ✓ CORRECT
    "The draw shot reverses cue ball direction"

    ✗ INCORRECT (even if technically correct)
    "The screw shot reverses cue ball direction"
    "The pull shot reverses cue ball direction"
```

### 4.2 Alias Management

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ALIAS MANAGEMENT                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Alias Definition:
    ─────────────────────────────────────────────────────────────────────────
    An alias is an alternative name for a concept that is documented 
    but NOT used as the primary term in content.

    ─────────────────────────────────────────────────────────────────────────

    ALIAS DOCUMENTATION

    Document aliases in the term's metadata:

    ```json
    {
      "term_id": "draw_shot",
      "canonical_term": "draw shot",
      "aliases": [
        "screw shot",
        "pull shot",
        "backspin shot"
      ],
      "usage": "Use canonical 'draw shot' in all content"
    }
    ```

    ─────────────────────────────────────────────────────────────────────────

    ALIAS USAGE RULES

    When aliases MAY be used:
    ─────────────────────────────────────────────────────────────────────────
    • In the "Also Known As" section of definitions
    • When explaining to beginners who may know alternative terms
    • In search optimization (keywords)
    • NEVER in main content

    When aliases MUST NOT be used:
    ─────────────────────────────────────────────────────────────────────────
    • In article titles
    • In quick summaries
    • In short definitions
    • In main body text
    • In headings (except "Also Known As")

    ─────────────────────────────────────────────────────────────────────────

    ALIAS VISIBILITY

    Allowed Alias Display:

    ✓ In "Also Known As" section:
    "Draw shot (also called screw shot or pull shot)"

    ✓ In cross-reference footnotes:
    "Related: Screw Shot (see Draw Shot)"

    ✗ NOT in main content:
    "The screw shot is executed by..."
```

---

## 5. Translation Consistency Rules

### 5.1 One Translation = One Concept

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      TRANSLATION UNIQUENESS RULE                              │
└─────────────────────────────────────────────────────────────────────────────┘

    Core Rule:
    ─────────────────────────────────────────────────────────────────────────
    Each Vietnamese translation MUST map to exactly ONE English concept.

    ─────────────────────────────────────────────────────────────────────────

    5.1.1  NO SHARED TRANSLATIONS

    ✗ INCORRECT
    "draw shot" → "đường cắt đít"
    "cut shot" → "đường cắt đít"    ← DUPLICATE!

    ✓ CORRECT
    "draw shot" → "đường cắt đít"
    "cut shot" → "đường cắt ngang"

    ─────────────────────────────────────────────────────────────────────────

    5.1.2  TRANSLATION UNIQUENESS CHECKLIST

    Before assigning a translation:

    □ Is this exact Vietnamese term already used for another concept?
    □ Does another English concept map to this Vietnamese term?
    □ Can a more specific translation differentiate the concepts?

    ─────────────────────────────────────────────────────────────────────────

    RESOLUTION STRATEGIES

    When translations conflict:

    Strategy 1: More Specific Translation
    ─────────────────────────────────────────────────────────────────────────
    English: "english", "side spin"
    Problem: Both might map to "kỹ thuật xoáy"
    Solution: "side english" → "kỹ thuật xoáy ngang"

    Strategy 2: Compound Translation
    ─────────────────────────────────────────────────────────────────────────
    English: "draw", "follow"
    Problem: Both use "quay" (spin)
    Solution: "draw" → "xoáy ngược", "follow" → "xoáy thuận"

    Strategy 3: Explanatory Translation
    ─────────────────────────────────────────────────────────────────────────
    English: "bridge", "rest"
    Problem: Both mean support device
    Solution: "hand bridge" → "tay trụ cầm tay", "score bridge" → "thiết bị ghi điểm"
```

### 5.2 Translation Format Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       TRANSLATION FORMAT RULES                               │
└─────────────────────────────────────────────────────────────────────────────┘

    FIRST USE FORMAT

    Standard First Use:
    ─────────────────────────────────────────────────────────────────────────
    English term (Vietnamese translation)

    ✓ CORRECT
    "A draw shot (đường cắt đít) uses backspin..."

    ✗ INCORRECT
    "A draw shot uses backspin (đường cắt đít)..."
    "A đường cắt đít (draw shot) uses backspin..."

    ─────────────────────────────────────────────────────────────────────────

    ESTABLISHED TERM FORMAT

    For well-established loanwords:
    ─────────────────────────────────────────────────────────────────────────
    English term (Vietnamese pronunciation/translation)

    ✓ CORRECT
    "break (đánh phá)"
    "scratch (ghiền)"
    "safety (đánh an toàn)"

    ✗ INCORRECT
    "break (phá bóng)" ← changes established meaning
    "scratch (lỗi)" ← too generic

    ─────────────────────────────────────────────────────────────────────────

    TECHNICAL TERM FORMAT

    When Vietnamese has no direct equivalent:
    ─────────────────────────────────────────────────────────────────────────
    English term (brief English explanation)

    ✓ CORRECT
    "english (side spin applied to the cue ball)"
    "squirt (cue ball deflection from english)"

    ✗ INCORRECT
    "english (xoáy ngang)"
    "squirt (hiện tượng lệch)"
```

### 5.3 Translation Quality Standards

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       TRANSLATION QUALITY STANDARDS                          │
└─────────────────────────────────────────────────────────────────────────────┘

    Required Translation Qualities:
    ─────────────────────────────────────────────────────────────────────────

    ✓ ACCURATE
    The translation must convey the exact meaning.

    ✓ UNIQUE
    The translation must not duplicate another concept's translation.

    ✓ NATURAL
    The translation should sound natural to Vietnamese speakers.

    ✓ CONSISTENT
    The translation style must follow established patterns.

    ─────────────────────────────────────────────────────────────────────────

    TRANSLATION REVIEW CHECKLIST

    □ Does the translation mean exactly what the English term means?
    □ Is this translation unique in the terminology database?
    □ Would a Vietnamese speaker naturally use this translation?
    □ Does this follow the same pattern as similar terms?
    □ Can this translation stand alone without English context?

    ─────────────────────────────────────────────────────────────────────────

    Example Review:

    Term: "cut shot"
    Proposed Translation: "đường cắt"
    
    Review:
    □ "Cut" means to divide or slice
    ✓ Translation conveys slicing motion
    □ Is "đường cắt" used for another term?
    → "draw shot" uses "đường cắt đít" ← Different ✓
    ✓ Natural Vietnamese phrasing
    ✓ Follows pattern "đường [action]"
    ✓ Can stand alone: "đường cắt ngang"

    ✓ APPROVED
```

---

## 6. Naming Consistency Rules

### 6.1 Compound Term Naming

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMPOUND TERM NAMING RULES                              │
└─────────────────────────────────────────────────────────────────────────────┘

    DEFINITION
    ─────────────────────────────────────────────────────────────────────────
    Compound terms are combinations of base terms that create 
    specific concepts.

    Examples:
    • "cue ball" = cue + ball
    • "draw shot" = draw + shot
    • "english with draw" = english + with + draw

    ─────────────────────────────────────────────────────────────────────────

    COMPOUND TERM RULES

    6.1.1  WORD ORDER CONSISTENCY
    ─────────────────────────────────────────────────────────────────────────

    If a pattern is established, maintain it.

    Established Pattern: [Technique] + [Shot/Stroke]
    ✓ CORRECT
    "draw shot"
    "follow shot"
    "stop shot"
    "massé shot"

    ✗ INCORRECT
    "shot draw"
    "shot follow"
    "massé stroke"

    ─────────────────────────────────────────────────────────────────────────

    6.1.2  CONNECTOR CONSISTENCY
    ─────────────────────────────────────────────────────────────────────────

    Use consistent connectors for compound concepts.

    Pattern: [Term] + [with/withdraw] + [Term]

    ✓ CORRECT
    "english with draw"
    "english with follow"
    "draw with english"

    ✗ INCORRECT
    "english and draw"
    "draw + english"
    "english-draw combination"

    ─────────────────────────────────────────────────────────────────────────

    6.1.3  MODIFIER PLACEMENT
    ─────────────────────────────────────────────────────────────────────────

    Adjective modifiers come BEFORE the noun.

    ✓ CORRECT
    "inside english"
    "outside english"
    "heavy draw"
    "light follow"

    ✗ INCORRECT
    "english inside"
    "draw heavy"
```

### 6.2 Capitalization Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CAPITALIZATION RULES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    TERM LIST CAPITALIZATION
    ─────────────────────────────────────────────────────────────────────────
    Terms in lists and indexes use Title Case.

    ✓ CORRECT
    "Draw Shot"
    "Follow Shot"
    "Stop Shot"
    "English"

    ─────────────────────────────────────────────────────────────────────────

    INLINE CAPITALIZATION
    ─────────────────────────────────────────────────────────────────────────
    Terms used inline use Sentence Case.

    ✓ CORRECT
    "A draw shot uses backspin..."
    "The follow shot applies top spin..."
    "English affects rebound angles..."

    ─────────────────────────────────────────────────────────────────────────

    HEADING CAPITALIZATION
    ─────────────────────────────────────────────────────────────────────────
    Article titles and major headings use Title Case.

    ✓ CORRECT
    ## Draw Shot Fundamentals
    ## Understanding English
    ### Inside English Technique

    ─────────────────────────────────────────────────────────────────────────

    PROPER NOUNS
    ─────────────────────────────────────────────────────────────────────────
    Proper nouns retain capitalization.

    ✓ CORRECT
    "World Pool-Billiard Association (WPA)"
    "Billiards Congress of America (BCA)"
    "Vietnam Pool Association"

    ✗ INCORRECT
    "World pool-billiard association"
    "Billiards congress of america"
```

### 6.3 Plural and Singular

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PLURAL/SINGULAR RULES                              │
└─────────────────────────────────────────────────────────────────────────────┘

    CONSISTENCY RULE
    ─────────────────────────────────────────────────────────────────────────
    Use the same form (singular or plural) for the same concept.

    Preferred: Use singular as base form
    ─────────────────────────────────────────────────────────────────────────

    ✓ CORRECT
    "The draw shot uses backspin"
    "Draw shots require below-center contact"
    "Practice your draw shot technique"

    ✗ INCORRECT
    "The draw shots use backspin"
    "Practice your draws"

    ─────────────────────────────────────────────────────────────────────────

    EXCEPTION: When plural is the standard term
    ─────────────────────────────────────────────────────────────────────────

    ✓ CORRECT
    "器材" (equipment - inherently plural concept)
    "Quilt" (in quilting - standard usage)

    Standard plural terms:
    • "solids" (for solid-colored balls)
    • "stripes" (for striped balls)
    • "colors" (in snooker)
```

---

## 7. Terminology Database Rules

### 7.1 Database Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DATABASE STRUCTURE RULES                              │
└─────────────────────────────────────────────────────────────────────────────┘

    EVERY term MUST be registered in the terminology database.

    Required Fields:
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field            │ Required │ Description                          │
    │   ───────────────┼──────────┼─────────────────────────────────────── │
    │   term_id         │ YES      │ Unique identifier                      │
    │   canonical_term  │ YES      │ Official term name                     │
    │   aliases         │ YES      │ List of alternative names              │
    │   translations   │ YES      │ Map of locale → translation            │
    │   category        │ YES      │ BKM category classification            │
    │   difficulty      │ YES      │ Beginner/Intermediate/Advanced/etc    │
    │   usage_count    │ YES      │ Number of articles using this term      │
    │   created_date   │ YES      │ When term was added                    │
    │   updated_date   │ YES      │ Last modification date                 │
    │   status         │ YES      │ Active/Deprecated/Replaced             │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Database Operations

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DATABASE OPERATION RULES                              │
└─────────────────────────────────────────────────────────────────────────────┘

    ADDING NEW TERMS
    ─────────────────────────────────────────────────────────────────────────

    Step 1: Search for existing
    ─────────────────────────────────────────────────────────────────────────
    Before creating a new term, search the database for:
    • Exact match on canonical term
    • Match on any alias
    • Match on translation

    Step 2: Conflict check
    ─────────────────────────────────────────────────────────────────────────
    □ Does this concept already exist?
    □ Does this translation already exist?
    □ Does any alias conflict?

    Step 3: Registration
    ─────────────────────────────────────────────────────────────────────────
    If no conflict, register with all required fields.

    ─────────────────────────────────────────────────────────────────────────

    UPDATING TERMS
    ─────────────────────────────────────────────────────────────────────────

    Allowed Updates:
    ✓ Add new alias
    ✓ Update translation (with version tracking)
    ✓ Update metadata (category, difficulty)
    ✓ Deprecate and replace

    Never Allowed:
    ✗ Change canonical term (create new term instead)
    ✗ Delete term (mark as deprecated)
    ✗ Change translation that would conflict

    ─────────────────────────────────────────────────────────────────────────

    DEPRECATING TERMS
    ─────────────────────────────────────────────────────────────────────────

    When a term is deprecated:

    1. Mark status as "Deprecated"
    2. Add "replaced_by" field pointing to new term
    3. Add migration notes
    4. Update all content to use replacement

    Example:

    ```json
    {
      "term_id": "screw_shot",
      "canonical_term": "screw shot",
      "status": "Deprecated",
      "replaced_by": "draw_shot",
      "deprecation_date": "2026-07-17",
      "migration_note": "Use 'draw shot' as canonical term"
    }
    ```
```

---

## 8. Content Creation Rules

### 8.1 Term Usage in Content

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTENT USAGE RULES                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    QUICK SUMMARY
    ─────────────────────────────────────────────────────────────────────────
    • Use canonical term only
    • No synonyms or aliases
    • No explanation needed if term is standard

    ✓ CORRECT
    "A shot using backspin to reverse cue ball direction"

    ✗ INCORRECT
    "A shot (also called screw or pull) using backspin..."
    "A screw shot using backspin..."

    ─────────────────────────────────────────────────────────────────────────

    SHORT DEFINITION
    ─────────────────────────────────────────────────────────────────────────
    • Use canonical term
    • Define briefly if not obvious
    • Use simple language

    ✓ CORRECT
    "A **draw shot** is a technique using backspin to reverse 
    cue ball direction after contact."

    ─────────────────────────────────────────────────────────────────────────

    FULL DEFINITION
    ─────────────────────────────────────────────────────────────────────────
    • Use canonical term throughout
    • List aliases in "Also Known As" section
    • First mention may include translation

    ✓ CORRECT
    ## Draw Shot

    A **draw shot** (đường cắt đít) is a technique using 
    backspin to reverse cue ball direction...

    ### Also Known As
    - Screw shot
    - Pull shot
    - Backspin shot

    ### How to Execute
    1. Place tip below center...
    2. Accelerate through...

    ✗ INCORRECT
    ## Screw Shot

    A screw shot (also called draw shot)...

    ─────────────────────────────────────────────────────────────────────────

    HEADINGS
    ─────────────────────────────────────────────────────────────────────────
    • Article title: Canonical term
    • Section headings: Canonical term
    • Subheadings: Canonical term

    ✓ CORRECT
    ## Draw Shot
    ### Draw Shot Mechanics
    #### Advanced Draw Control

    ✗ INCORRECT
    ## Draw Shot
    ### The Screw/Pull Technique
    #### Mastering Backspin
```

### 8.2 Cross-Reference Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CROSS-REFERENCE RULES                                │
└─────────────────────────────────────────────────────────────────────────────┘

    WHEN CROSS-REFERENCING
    ─────────────────────────────────────────────────────────────────────────
    Use canonical term in links and references.

    ✓ CORRECT
    "See also: Follow Shot"
    "Compare with: Stop Shot"
    "Related: English with Draw"

    ✗ INCORRECT
    "See also: Follow-through stroke"
    "Compare with: Dead ball"
    "Related: Top spin shot"

    ─────────────────────────────────────────────────────────────────────────

    LINKING FORMAT
    ─────────────────────────────────────────────────────────────────────────
    Cross-references must link to the canonical term article.

    ✓ CORRECT
    "[[Draw Shot]]"
    "[[Follow Shot|Draw Shot and Follow Shot]]"

    ✗ INCORRECT
    "[[Screw Shot]]"     ← Alias, not canonical
    "[[Backspin Shot]]"  ← Alias, not canonical
```

### 8.3 Search Optimization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SEARCH OPTIMIZATION RULES                             │
└─────────────────────────────────────────────────────────────────────────────┘

    KEYWORDS AND ALIASES
    ─────────────────────────────────────────────────────────────────────────
    Aliases are used for search optimization, NOT content.

    Term Metadata for Search:

    ```json
    {
      "term_id": "draw_shot",
      "canonical_term": "draw shot",
      "aliases": ["screw shot", "pull shot", "backspin shot"],
      "search_keywords": [
        "draw shot",
        "screw shot", 
        "pull shot",
        "backspin",
        "đường cắt đít",
        "xoáy ngược"
      ]
    }
    ```

    Content Writers:
    ─────────────────────────────────────────────────────────────────────────
    • Write content using canonical terms
    • Do NOT manually include aliases in content
    • The system handles search indexing

    Exception - Brief Mention:
    ─────────────────────────────────────────────────────────────────────────
    Only for articles where users commonly search alias:

    "Draw shot (also called screw shot) is..."

    This exception is for high-traffic aliases, approved by content team.
```

---

## 9. Conflict Resolution

### 9.1 Conflict Types

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONFLICT TYPES                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    TYPE 1: Same Term, Different Concepts
    ─────────────────────────────────────────────────────────────────────────
    Problem: "bridge" means both hand bridge and score bridge

    Resolution:
    → Use compound terms: "hand bridge", "score bridge"
    → Deprecate ambiguous "bridge"

    TYPE 2: Different Terms, Same Concept
    ─────────────────────────────────────────────────────────────────────────
    Problem: "draw shot" and "screw shot" refer to same technique

    Resolution:
    → Select canonical: "draw shot"
    → Add aliases: "screw shot", "pull shot"
    → Migrate content to canonical

    TYPE 3: Same Translation, Different Concepts
    ─────────────────────────────────────────────────────────────────────────
    Problem: Both "cut shot" and "draw shot" map to "đường cắt"

    Resolution:
    → Make translations unique
    → "cut shot" → "đường cắt ngang"
    → "draw shot" → "đường cắt đít"

    TYPE 4: Term Reuse
    ─────────────────────────────────────────────────────────────────────────
    Problem: "run" in "run a rack" vs "run" in "running ball"

    Resolution:
    → This is acceptable - same word, different meanings
    → Context makes meaning clear
    → No action needed
```

### 9.2 Resolution Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        RESOLUTION PROCESS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    STEP 1: IDENTIFY CONFLICT
    ─────────────────────────────────────────────────────────────────────────
    Report conflict to terminology team with:
    • Conflicting terms
    • Evidence of conflict
    • Proposed resolution

    STEP 2: REVIEW CONTEXT
    ─────────────────────────────────────────────────────────────────────────
    Terminology team reviews:
    • Historical usage in BKM
    • Industry standards
    • Impact on existing content
    • User search patterns

    STEP 3: DECIDE RESOLUTION
    ─────────────────────────────────────────────────────────────────────────
    Options:
    • Keep existing, deprecate new
    • Merge concepts
    • Keep both, differentiate
    • Create compound term

    STEP 4: IMPLEMENT
    ─────────────────────────────────────────────────────────────────────────
    • Update terminology database
    • Update affected content
    • Document change
    • Notify content team

    STEP 5: VERIFY
    ─────────────────────────────────────────────────────────────────────────
    • Check no new conflicts created
    • Verify content consistency
    • Monitor search effectiveness
```

---

## 10. Quality Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          QUALITY CHECKLIST                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Before Publishing Content:
    ─────────────────────────────────────────────────────────────────────────

    □ Terminology Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] All terms use canonical form
    [ ] No synonyms used in place of canonical
    [ ] Aliases only in "Also Known As" section
    [ ] Translations are unique

    □ Consistency Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] Word order matches standard pattern
    [ ] Capitalization follows rules
    [ ] Plural/singular consistent
    [ ] Cross-references use canonical terms

    □ Translation Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] First use includes translation format
    [ ] Translation is unique
    [ ] Translation is accurate
    [ ] Translation sounds natural

    □ Database Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] New terms registered in database
    [ ] No duplicate translations
    [ ] No conflicting aliases
    [ ] Search keywords included
```

---

## 11. Terminology Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      QUICK REFERENCE TABLE                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   DO                                                                  │
    │   ────────────────────────────────────────────────────────────────  │
    │   ✓ Use canonical term everywhere                                    │
    │   ✓ Document aliases in metadata                                    │
    │   ✓ Create unique translations                                      │
    │   ✓ Follow established patterns                                     │
    │   ✓ Use title case in lists, sentence case in content              │
    │   ✓ Register new terms before use                                   │
    │   ✓ Deprecate instead of delete                                    │
    │                                                                      │
    │   DON'T                                                               │
    │   ────────────────────────────────────────────────────────────────  │
    │   ✗ Use synonyms instead of canonical terms                        │
    │   ✗ Create duplicate translations                                  │
    │   ✗ Mix regional variants in same content                          │
    │   ✗ Change canonical terms                                          │
    │   ✗ Use aliases in main content                                    │
    │   ✗ Create terms without database registration                     │
    │   ✗ Delete terms (deprecate instead)                               │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 12. Related Documents

- [Article Specification](./article_specification.md)
- [Definition Standard](./definition_standard.md)
- [Example Standard](./example_standard.md)
- [Difficulty Standard](./difficulty_standard.md)
- [Term Schema](./term_schema.md)
- [Validation Rules](./validation_rules.md)

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial terminology rules |

---

**Standard Owner:** Content Team
**Next Review:** Monthly during content development
