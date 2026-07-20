# BKM - Article Specification

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document defines the standard specification for all knowledge articles in the BKM Knowledge Base. Every article must follow this structure to ensure consistency, discoverability, and a unified user experience across the entire project.

---

## 2. Article Structure Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ARTICLE ANATOMY                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐  │
    │   │                    FRONT MATTER                              │  │
    │   │  • Article ID & Metadata                                    │  │
    │   │  • Classification (Category & Tags)                         │  │
    │   │  • Status & Version                                         │  │
    │   └─────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐  │
    │   │                    CONTENT CORE                            │  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  1. Names (EN + VI)                                   ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  2. Quick Summary                                    ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  3. Definition                                         ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  4. Detailed Content                                  ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  5. How to Execute                                     ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  6. When & When Not to Use                            ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  7. Common Mistakes & Corrections                     ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   │  ┌───────────────────────────────────────────────────────┐│  │
    │   │  │  8. Professional Tips                                 ││  │
    │   │  └───────────────────────────────────────────────────────┘│  │
    │   │                                                              │  │
    │   └─────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    │   ┌─────────────────────────────────────────────────────────────┐  │
    │   │                    BACK MATTER                              │  │
    │   │  • Related Terms                                           │  │
    │   │  • Media Attachments                                       │  │
    │   │  • Source & References                                     │  │
    │   │  • Changelog                                               │  │
    │   └─────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Front Matter

### 3.1 Metadata Block (Required)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          METADATA BLOCK                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    Every article MUST include these metadata fields at the top:
    
    ─────────────────────────────────────────────────────────────────────────
    
    Article ID:
    ─────────────────────────────────────────────────────────────────────────
    id: TERM-XXXXXX
    type: string
    format: TERM-NNNNNN
    required: YES
    
    Slug:
    ─────────────────────────────────────────────────────────────────────────
    slug: article-slug
    type: string
    format: kebab-case
    required: YES
    
    Category:
    ─────────────────────────────────────────────────────────────────────────
    category: CAT-XXXXXX
    type: string
    format: CAT-NNNNNN
    required: YES
    note: Must reference valid category
    
    Difficulty:
    ─────────────────────────────────────────────────────────────────────────
    difficulty: beginner | intermediate | advanced | professional
    type: enum
    required: YES
    
    Status:
    ─────────────────────────────────────────────────────────────────────────
    status: draft | review | published | deprecated
    type: enum
    required: YES
    
    Version:
    ─────────────────────────────────────────────────────────────────────────
    version: 1.0.0
    type: string
    format: semantic (major.minor.patch)
    required: YES
    
    Created:
    ─────────────────────────────────────────────────────────────────────────
    created: YYYY-MM-DD
    type: date
    required: YES
    
    Updated:
    ─────────────────────────────────────────────────────────────────────────
    updated: YYYY-MM-DD
    type: date
    required: YES
```

### 3.2 Classification Block (Required)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CLASSIFICATION BLOCK                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Tags:
    ─────────────────────────────────────────────────────────────────────────
    tags:
      - technique
      - fundamentals
      - must-know
    type: array of strings
    min: 1
    max: 10
    required: YES
    
    Priority:
    ─────────────────────────────────────────────────────────────────────────
    priority: 1 | 2 | 3 | 4
    type: integer
    description: Writing priority level
    required: YES
    
    Languages:
    ─────────────────────────────────────────────────────────────────────────
    languages: [en, vi]
    type: array of strings
    required: YES
    note: Always [en, vi] for BKM project
    
    ─────────────────────────────────────────────────────────────────────────
    
    Example:
    ─────────────────────────────────────────────────────────────────────────
    tags: [technique, spin, advanced]
    priority: 2
    languages: [en, vi]
```

---

## 4. Content Core Sections

### 4.1 Section 1: Names (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SECTION 1: NAMES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Provide the article's identity in both languages
    
    ─────────────────────────────────────────────────────────────────────────

    English Name:
    ─────────────────────────────────────────────────────────────────────────
    names:
      en: "Draw Shot"
    type: string
    min_length: 1
    max_length: 500
    required: YES
    
    Vietnamese Name:
    ─────────────────────────────────────────────────────────────────────────
    names:
      vi: "Đường Cắt Đít"
    type: string
    min_length: 1
    max_length: 500
    required: YES
    
    Pronunciation (Optional but Recommended):
    ─────────────────────────────────────────────────────────────────────────
    names:
      en_phonetic: "/drɔː ʃɒt/"
      vi_phonetic: "/ɗɯɐŋ˧ ˈkæt̚ˀ ˈɗi˧t̚ˀ/"
    type: string
    format: IPA
    required: NO
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 1. Names

    ### English
    Draw Shot

    ### Vietnamese
    Đường Cắt Đít

    ### Pronunciation (Optional)
    EN: /drɔː ʃɒt/
    VI: /ɗɯɐŋ˧ ˈkæt̚ˀ ˈɗi˧t̚ˀ/
```

### 4.2 Section 2: Quick Summary (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SECTION 2: QUICK SUMMARY                              │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: One-sentence overview for quick understanding
    
    ─────────────────────────────────────────────────────────────────────────

    English Summary:
    ─────────────────────────────────────────────────────────────────────────
    summary:
      en: "A shot using backspin to bring the cue ball back toward the player"
    type: string
    min_length: 30
    max_length: 150
    required: YES
    
    Vietnamese Summary:
    ─────────────────────────────────────────────────────────────────────────
    summary:
      vi: "Đòn đánh tạo lực ngược khiến bóng cơ quay về phía người đánh"
    type: string
    min_length: 30
    max_length: 150
    required: YES
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 2. Quick Summary

    **English:** A shot using backspin to bring the cue ball back toward 
    the player after contacting the object ball.

    **Vietnamese:** Đòn đánh tạo lực ngược khiến bóng cơ quay về phía 
    người đánh sau khi chạm bóng mục tiêu.
```

### 4.3 Section 3: Definition (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SECTION 3: DEFINITION                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Comprehensive definition in both languages
    
    ─────────────────────────────────────────────────────────────────────────

    English Definition:
    ─────────────────────────────────────────────────────────────────────────
    definition:
      en: |
        A draw shot (also called a screw shot, pull shot, or backspin shot) 
        is a type of cue ball control shot executed by striking the cue 
        ball below center with a follow-through motion.
        
        The backspin (also called "english" when applied sideways) causes 
        the cue ball to reverse direction after contacting the object ball, 
        traveling back toward or past the player.
    type: markdown
    min_length: 200
    max_length: 2000
    required: YES
    
    Vietnamese Definition:
    ─────────────────────────────────────────────────────────────────────────
    definition:
      vi: |
        Đường cắt đít (còn gọi là screw shot, pull shot, hoặc backspin shot) 
        là loại đòn kiểm soát bóng cơ được thực hiện bằng cách đánh vào 
        phần dưới tâm bóng cơ với chuyển động theo đuổi.
        
        Lực ngược (còn gọi là "english" khi đánh ngang) khiến bóng cơ đổi 
        hướng sau khi chạm bóng mục tiêu, di chuyển ngược về phía người đánh.
    type: markdown
    min_length: 200
    max_length: 2000
    required: YES
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 3. Definition

    ### English

    A draw shot (also called a screw shot, pull shot, or backspin shot) is 
    a type of cue ball control shot executed by striking the cue ball below 
    center with a follow-through motion.

    The backspin causes the cue ball to reverse direction after contacting 
    the object ball, traveling back toward or past the player.

    ### Vietnamese

    Đường cắt đít (còn gọi là screw shot, pull shot, hoặc backspin shot) 
    là loại đòn kiểm soát bóng cơ được thực hiện bằng cách đánh vào phần 
    dưới tâm bóng cơ với chuyển động theo đuổi.

    Lực ngược khiến bóng cơ đổi hướng sau khi chạm bóng mục tiêu, di 
    chuyển ngược về phía người đánh.
```

### 4.4 Section 4: Detailed Content (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SECTION 4: DETAILED CONTENT                            │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: In-depth explanation of the concept
    
    ─────────────────────────────────────────────────────────────────────────

    Subsections Required:
    ─────────────────────────────────────────────────────────────────────────
    
    ### 4.1 What It Is
    ─────────────────────────────────────────────────────────────────────────
    • Core concept explanation
    • Key characteristics
    • Distinguishing features from similar concepts
    
    ### 4.2 How It Works
    ─────────────────────────────────────────────────────────────────────────
    • Physics/mechanics explanation
    • Cause and effect relationships
    • Visual representation if helpful
    
    ### 4.3 Key Principles
    ─────────────────────────────────────────────────────────────────────────
    • 3-5 bullet points of essential principles
    • Each principle explained briefly
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 4. Detailed Content

    ### 4.1 What Is a Draw Shot?

    A draw shot is a fundamental cue ball control technique that creates 
    backspin on the cue ball. Unlike a stop shot (which uses center ball 
    contact) or a follow shot (which uses top spin), the draw shot requires 
    striking below the center of the cue ball.

    ### 4.2 How It Works

    When the cue tip strikes the cue ball below center:

    1. The cue ball initially slides forward with backspin
    2. As it contacts the object ball, some spin transfers
    3. The remaining backspin causes friction with the cloth
    4. The cue ball reverses direction and travels backward

    ### 4.3 Key Principles

    • **Below-center contact** is essential — typically ½ to 1 tip below center
    • **Follow-through** must be in the direction of travel
    • **Acceleration** through the ball creates more spin
    • **Cue elevation** affects spin retention (more elevation = more spin loss)
    • **Tip condition** impacts spin transfer efficiency
```

### 4.5 Section 5: How to Execute (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SECTION 5: HOW TO EXECUTE                               │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Step-by-step execution guide
    
    ─────────────────────────────────────────────────────────────────────────

    Prerequisites:
    ─────────────────────────────────────────────────────────────────────────
    • List any prerequisite knowledge/skills
    • Equipment requirements
    • Pre-shot checklist
    
    Step-by-Step Instructions:
    ─────────────────────────────────────────────────────────────────────────
    • Numbered steps (1, 2, 3...)
    • Clear, actionable instructions
    • Include stance, bridge, and stroke guidance
    • Minimum 5 steps, maximum 12 steps
    
    Common Variations:
    ─────────────────────────────────────────────────────────────────────────
    • Any common variations of the technique
    • When each variation is appropriate
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 5. How to Execute

    ### Prerequisites

    Before attempting a draw shot, you should:
    - Master the basic bridge hand
    - Understand cue ball contact points
    - Practice straight follow-through shots

    ### Step-by-Step Execution

    1. **Establish your stance** — Position yourself behind the line of 
       the shot with feet shoulder-width apart.

    2. **Form your bridge** — Create a stable open or closed bridge, 
       keeping your hand flat on the cloth.

    3. **Grip the cue** — Hold the cue near the end with light pressure, 
       allowing for a smooth pull-back motion.

    4. **Aim below center** — Place your cue tip approximately ½ tip 
       below the center of the cue ball.

    5. **Pull back smoothly** — Draw the cue straight back in line 
       with the shot direction.

    6. **Accelerate through** — Push the cue forward with increasing 
       speed, striking firmly through the ball.

    7. **Follow through** — Extend your bridge arm fully, maintaining 
       the low cue direction.

    ### Common Variations

    | Variation | When to Use | Tip Placement |
    |-----------|-------------|----------------|
    | Light Draw | Short distances | ½ tip below center |
    | Medium Draw | Medium distances | 1 tip below center |
    | Heavy Draw | Long distances | 1-2 tips below center |
```

### 4.6 Section 6: When & When Not to Use (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECTION 6: WHEN & WHEN NOT TO USE                          │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Practical application guidance
    
    ─────────────────────────────────────────────────────────────────────────

    When to Use:
    ─────────────────────────────────────────────────────────────────────────
    • Specific scenarios where this technique is ideal
    • Strategic advantages
    • Position play situations
    • Minimum 3 use cases
    
    When NOT to Use:
    ─────────────────────────────────────────────────────────────────────────
    • Situations where another technique is better
    • Risks and limitations
    • Common misapplications
    • Minimum 2 cautionary cases
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 6. When to Use & When Not to Use

    ### When to Use

    Use the draw shot in these situations:

    1. **Position Play Behind Object Ball**
       When you need the cue ball to come back toward you after pocketing 
       an object ball, the draw shot is essential.

    2. **Narrow Gaps**
       Draw allows you to navigate tight spaces between balls by bringing 
       the cue ball back through gaps after the initial shot.

    3. **Long Draws**
       For shots requiring the cue ball to travel backward significant 
       distances, draw is the primary control method.

    4. **Combos and Caroms**
       When setting up combination shots or bank combinations, draw 
       provides precise cue ball control.

    ### When Not to Use

    Avoid the draw shot in these situations:

    1. **Frozen Balls**
       When the cue ball is frozen to an object ball, draw can cause 
       miscues or unwanted cue ball movement.

    2. **Short, Soft Shots**
       For delicate shots near the pocket, the momentum of a draw can 
       cause over-travel or scratch.

    3. **High Speed Requirements**
       If you need maximum cue ball speed, draw reduces forward momentum 
       and is not the optimal choice.
```

### 4.7 Section 7: Common Mistakes & Corrections (Bắt Buộc)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  SECTION 7: COMMON MISTAKES & CORRECTIONS                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Help learners avoid and fix errors
    
    ─────────────────────────────────────────────────────────────────────────

    Common Mistakes:
    ─────────────────────────────────────────────────────────────────────────
    • List 3-5 frequent errors
    • Explain why each is wrong
    • Provide visual cues if helpful
    
    Corrections:
    ─────────────────────────────────────────────────────────────────────────
    • Specific fixes for each mistake
    • Practice drills if applicable
    • Troubleshooting guidance
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 7. Common Mistakes & Corrections

    ### Mistake 1: Scooping the Cue

    **Problem:** Lifting the cue tip instead of striking through causes 
    the cue ball to go airborne.

    **Why It's Wrong:** A scooping motion creates upward force, causing 
    the cue tip to hit the side of the ball or miss entirely.

    **Correction:**
    - Keep your cue on the same plane throughout the stroke
    - Practice with the cue tip touching the ball at address
    - Focus on pushing through, not pulling up

    ### Mistake 2: Incomplete Follow-Through

    **Problem:** Stopping the cue immediately after contact results in 
    minimal draw effect.

    **Why It's Wrong:** Backspin requires continued acceleration through 
    the ball. Abrupt stops don't transfer enough spin.

    **Correction:**
    - Extend your bridge arm fully after contact
    - Practice following through to table height
    - Visualize pushing the cue through the ball

    ### Mistake 3: Wrong Tip Placement

    **Problem:** Hitting too far below center creates excessive draw but 
    reduces accuracy and may cause miscues.

    **Why It's Wrong:** Extreme below-center contact reduces the sweet 
    spot contact area, increasing error margin.

    **Correction:**
    - Start with ½ tip below center
    - Gradually increase as skill improves
    - Prioritize accuracy over power
```

### 4.8 Section 8: Professional Tips (Optional but Recommended)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SECTION 8: PROFESSIONAL TIPS                            │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Advanced insights from experts
    
    ─────────────────────────────────────────────────────────────────────────

    Expert Insights:
    ─────────────────────────────────────────────────────────────────────────
    • Pro-level techniques
    • Tournament-proven strategies
    • Mental approach
    • Equipment considerations
    
    Advanced Variations:
    ─────────────────────────────────────────────────────────────────────────
    • Elite-level techniques
    • Competition-specific applications
    • Specialty uses
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## 8. Professional Tips

    ### Pro Insights

    **On Timing:**
    > "The draw shot is 80% feel and 20% mechanics. You can have perfect 
    technique but if you don't commit to the stroke, the ball won't respond."
    > — Shane Warne, Australian Snooker Champion

    **On Practice:**
    > "I practice draw shots from every angle. It's not about the straight 
    shot — it's about understanding how draw works off rails and cushions."
    > — Ronnie O'Sullivan, 7-time World Champion

    ### Advanced Techniques

    1. **Double Draw** — Layering multiple draw applications for extreme 
       cue ball control (requires exceptional touch)

    2. **Draw with English** — Combining draw with side spin for complex 
       position scenarios

    3. **Draw Off the Rail** — Using rail contact to enhance or modify 
       draw effect (advanced cushion play)

    ### Equipment Considerations

    - **Tip Hardness:** Harder tips (like phenolic) generate more spin 
      but require precise contact
    - **Shaft Stiffness:** Stiffer shafts transfer more energy, beneficial 
      for heavy draw
    - **Cloth Speed:** Faster cloths reduce the distance draw travels
```

---

## 5. Back Matter

### 5.1 Related Terms

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RELATED TERMS                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Connect related concepts
    
    ─────────────────────────────────────────────────────────────────────────

    Related Terms:
    ─────────────────────────────────────────────────────────────────────────
    • List 3-10 related article IDs
    • Include relationship type (prerequisite, similar, contrast, advanced)
    • Recommended Next: Suggest logical follow-up learning
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## Related Terms

    ### Prerequisites
    - [Stop Shot](./stopshot.md) — TERM-000010
    - [Follow Shot](./followshot.md) — TERM-000011
    - [Basic Bridge](./basic-bridge.md) — TERM-000020

    ### Similar Concepts
    - [Screw Shot](./screw-shot.md) — TERM-000012 (same technique, different name)
    - [Pull Shot](./pull-shot.md) — TERM-000013 (same technique, different name)

    ### Advanced Topics
    - [English with Draw](./english-draw.md) — TERM-000050
    - [Double Draw](./double-draw.md) — TERM-000051

    ### Recommended Next
    - [Follow Shot](./followshot.md) — TERM-000011
```

### 5.2 Media Attachments

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MEDIA ATTACHMENTS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Provide visual/demonstration content
    
    ─────────────────────────────────────────────────────────────────────────

    Media Types:
    ─────────────────────────────────────────────────────────────────────────
    • Images: diagrams, cue positions, contact points
    • Videos: demonstration clips (optional)
    • Diagrams: visual representations
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## Media

    ### Contact Point Diagram
    [IMAGE: draw-shot-contact-points.png]

    ### Execution Sequence
    [IMAGE: draw-shot-sequence-1.webp]
    [IMAGE: draw-shot-sequence-2.webp]
    [IMAGE: draw-shot-sequence-3.webp]

    ### Common Error Demonstration
    [IMAGE: draw-shot-scooping-error.webp]

    ### Video (Optional)
    [VIDEO: draw-shot-demonstration.mp4]
```

### 5.3 Source & References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SOURCE & REFERENCES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Cite information sources
    
    ─────────────────────────────────────────────────────────────────────────

    Sources:
    ─────────────────────────────────────────────────────────────────────────
    • Books and publications
    • Expert consultations
    • Video references
    • Research papers
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## Sources & References

    ### Books
    - *The 99 Critical Shots in Pool* by Ray Martin
    - *Play Your Best Pool* by Phil Capelle
    - *Advanced Pool* by Robert Byrne

    ### Videos
    - "How to Master the Draw Shot" — Dr. Dave Alciato
    - "Draw Shot Essentials" — Ronnie O'Sullivan Training

    ### Expert Review
    - Reviewed by: [Coach Name], [Certification]
    - Last reviewed: 2026-07-15
```

### 5.4 Changelog

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CHANGELOG                                          │
└─────────────────────────────────────────────────────────────────────────────┘

    Purpose: Track article history
    
    ─────────────────────────────────────────────────────────────────────────

    Changelog Format:
    ─────────────────────────────────────────────────────────────────────────
    • Version number
    • Date
    • Author
    • Changes made
    
    ─────────────────────────────────────────────────────────────────────────

    Structure:
    ─────────────────────────────────────────────────────────────────────────

    ## Changelog

    | Version | Date | Author | Changes |
    |---------|------|--------|---------|
    | 1.0.0 | 2026-07-17 | Content Team | Initial publication |
    | 0.1.0 | 2026-07-10 | Content Team | Draft created |
```

---

## 6. Complete Article Template

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          COMPLETE TEMPLATE                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ---
    id: TERM-XXXXXX
    slug: article-slug
    category: CAT-XXXXXX
    difficulty: beginner | intermediate | advanced | professional
    status: draft | review | published | deprecated
    version: 1.0.0
    created: YYYY-MM-DD
    updated: YYYY-MM-DD
    tags: [tag1, tag2, tag3]
    priority: 1 | 2 | 3 | 4
    languages: [en, vi]
    ---

    # [English Name]

    ## 1. Names

    ### English
    [Name]

    ### Vietnamese
    [Tên]

    ### Pronunciation (Optional)
    EN: [IPA]
    VI: [IPA]

    ## 2. Quick Summary

    **English:** [30-150 characters]

    **Vietnamese:** [30-150 characters]

    ## 3. Definition

    ### English

    [Markdown content, 200-2000 characters]

    ### Vietnamese

    [Markdown content, 200-2000 characters]

    ## 4. Detailed Content

    ### 4.1 What Is [Term]?

    [Content]

    ### 4.2 How It Works

    [Content]

    ### 4.3 Key Principles

    • **Principle 1:** [Description]
    • **Principle 2:** [Description]
    • **Principle 3:** [Description]

    ## 5. How to Execute

    ### Prerequisites

    - [Prerequisite 1]
    - [Prerequisite 2]

    ### Step-by-Step Execution

    1. [Step 1]
    2. [Step 2]
    3. [Step 3]
    4. [Step 4]
    5. [Step 5]
    6. [Step 6]
    7. [Step 7]

    ### Common Variations

    | Variation | When to Use | Tip Placement |
    |-----------|-------------|----------------|
    | [Name] | [Use case] | [Contact point] |

    ## 6. When to Use & When Not to Use

    ### When to Use

    1. **[Situation]:** [Description]
    2. **[Situation]:** [Description]
    3. **[Situation]:** [Description]

    ### When Not to Use

    1. **[Situation]:** [Description]
    2. **[Situation]:** [Description]

    ## 7. Common Mistakes & Corrections

    ### Mistake 1: [Error Name]

    **Problem:** [Description]

    **Why It's Wrong:** [Explanation]

    **Correction:** [Fix]

    ## 8. Professional Tips

    ### Pro Insights

    > "[Quote]"
    > — [Expert Name]

    ### Advanced Techniques

    - **[Technique]:** [Description]

    ### Equipment Considerations

    - **[Point]:** [Description]

    ## Related Terms

    ### Prerequisites
    - [Term](./slug.md) — TERM-XXXXXX

    ### Similar Concepts
    - [Term](./slug.md) — TERM-XXXXXX

    ### Recommended Next
    - [Term](./slug.md) — TERM-XXXXXX

    ## Media

    [IMAGE: media-description.png]
    [VIDEO: video-description.mp4] (Optional)

    ## Sources & References

    ### Books
    - *[Title]* by [Author]

    ### Videos
    - "[Video Title]" — [Creator]

    ### Expert Review
    - Reviewed by: [Name]
    - Last reviewed: YYYY-MM-DD

    ## Changelog

    | Version | Date | Author | Changes |
    |---------|------|--------|---------|
    | 1.0.0 | YYYY-MM-DD | Author | Initial publication |
```

---

## 7. Section Requirements Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECTION REQUIREMENTS SUMMARY                               │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Section                   │ Required │ Min    │ Max    │ Languages│
    │   ─────────────────────────┼──────────┼────────┼────────┼───────────│
    │                                                                      │
    │   FRONT MATTER                                                   │
    │   ─────────────────────────────────────────────────────────────────  │
    │   Metadata                  │    YES   │   -    │   -    │     -     │
    │   Classification           │    YES   │   -    │   -    │     -     │
    │                                                                      │
    │   CONTENT CORE                                                  │
    │   ─────────────────────────────────────────────────────────────────  │
    │   1. Names                   │    YES   │   1ch  │  500ch │   EN+VI   │
    │   2. Quick Summary          │    YES   │  30ch  │  150ch │   EN+VI   │
    │   3. Definition             │    YES   │ 200ch  │ 2000ch │   EN+VI   │
    │   4. Detailed Content       │    YES   │   -    │   -    │   EN+VI   │
    │   5. How to Execute         │    YES   │ 5 step │ 12 step│   EN+VI   │
    │   6. When/Not to Use       │    YES   │ 3 uses │   -    │   EN+VI   │
    │   7. Mistakes & Corrections│    YES   │ 3 mist │   -    │   EN+VI   │
    │   8. Professional Tips      │  RECOMM  │   -    │   -    │   EN+VI   │
    │                                                                      │
    │   BACK MATTER                                                    │
    │   ─────────────────────────────────────────────────────────────────  │
    │   Related Terms             │  RECOMM  │   3    │   10   │     -     │
    │   Media                     │  RECOMM  │   -    │   -    │     -     │
    │   Sources                  │  RECOMM  │   -    │   -    │     -     │
    │   Changelog                │    YES   │   1    │   -    │     -     │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Formatting Standards

### 8.1 Markdown Usage

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MARKDOWN STANDARDS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Headings:
    ─────────────────────────────────────────────────────────────────────────
    • Use ATX style (# Heading)
    • H1 = Article Title (single)
    • H2 = Major sections
    • H3 = Subsections
    • H4 = Sub-subsections (use sparingly)
    
    Lists:
    ─────────────────────────────────────────────────────────────────────────
    • Use dashes for unordered lists
    • Use numbers for ordered lists
    • Maximum nesting: 2 levels
    • Keep items concise
    
    Emphasis:
    ─────────────────────────────────────────────────────────────────────────
    • **Bold** for key terms and importance
    • *Italic* for subtle emphasis
    • `Code` for technical terms
    
    Tables:
    ─────────────────────────────────────────────────────────────────────────
    • Use when comparing 2+ items
    • Always include headers
    • Align columns consistently
    
    Code Blocks:
    ─────────────────────────────────────────────────────────────────────────
    • Use for technical examples
    • Specify language when applicable
```

### 8.2 Writing Style

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WRITING STYLE                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Voice:
    ─────────────────────────────────────────────────────────────────────────
    • Second person ("you") for instructions
    • Active voice preferred
    • Clear and direct
    
    Tone:
    ─────────────────────────────────────────────────────────────────────────
    • Professional but approachable
    • Educational and supportive
    • Confident without being dogmatic
    
    Sentence Structure:
    ─────────────────────────────────────────────────────────────────────────
    • Average: 15-20 words
    • Maximum: 40 words
    • Avoid run-on sentences
    • One idea per sentence (mostly)
    
    Technical Terms:
    ─────────────────────────────────────────────────────────────────────────
    • Define on first use
    • Use consistently
    • Include Vietnamese translation for key terms
```

---

## 9. Related Documents

- [Term Schema](./term_schema.md)
- [Validation Rules](./validation_rules.md)
- [Category Tree](./category_tree.md)
- [Content Workflow](./12_Content_Workflow.md)

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial article specification |

---

**Standard Owner:** Content Team
**Next Review:** Monthly during content development
