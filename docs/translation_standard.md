# BKM - Translation Standard

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This standard defines the bilingual translation framework for all billiard terms. Every term in the BKM Knowledge Graph must support both English and Vietnamese with multiple translation layers to serve different user needs.

---

## 2. Translation Layers

### 2.1 Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TRANSLATION LAYER MODEL                               │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                     │
    │                        USER CONTEXT                                  │
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │  Layer 4: Common Translation (layman understanding)        │   │
    │   │  "Cắt đít" → "Draw shot" (casual, everyday language)      │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    │                              ▲                                       │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │  Layer 3: Professional Translation (standard terminology)  │   │
    │   │  "Cắt đít" → "Draw shot" (formal, teaching context)      │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    │                              ▲                                       │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │  Layer 2: Literal Translation (word-by-word)               │   │
    │   │  "Cắt đít" → "Cut bottom/end" (exact meaning)             │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    │                              ▲                                       │
    │   ┌─────────────────────────────────────────────────────────────┐   │
    │   │  Layer 1: Native Name (official term in each language)       │   │
    │   │  "Draw Shot" / "Đường Cắt Đít"                             │   │
    │   └─────────────────────────────────────────────────────────────┘   │
    │                                                                     │
    └─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Layer Definitions

| Layer | Name | Purpose | Use Case |
|-------|------|---------|----------|
| 1 | Native Name | Official term in each language | Primary display, search |
| 2 | Literal Translation | Word-by-word translation | Learning, etymology |
| 3 | Professional Translation | Standard technical term | Teaching, documentation |
| 4 | Common Translation | Layman, everyday language | Casual users, beginners |

---

## 3. Data Model

### 3.1 Translation Structure

```json
{
  "term_id": "TERM-000009",
  "term_slug": "draw-shot",
  "translations": {
    "en": {
      "native_name": "Draw Shot",
      "literal": "Draw Shot",
      "professional": "Draw Shot",
      "common": "Draw Shot",
      "phonetic": "/drɔː ʃɒt/"
    },
    "vi": {
      "native_name": "Đường Cắt Đít",
      "literal": "Cắt đít (cắt = cut, đít = bottom/end)",
      "professional": "Đường cắt đít",
      "common": "Cắt đít, Lộn đít",
      "phonetic": "/duəŋ˧˦ kat˦ˀ dit˦ˀ/"
    }
  },
  "notes": {
    "en": "Also called 'screw shot' or 'pull shot'",
    "vi": "Còn gọi là 'screw shot' hoặc 'pull shot'"
  }
}
```

### 3.2 Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `term_id` | ID | Yes | Reference to term |
| `translations` | object | Yes | Per-language translation object |
| `native_name` | string | Yes | Official term in that language |
| `literal` | string | Yes | Literal word-by-word translation |
| `professional` | string | Yes | Standard technical translation |
| `common` | string | No | Common/colloquial translations |
| `phonetic` | string | No | IPA pronunciation guide |
| `notes` | object | No | Additional translation notes |

---

## 4. Translation Guidelines

### 4.1 Native Name (Layer 1)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              NATIVE NAME                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Requirements:
    ✓ Must be the official, accepted term in the language
    ✓ Capitalize proper nouns and formal terms
    ✓ Use standard spelling conventions
    ✓ Include diacritical marks (Vietnamese: ă, â, đ, ê, ô, ơ, ư)
    
    Examples:
    English: "Draw Shot" (not "draw shot" or "DRAW SHOT")
    Vietnamese: "Đường Cắt Đít" (not "đường cắt đít")
```

### 4.2 Literal Translation (Layer 2)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LITERAL TRANSLATION                               │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Word-by-word translation to understand term etymology
    
    Format: "Translation (breakdown)"
    
    Rules:
    ✓ Translate each word literally
    ✓ Provide word-by-word breakdown in parentheses
    ✓ Maintain grammatical structure explanation
    ✓ Use simple, clear language
    
    Examples:
    Vietnamese → English:
    "Đường Cắt Đít" → "Draw Shot (đường = shot/path, cắt = cut, đít = bottom)"
    "Bóng Cơ" → "Cue Ball (bóng = ball, cơ = cue)"
    
    English → Vietnamese:
    "Draw Shot" → "Đường Cắt Đít (draw = cắt, shot = đường)"
    "English" → "Xoáy Ngang (english = xoáy ngang)"
```

### 4.3 Professional Translation (Layer 3)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PROFESSIONAL TRANSLATION                               │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Standard technical terminology for formal contexts
    
    Rules:
    ✓ Use official/standard billiard terminology
    ✓ Follow professional associations' conventions
    ✓ Appropriate for teaching and documentation
    ✓ Consistent across similar terms
    
    Examples:
    English → Vietnamese (Professional):
    "Draw Shot" → "Đường cắt đít"
    "Stop Shot" → "Đường dừng"
    "Follow Shot" → "Đường đi theo"
    
    ✓ All use "đường" prefix (standard technical prefix)
    ✓ Consistent capitalization (Title Case)
```

### 4.4 Common Translation (Layer 4)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           COMMON TRANSLATION                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Everyday language for casual learners and beginners
    
    Rules:
    ✓ Use colloquial, commonly spoken terms
    ✓ May include slang and informal variations
    ✓ Multiple alternatives allowed (separated by commas)
    ✓ Prioritize terms people actually use
    
    Examples:
    "Đường Cắt Đít" → Common: "Cắt đít, Lộn đít, Xoáy ngược"
    
    Note: "Cắt đít" is common, "Lộn đít" is regional slang
```

---

## 5. Vietnamese Translation Rules

### 5.1 Orthographic Standards

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VIETNAMESE ORTHOGRAPHY                               │
└─────────────────────────────────────────────────────────────────────────────┘

    Required Diacritics:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Letter │ Usage          │ Example                                  │
    ├────────┼────────────────┼─────────────────────────────────────────┤
    │ ă      │ Short A        │ Băng (cushion)                          │
    │ â      │ Deep A         │ Cắt (cut)                               │
    │ đ      │ D-stop         │ Đường (shot/path)                       │
    │ ê      │ E-close        │ Kẹt (snooker)                          │
    │ ô      │ O-close        │ Cơ (cue)                                │
    │ ơ      │ O-open         │ Bơi (swim - metaphor)                   │
    │ ư      │ U-oo           │ Lựa (choose)                           │
    └─────────────────────────────────────────────────────────────────────┘
    
    Tone Marks:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Tone  │ Mark  │ Word      │ Sound                                  │
    ├────────┼───────┼───────────┼───────────────────────────────────────┤
    │ Ngang  │ (none)│ ma        │ flat                                   │
    │ Huyền  │ `     │ mà        │ low                                    │
    │ Sắc   │ '     │ má        │ high rising                            │
    │ Hỏi   │ ?     │ mả        │ dipping                                │
    │ Ngã   │ ~     │ mã        │ rising broken                          │
    │ Nặng  │ .     │ mạ        │ low falling                            │
    └─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Terminology Conventions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       TERMINOLOGY CONVENTIONS                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Prefix Patterns:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Prefix    │ Usage            │ Example                              │
    ├───────────┼──────────────────┼─────────────────────────────────────┤
    │ Đường     │ Shot types       │ Đường cắt đít, Đường dừng           │
    │ Bóng      │ Ball types       │ Bóng cơ, Bóng mục tiêu               │
    │ Băng      │ Cushion terms    │ Băng, Đánh băng                      │
    │ Túi       │ Pocket terms     │ Túi góc, Túi bên                     │
    │ Kỹ thuật  │ Techniques       │ Kỹ thuật cầu, Kỹ thuật ngắm          │
    │ Tư thế    │ Stance/position  │ Tư thế, Tư thế cơ bản               │
    │ Cầu       │ Bridge types     │ Cầu mở, Cầu cơ khí                   │
    └─────────────────────────────────────────────────────────────────────┘
```

### 5.3 Regional Variations

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         REGIONAL VARIATIONS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Northern Vietnam (Hà Nội):
    • "Cắt đít" - Standard usage
    • "Băng" - For cushion
    
    Central Vietnam:
    • Regional terms may vary
    • "Căng" - Alternative pronunciation
    
    Southern Vietnam:
    • "Lộn đít" - More common than "Cắt đít"
    • "Bi" - More common than "Bóng"
    
    Document regional variations in notes field:
    {
      "common": "Cắt đít, Lộn đít",
      "notes": {
        "vi": "Lộn đít phổ biến ở miền Nam"
      }
    }
```

---

## 6. English Translation Rules

### 6.1 Spelling Conventions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ENGLISH SPELLING                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    British vs American:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Concept          │ British            │ American                   │
    ├─────────────────┼────────────────────┼────────────────────────────┤
    │ Cue ball        │ White ball         │ Cue ball                  │
    │ Object balls    │ Coloured balls     │ Object balls              │
    │ Pocket          │ Pot                │ Pocket                    │
    │ Cushion         │ Cushion            │ Rail (in some contexts)   │
    │ Cloth           │ Cloth              │ Felt                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    Document dialect differences:
    {
      "en": {
        "native_name": "Cue Ball",
        "british_variant": "White Ball",
        "american_variant": "Cue Ball"
      }
    }
```

### 6.2 Capitalization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CAPITALIZATION                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Title Case (Official Names):
    "Draw Shot", "Stop Shot", "English Spin"
    
    Sentence Case (Descriptions):
    "This is a draw shot used for position play"
    
    All Caps (Abbreviations):
    "CTE", "OB", "CB", "CBSE"
```

---

## 7. Special Cases

### 7.1 Untranslatable Terms

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           UNTRANSLATABLE                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Some terms have no direct translation:
    
    Strategy: Keep original + explain
    
    Example:
    "Massé" (French origin)
    → Vietnamese: "Massé" (keep French, with explanation)
    → Literal: "Massé (kỹ thuật đường cong với xoáy mạnh)"
    
    Rule: Mark as untranslatable and provide phonetic approximation
```

### 7.2 Loan Words

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            LOAN WORDS                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    Common billiard loan words in Vietnamese:
    
    ┌─────────────────────────────────────────────────────────────────────┐
    │ English     │ Vietnamese     │ Notes                        │
    ├─────────────┼────────────────┼──────────────────────────────┤
    │ Break       │ Break          │ Keep English spelling       │
    │ Safety      │ Safety         │ Keep English spelling       │
    │ Snooker     │ Snooker        │ Keep English spelling       │
    │ Massé       │ Massé          │ Keep French spelling        │
    │ Carom       │ Carom          │ Keep English spelling       │
    │ Spin        │ Spin           │ May also use "xoáy"         │
    │ English     │ English        │ Keep English (except in     │
    │             │                │ combination: xoáy ngang)    │
    └─────────────────────────────────────────────────────────────────────┘
```

### 7.3 Compound Terms

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMPOUND TERMS                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    English compounds → Vietnamese compounds:
    
    "Jump Shot" → "Đường Nhảy"
    (verb + noun → noun phrase with "đường")
    
    "Side Pocket" → "Túi Bên"
    (adjective + noun → noun phrase reordered)
    
    "Power Draw" → "Đường Cắt Đít Lực"
    (adjective + noun → noun phrase with modifiers)
```

---

## 8. Quality Standards

### 8.1 Review Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TRANSLATION REVIEW                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    □ Native name matches official terminology
    □ Literal translation accurately breaks down each word
    □ Professional translation follows industry standards
    □ Common translation reflects actual usage
    □ Vietnamese diacritics are correct
    □ Tone marks are appropriate for context
    □ No anglicisms in Vietnamese (unless loan word)
    □ Consistency with related terms
    □ Regional variations noted
    □ Phonetic guides are accurate (IPA)
```

### 8.2 Consistency Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONSISTENCY RULES                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    1. Shot types: Always use "Đường" prefix
       ✓ Đường cắt đít, Đường dừng, Đường đi theo
       ✗ Cắt đít, Dừng bóng (inconsistent)
    
    2. Ball types: Always use "Bóng" prefix
       ✓ Bóng cơ, Bóng mục tiêu, Bóng 8
       ✗ Cơ, Bi mục tiêu (inconsistent)
    
    3. Equipment: Use standard vocabulary
       ✓ Cơ, Băng, Túi, Phấn
       ✗ Gậy (not standard for billiards)
```

---

## 9. Example Translations

### 9.1 Shot Terms

```json
{
  "term_id": "TERM-000009",
  "term_slug": "draw-shot",
  "translations": {
    "en": {
      "native_name": "Draw Shot",
      "literal": "Draw Shot (draw = pull back, shot = stroke)",
      "professional": "Draw Shot",
      "common": "Draw Shot, Screw Shot, Pull Shot",
      "phonetic": "/drɔː ʃɒt/"
    },
    "vi": {
      "native_name": "Đường Cắt Đít",
      "literal": "Cắt đít (cắt = cut, đít = bottom/end)",
      "professional": "Đường cắt đít",
      "common": "Cắt đít, Lộn đít, Xoáy ngược",
      "phonetic": "/duəŋ˧˦ kat˦ˀ dit˦ˀ/"
    }
  }
}
```

```json
{
  "term_id": "TERM-000012",
  "term_slug": "english",
  "translations": {
    "en": {
      "native_name": "English",
      "literal": "English (historical term, origin unclear)",
      "professional": "English (Side Spin)",
      "common": "English, Side Spin, Sidespin",
      "phonetic": "/ˈɪŋɡlɪʃ/"
    },
    "vi": {
      "native_name": "Xoáy Ngang",
      "literal": "Xoáy ngang (xoáy = spin, ngang = horizontal)",
      "professional": "Xoáy ngang",
      "common": "Xoáy ngang, Xoáy bên, Lết",
      "phonetic": "/sɔaj˧˦ ŋaːŋ˧˦/"
    }
  }
}
```

### 9.2 Equipment Terms

```json
{
  "term_id": "TERM-000026",
  "term_slug": "cue-stick",
  "translations": {
    "en": {
      "native_name": "Cue Stick",
      "literal": "Cue Stick (cue = shortened form, stick = rod)",
      "professional": "Cue Stick, Cue",
      "common": "Cue, Stick, Pool Cue",
      "phonetic": "/kjuː stɪk/"
    },
    "vi": {
      "native_name": "Cơ Bi-a",
      "literal": "Cơ bi-a (cơ = cue stick, bi-a = billiards)",
      "professional": "Cơ bi-a",
      "common": "Cơ, Gậy cơ, Cán cơ",
      "phonetic": "/kəː˧˦ bi˧˦ aː˧˦/"
    }
  }
}
```

### 9.3 Position Terms

```json
{
  "term_id": "TERM-000062",
  "term_slug": "bridge",
  "translations": {
    "en": {
      "native_name": "Bridge",
      "literal": "Bridge (support structure)",
      "professional": "Bridge, Bridge Hand",
      "common": "Bridge, Rest",
      "phonetic": "/brɪdʒ/"
    },
    "vi": {
      "native_name": "Tay Giá Đỡ",
      "literal": "Tay giá đỡ (tay = hand, giá đỡ = support)",
      "professional": "Tay giá đỡ, Cầu",
      "common": "Cầu, Tay chống",
      "phonetic": "/taj˧˦ ʒa˧˦ dɤ˧˦/"
    }
  }
}
```

---

## 10. Database Schema Extension

### 10.1 Translation Table

```sql
CREATE TABLE translations (
    id                  VARCHAR(20) PRIMARY KEY,
    term_id             VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    language            VARCHAR(5) NOT NULL,
    
    -- Name layers
    native_name         VARCHAR(255) NOT NULL,
    literal             VARCHAR(500) NOT NULL,
    professional        VARCHAR(255) NOT NULL,
    common              VARCHAR(500),
    
    -- Additional
    phonetic            VARCHAR(100),
    dialect_variant     VARCHAR(255),
    
    -- Metadata
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_term_language UNIQUE (term_id, language),
    CONSTRAINT valid_language CHECK (language IN ('en', 'vi'))
);

CREATE INDEX idx_translations_term ON translations(term_id);
CREATE INDEX idx_translations_language ON translations(language);
```

---

## 11. Related Documents

- [Term Schema](./term_schema.md)
- [Alias System](./alias_schema.md)
- [Naming Convention](./naming.md)
- [ID Standard](./id_standard.md)

---

## 12. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial translation standard |

---

**Standard Owner:** Content Team
**Next Review:** Q4 2026
