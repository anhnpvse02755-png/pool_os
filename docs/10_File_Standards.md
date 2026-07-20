# Billiard Knowledge Module (BKM) - File Standards

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Markdown Standards

### 1.1 File Structure

```markdown
# Document Title (H1)

## Version X.X
**Last Updated:** Month Year
**Status:** Draft | Review | Published | Deprecated

---

## Section Title (H2)

### Subsection Title (H3)

#### Detail Title (H4)

##### Minor Title (H5)

###### Note Title (H6)
```

### 1.2 Document Template

```markdown
# [Document Title]

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Overview

[Introduction and purpose]

## 2. [Main Section]

[Content]

## 3. [Additional Section]

[Content]

---

## X. Appendix

### X.1 Related Documents

- [Document Name](./path/document.md)

### X.2 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jul 2026 | Name | Initial specification |

---

**End of Document**
```

---

## 2. Heading Hierarchy

### 2.1 Heading Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Single H1** | Only one per file | `# Title` |
| **Sequential** | Don't skip levels | After H2, use H3 |
| **Meaningful** | Descriptive, not generic | `## Stroke Mechanics` |
| **No Code in H1** | Keep H1 clean | `# Draw Shot`, not `# draw-shot.json` |
| **Sentence Case** | Capitalize first word, proper nouns | `## How to Execute` |

### 2.2 Heading Examples

```markdown
# Draw Shot

## Definition

### Primary Definition

#### When to Use

### Technical Definition

#### Physics Principles

## How to Execute

### Step 1: Setup

### Step 2: Execution

### Step 3: Follow Through
```

### 2.3 Incorrect Headings

```markdown
# draw shot                        ❌ (lowercase)
## Definition                     ✅
### important note                ❌ (lowercase)
## 1. Overview                   ❌ (numbered)
## Section One                   ❌ (numbered)
### - bullet point                ❌ (not a heading)
```

---

## 3. Code Block Conventions

### 3.1 Code Block with Language

````markdown
```json
{
  "name": "Draw Shot",
  "difficulty": "intermediate"
}
```

```typescript
interface Term {
  id: string;
  slug: string;
  name: Record<string, string>;
}
```

```sql
SELECT * FROM terms WHERE slug = 'draw-shot';
```

```dart
class TermService {
  Future<Term> getBySlug(String slug) async {
    return await repository.getBySlug(slug);
  }
}
```
````

### 3.2 Code Block without Language

Use when showing generic code snippets or pseudo-code:

````markdown
```
Pseudo-code example:
1. Get user input
2. Process request
3. Return response
```

```
File naming pattern:
{type}-{slug}-{variant}.{ext}
```
````

### 3.3 Inline Code

Use backticks for inline code:

```markdown
Use `slug` for URL-safe identifiers.
The term `draw-shot` has ID `550e8400-...`.
Set `status = 'published'` to make visible.
```

### 3.4 Code Reference Format

When referencing existing code from the codebase:

```markdown
The `TermService` class (```10:25:lib/services/term_service.dart```) handles...
```

Format: `startLine:endLine:filepath`

---

## 4. Link Standards

### 4.1 Internal Links

```markdown
See [Database Schema](./03_Database.md) for entity definitions.
Refer to [Category System](./06_Category_System.md#category-tree).
```

### 4.2 External Links

```markdown
Learn more about [PostgreSQL](https://www.postgresql.org/).
Visit the [Pool OS Website](https://pool-os.com).
```

### 4.3 Anchor Links

```markdown
Jump to [Section 3](#3-section-title).
Jump to [Code Example](#code-example).
```

### 4.4 Link Best Practices

| Practice | Example | Notes |
|----------|---------|-------|
| **Descriptive** | `[Database Schema](./03_Database.md)` | ✅ |
| **Vague** | `[Click here](./...)` | ❌ |
| **Full URL** | `https://example.com/docs` | For external links |
| **Relative** | `./folder/file.md` | For internal links |

---

## 5. Image Embedding Rules

### 5.1 Image Syntax

```markdown
![Alt text](./images/diagram.png)
![Draw Shot Technique](./media/draw-shot-demo.jpg)
```

### 5.2 Image Best Practices

| Rule | Description | Example |
|------|-------------|---------|
| **Alt Text** | Required for accessibility | `![Description](./path)` |
| **Descriptive Name** | Clear, specific names | `draw-shot-diagram.png` |
| **Size Indication** | Note if large | `![Large diagram](./large.png)` |
| **Format** | Use WebP when possible | `.webp` over `.png` |

### 5.3 Image Placeholder Format

When image is pending:

```markdown
![Draw Shot Technique - Diagram Placeholder]
*Figure 1: Draw shot technique diagram (to be added)*
```

### 5.4 Image Sizing

```markdown
<!-- HTML approach (if supported) -->
<img src="./diagram.png" width="800" alt="Description">

<!-- Markdown approach -->
![Description](./diagram.png)

*Figure 1: Description (800px wide)*
```

---

## 6. Table Formatting

### 6.1 Basic Table

```markdown
| Column 1 | Column 2 | Column 3 |
|---------|---------|---------|
| Row 1   | Data    | Data    |
| Row 2   | Data    | Data    |
| Row 3   | Data    | Data    |
```

### 6.2 Table with Alignment

```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| Data | Data   | Data  |
| Data | Data   | Data  |
```

### 6.3 Table with Multiple Lines

```markdown
| Feature | Description |
|---------|-------------|
| Search | Full-text search with fuzzy matching |
| Filter | By difficulty, category, discipline |
| Sort | By relevance, date, popularity |
```

### 6.4 Complex Table

```markdown
| Metric | Definition | Target | Measurement |
|--------|------------|--------|-------------|
| **Accuracy** | Content verified by experts | >95% | Review score |
| **Coverage** | Terms with complete definitions | >90% | Auto check |
| **Freshness** | Content updated within 6 months | >80% | Date check |
```

### 6.5 Table Best Practices

| Practice | Description |
|----------|-------------|
| **Header Row** | Always include header row |
| **Alignment** | Use alignment for numeric columns |
| **Consistent Width** | Avoid extremely wide cells |
| **Pipe Alignment** | Align pipes for readability |

---

## 7. List Conventions

### 7.1 Bullet Lists

```markdown
- First item
- Second item
  - Nested item
  - Another nested
- Third item
```

### 7.2 Numbered Lists

```markdown
1. First step
2. Second step
3. Third step
   1. Sub-step
   2. Sub-step
```

### 7.3 Task Lists

```markdown
- [x] Completed task
- [ ] Pending task
- [ ] Another pending
```

### 7.4 Definition Lists

```markdown
Term 1
: Definition of term 1

Term 2
: Definition of term 2
```

### 7.5 List Best Practices

| Practice | Description |
|----------|-------------|
| **Consistent Style** | Use same list type throughout |
| **Indentation** | 2 spaces for nested items |
| **Capitalization** | Capitalize first word |
| **No Empty Items** | Don't leave items blank |

---

## 8. Frontmatter Requirements

### 8.1 Document Frontmatter

```markdown
---
title: "Draw Shot"
description: "Complete guide to draw shot technique in pool"
version: "1.0"
status: "published"
author: "Pool OS Team"
created: "2026-07-01"
updated: "2026-07-15"
tags: ["stroke", "spin", "technique"]
---
```

### 8.2 Term Frontmatter

```markdown
---
id: "550e8400-e29b-41d4-a716-446655440000"
slug: "draw-shot"
code: "DRAW_SHOT"
discipline: "pool"
difficulty: "intermediate"
version: "v1"
status: "published"
---
```

### 8.3 Frontmatter Standards

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `version` | Yes | Semantic version |
| `status` | Yes | draft/review/published |
| `created` | Yes | ISO date |
| `updated` | Yes | ISO date |
| `author` | Recommended | Author name |
| `tags` | Optional | Related tags |

---

## 9. File Naming Conventions

### 9.1 Documentation Files

| Type | Format | Example |
|------|--------|---------|
| **Specification** | `NN_Title.md` | `03_Database.md` |
| **Guide** | `NN_Title.md` | `10_File_Standards.md` |
| **Reference** | `NN_Title.md` | `15_API_Reference.md` |
| **Changelog** | `CHANGELOG.md` | `CHANGELOG.md` |
| **README** | `README.md` | `README.md` |

### 9.2 Content Files

| Type | Format | Example |
|------|--------|---------|
| **Term** | `{slug}.md` | `draw-shot.md` |
| **Category** | `{slug}.md` | `stroke-techniques.md` |
| **Drill** | `{slug}.md` | `straight-shot-drill.md` |

### 9.3 Media Files

| Type | Format | Example |
|------|--------|---------|
| **Image** | `{slug}-{variant}.{ext}` | `draw-shot-demo.webp` |
| **Video** | `{slug}-{variant}.{ext}` | `draw-shot-demo-1080p.mp4` |
| **Animation** | `{slug}-{variant}.{ext}` | `ball-path.gif` |

### 9.4 Naming Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Lowercase** | All lowercase | `draw-shot.md` |
| **Hyphens** | Words separated by hyphens | `stroke-techniques.md` |
| **No Spaces** | Never use spaces | ❌ `draw shot.md` |
| **No Special Chars** | Only alphanumeric + hyphens | `pool-fundamentals.md` |
| **Sequential** | Use numbers for ordering | `01_Overview.md` |
| **Descriptive** | Clear, meaningful names | `stroke-mechanics.md` |

---

## 10. Directory Structure Standards

### 10.1 Root Structure

```
docs/                       # Documentation root
├── 01_Project_Vision.md
├── 02_Architecture.md
├── 03_Database.md
├── ...
├── 15_API_Reference.md
├── _templates/
│   ├── term-template.md
│   └── guide-template.md
└── _assets/
    ├── images/
    └── diagrams/
```

### 10.2 Content Structure

```
content/
├── terms/
│   ├── pool/
│   │   ├── shots/
│   │   │   ├── draw-shot.md
│   │   │   └── follow-shot.md
│   │   ├── techniques/
│   │   └── rules/
│   ├── snooker/
│   └── shared/
│
├── drills/
│   ├── pool/
│   │   ├── individual/
│   │   │   └── straight-shot-drill.md
│   │   └── game-situation/
│   └── snooker/
│
└── glossary/
    ├── pool-glossary.md
    └── snooker-glossary.md
```

### 10.3 Archive Structure

```
archive/
├── deprecated/
│   ├── old-term-v1.md
│   └── superseded-guide.md
└── drafts/
    ├── incomplete-draft.md
    └── needs-review.md
```

---

## 11. Content Length Guidelines

### 11.1 Document Length Recommendations

| Document Type | Min Words | Target Words | Max Words |
|---------------|-----------|--------------|-----------|
| **Quick Reference** | 100 | 300 | 500 |
| **Single Term** | 200 | 500 | 1,500 |
| **Complete Guide** | 1,000 | 3,000 | 10,000 |
| **Technical Spec** | 2,000 | 5,000 | 20,000 |

### 11.2 Section Length

| Section Type | Target Length | Purpose |
|--------------|--------------|---------|
| **Overview** | 100-300 words | Quick understanding |
| **Detailed Section** | 500-1,500 words | Thorough coverage |
| **Reference** | Variable | Comprehensive |

### 11.3 Breaking Up Long Content

```markdown
## Long Topic

[Introduction paragraph]

### Core Concept

[Detailed explanation]

### Advanced Details

[For advanced users]

### Practical Examples

[Real-world applications]

### Common Mistakes

[What to avoid]

### See Also

[Related topics]
```

---

## 12. Special Formatting

### 12.1 Blockquotes

```markdown
> **Note:** This is an important note.
> It can span multiple lines.

> **Warning:** Be careful with this approach.
> It has side effects.
```

### 12.2 Alerts/Callouts

```markdown
> [!NOTE]  
> Information the user should know.

> [!TIP]  
> Helpful suggestion.

> [!WARNING]  
> Potential issue ahead.

> [!DANGER]  
> Critical warning.
```

### 12.3 Horizontal Rules

```markdown
---

Use horizontal rules to separate major sections.
```

### 12.4 Abbreviations

```markdown
*API* - Application Programming Interface
*CRUD* - Create, Read, Update, Delete
*UUID* - Universally Unique Identifier
```

---

## 13. Accessibility Standards

### 13.1 Writing for Accessibility

| Guideline | Description |
|-----------|-------------|
| **Plain Language** | Use simple, clear words |
| **Short Sentences** | Aim for <25 words per sentence |
| **Active Voice** | Prefer "The user clicks" over "It is clicked" |
| **Headings** | Use descriptive headings |
| **Lists** | Use lists for parallel items |
| **Alt Text** | Describe images meaningfully |

### 13.2 Checklist

- [ ] All images have descriptive alt text
- [ ] Links have meaningful text
- [ ] Headings create logical structure
- [ ] Lists use proper formatting
- [ ] Tables have header rows
- [ ] Code blocks specify language

---

## 14. Appendix

### 14.1 Quick Reference

```markdown
# H1 - Document Title
## H2 - Major Section
### H3 - Subsection
#### H4 - Detail
##### H5 - Minor
###### H6 - Note

**Bold** for emphasis
*Italic* for titles/terms
`Code` for technical terms
[Link](./path) for references
![Alt](./image) for images
| Table | Header |
|-------|--------|
| Data  | Data   |
```

### 14.2 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Architecture](./02_Architecture.md)
- [BKM Database Schema](./03_Database.md)

---

**End of Document**
