# BKM - Reference Standards

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document establishes standards for all references used in the BKM Knowledge Base. Consistent reference standards ensure verifiability, proper attribution, and reliable information sourcing.

---

## 2. Reference Purpose Classification

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         REFERENCE PURPOSE TYPES                              │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Purpose              │ Description                                │
    │   ─────────────────────┼─────────────────────────────────────────   │
    │   Authority Source    │ Official rules, standards, governing bodies│
    │   Learning Resource   │ Books, courses, educational materials       │
    │   Technical Source    │ Equipment specs, manufacturer information   │
    │   Expert Source       │ Professional coaches, recognized experts    │
    │   Visual Reference    │ Videos, demonstrations, tutorials           │
    │   Historical Source   │ Archives, records, documented history      │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Universal Metadata Requirements

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       UNIVERSAL METADATA FIELDS                              │
└─────────────────────────────────────────────────────────────────────────────┘

    Every reference MUST include the following metadata:

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Required │ Description                        │
    │   ──────────────────┼──────────┼───────────────────────────────────  │
    │   reference_id      │ YES      │ Unique identifier                    │
    │   reference_type    │ YES      │ Category of reference                │
    │   title            │ YES      │ Official title of source             │
    │   author_creator   │ YES      │ Author, creator, or publisher        │
    │   publication_date │ YES      │ Date of release/publication          │
    │   access_date      │ YES      │ When BKM accessed this source        │
    │   url              │ YES*     │ Web link (if applicable)            │
    │   isbn_issn        │ YES*     │ ISBN/ISSN (for books/journals)       │
    │   verification_status│ YES    │ Verified, unverified, expired        │
    │   relevance_score  │ YES      │ 1-5 rating for BKM relevance        │
    │   last_verified    │ YES      │ Last verification date               │
    │                                                                      │
    │   * Required when applicable                                         │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    VERIFICATION STATUS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Status            │ Meaning                                      │
    │   ─────────────────┼─────────────────────────────────────────────   │
    │   Verified         │ Content confirmed accurate and current        │
    │   Unverified       │ Not yet checked by content team              │
    │   Expired          │ Link broken or content outdated               │
    │   Disputed         │ Accuracy questioned, flagged for review        │
    │   Superseded       │ Newer version available                       │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    RELEVANCE SCORE
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Score │ Description                                              │
    │   ─────┼─────────────────────────────────────────────────────────── │
    │   5     │ Primary source, directly on topic                        │
    │   4     │ Highly relevant, useful supplementary                   │
    │   3     │ Relevant with some tangential content                   │
    │   2     │ Minor relevance, specific details                       │
    │   1     │ Minimal relevance, historical context                    │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 4. Book References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            BOOK REFERENCES                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Books provide foundational knowledge, expert techniques, and 
    authoritative instruction from recognized billiards authorities.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-{type}-{number} (e.g., BKM-BK-001)        │
    │   reference_type   │ book                                           │
    │   title            │ Full book title                                │
    │   subtitle         │ Subtitle if applicable                         │
    │   author_creator   │ Author(s) full name(s)                         │
    │   author_bio       │ Brief author credentials                        │
    │   edition          │ Edition number                                  │
    │   publisher        │ Publishing company                              │
    │   publication_date │ Publication date (YYYY-MM-DD)                    │
    │   isbn            │ ISBN-13 (required)                              │
    │   isbn_10         │ ISBN-10 (optional)                              │
    │   page_count      │ Total pages                                     │
    │   language        │ Primary language                                │
    │   dimensions      │ Book dimensions (optional)                      │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ADDITIONAL METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   series            │ Series name and volume (if applicable)         │
    │   binding           │ Hardcover, paperback, ebook                    │
    │   table_of_contents │ Chapter listing                                │
    │   awards           │ Awards or recognition received                  │
    │   reviews          │ Notable review citations                        │
    │   related_works   │ Previous editions, related books                │
    │   Vietnamese_title │ Local translation title (if available)          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Full Citation:
    ─────────────────────────────────────────────────────────────────────────
    {Author Last}, {First Initial}. ({Year}). 
    {Title}: {Subtitle}. {Edition} ed. {Publisher}.

    Example:
    Shamos, M. I. (1999). 
    The Illustrated Encyclopedia of Billiards. 
    1st ed. Lyons Press.

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (Shamos, 1999) or Shamos (1999)

    ─────────────────────────────────────────────────────────────────────────

    QUALITY CRITERIA
    ─────────────────────────────────────────────────────────────────────────

    Preferred Books:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Written by recognized authorities
    ✓ Published by established publishers
    ✓ Peer-reviewed or endorsed by associations
    ✓ Multiple editions (established value)
    ✓ Cited by other reputable sources

    Avoid:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Self-published without credentials
    ✗ Outdated editions (superseded available)
    ✗ Content contradicted by current standards
    ✗ Author unknown or unverified credentials
```

### 4.1 Recommended Book Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       BOOK CATEGORY STANDARDS                                │
└─────────────────────────────────────────────────────────────────────────────┘

    TECHNICAL INSTRUCTION
    ─────────────────────────────────────────────────────────────────────────
    Focus: Technique, mechanics, shot-making

    Examples: "The 99 Critical Shots in Pool", "Play Your Best Pool"

    Required Author Credentials:
    • Professional player or coach
    • Recognized by governing bodies
    • Published teaching career

    ─────────────────────────────────────────────────────────────────────────

    STRATEGY & TACTICS
    ─────────────────────────────────────────────────────────────────────────
    Focus: Game strategy, position play, match play

    Examples: "The Player's Billiards Bible", "Pool Strategy"

    Required Author Credentials:
    • Tournament champion or coach
    • Published strategy articles
    • Demonstrated expertise

    ─────────────────────────────────────────────────────────────────────────

    HISTORY & CULTURE
    ─────────────────────────────────────────────────────────────────────────
    Focus: History, legends, organizational

    Examples: "Billiards: The Good Old Days", "Pool Hall Hall of Fame"

    Required Author Credentials:
    • Historian or documented researcher
    • Primary source access
    • Editorial oversight

    ─────────────────────────────────────────────────────────────────────────

    EQUIPMENT & SCIENCE
    ─────────────────────────────────────────────────────────────────────────
    Focus: Physics, equipment, technical specifications

    Examples: "The Science of Billiards", equipment manufacturer guides

    Required Author Credentials:
    • Scientific background
    • Equipment expertise
    • Technical accuracy verified
```

---

## 5. WPA Rules References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WPA RULES REFERENCES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    The World Pool-Billiard Association (WPA) rules serve as the 
    authoritative source for official competition regulations.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-WPA-{number}                           │
    │   reference_type   │ official-rules                                 │
    │   title            │ Official Rules of [Game Type]                  │
    │   author_creator   │ World Pool-Billiard Association                 │
    │   version          │ Rule version (e.g., "2022 Edition")            │
    │   publication_date │ Effective date (YYYY-MM-DD)                    │
    │   access_date      │ When accessed by BKM                           │
    │   url             │ Official WPA website URL                        │
    │   languages       │ Available translations                           │
    │   game_types      │ Games covered (8-ball, 9-ball, etc.)            │
    │   jurisdiction    │ International or regional variant               │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Full Citation:
    ─────────────────────────────────────────────────────────────────────────
    World Pool-Billiard Association. ({Year}). 
    Official Rules of [Game Type]. 
    Retrieved from https://www.wpa-pool.com

    Example:
    World Pool-Billiard Association. (2022). 
    Official Rules of Eight-Ball. 
    Retrieved from https://www.wpa-pool.com

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (WPA, 2022) or WPA Rules (2022)

    Rule-Specific:
    ─────────────────────────────────────────────────────────────────────────
    "According to WPA Rule 3.1(a)..." (WPA, 2022)

    ─────────────────────────────────────────────────────────────────────────

    VERIFICATION REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────

    Verify:
    ─────────────────────────────────────────────────────────────────────────
    □ Current version being used
    □ Official WPA source URL
    □ Translation accuracy (if not English)
    □ Regional rule variations noted
    □ Recent updates documented

    ─────────────────────────────────────────────────────────────────────────

    RULE REFERENCE STRUCTURE
    ─────────────────────────────────────────────────────────────────────────

    When referencing specific rules:

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Element          │ Format                                           │
    │   ────────────────┼─────────────────────────────────────────────    │
    │   Rule number     │ Section.Subsection (e.g., 3.1)                   │
    │   Rule title      │ Descriptive title of rule                        │
    │   Full text       │ Exact wording from official source               │
    │   Interpretation  │ BKM explanation if needed                        │
    │   Examples        │ Practical applications                           │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    COMMON WPA RULE CATEGORIES
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Game           │ Rule Book                                       │
    │   ──────────────┼───────────────────────────────────────────────   │
    │   8-Ball        │ WPA 8-Ball Rules                                │
    │   9-Ball        │ WPA 9-Ball Rules                                │
    │   10-Ball       │ WPA 10-Ball Rules                              │
    │   Straight Pool  │ WPA 14.1 Continuous Rules                       │
    │   One-Pocket    │ WPA One-Pocket Rules                            │
    │   Banks          │ WPA Banks Pool Rules                             │
    │   Snooker       │ World Professional Billiards and Snooker Assoc.  │
    │   Carom         │ Union Mondiale de Billard                        │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Official Document References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      OFFICIAL DOCUMENT REFERENCES                           │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Official documents include governing body publications, 
    tournament regulations, and organizational standards.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-{BODY}-{number}                        │
    │   reference_type   │ official-document                               │
    │   title            │ Document title                                 │
    │   author_creator   │ Issuing organization                            │
    │   document_type   │ Regulation, guideline, standard, report          │
    │   publication_date │ Issue date (YYYY-MM-DD)                        │
    │   effective_date  │ When effective (if different)                  │
    │   expiration_date │ Expiration date (if applicable)                 │
    │   access_date      │ When BKM accessed                              │
    │   url             │ Official source URL                             │
    │   scope           │ International, regional, national               │
    │   jurisdiction    │ Governing bodies covered                        │
    │   status         │ Current, superseded, draft                      │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    DOCUMENT TYPES
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Type            │ Description                                      │
    │   ───────────────┼───────────────────────────────────────────────    │
    │   Regulation     │ Binding rules and requirements                    │
    │   Guideline      │ Recommended practices                            │
    │   Standard       │ Technical or quality specifications               │
    │   Report         │ Research, analysis, findings                      │
    │   Handbook       │ Comprehensive guidance                           │
    │   Policy         │ Organizational rules                             │
    │   Technical Spec │ Equipment or technical specifications             │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Full Citation:
    ─────────────────────────────────────────────────────────────────────────
    {Organization}. ({Year}). {Title}. 
    {Organization URL}/path/to/document

    Example:
    Billiards Congress of America. (2021). 
    BCA Pool League Official Rules. 
    https://www.bca-pool.com/rules

    ─────────────────────────────────────────────────────────────────────────

    COMMON OFFICIAL SOURCES
    ─────────────────────────────────────────────────────────────────────────

    Governing Bodies:
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Organization             │ Abbreviation │ Scope                    │
    │   ────────────────────────┼──────────────┼──────────────────────────  │
    │   World Pool-Billiard     │ WPA          │ International            │
    │   Association            │              │                          │
    │   Billiards Congress     │ BCA          │ United States            │
    │   of America             │              │                          │
    │   European Pocket         │ EPBF         │ Europe                  │
    │   Biljart Federation      │              │                          │
    │   World Professional     │ WPBSA        │ Professional/Snooker     │
    │   Billiards and Snooker   │              │                          │
    │   Association            │              │                          │
    │   Union Mondiale         │ UMB          │ Carom/International     │
    │   de Billard             │              │                          │
    │   Asian Pocket Billiard  │ APBU         │ Asia                    │
    │   Union                  │              │                          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    VERIFICATION REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────

    For Official Documents:
    ─────────────────────────────────────────────────────────────────────────
    □ Verify issuing organization authority
    □ Confirm document is current version
    □ Check for newer editions
    □ Note any regional variations
    □ Document any amendments
```

---

## 7. Professional Coach References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COACH REFERENCES                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Professional coaches provide expert instruction, 
    training methodologies, and practical guidance.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-COA-{number}                           │
    │   reference_type   │ coach-reference                                 │
    │   coach_name        │ Full name                                     │
    │   coach_title       │ Title(s) and credentials                       │
    │   specialization   │ Primary coaching focus                         │
    │   certifications   │ Official certifications held                    │
    │   affiliations     │ Organizations they represent                     │
    │   contact          │ Professional contact (website/social)            │
    │   content_types   │ Videos, courses, books authored                 │
    │   years_active     │ Years of coaching experience                    │
    │   notable_students │ Notable students/players coached                  │
    │   access_date      │ When BKM verified information                  │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    COACH CREDENTIAL CATEGORIES
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Category          │ Description                                      │
    │   ─────────────────┼─────────────────────────────────────────────    │
    │   Player- Coach    │ Former professional player turned coach          │
    │   Certified        │ Certified by governing body                     │
    │   Academic         │ Sports science background                        │
    │   Institution      │ Associated with academy/training facility        │
    │   Online Educator  │ Primarily online content creator                │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Named Coach Content:
    ─────────────────────────────────────────────────────────────────────────
    {Coach Name}, {Credentials}. ({Year}). 
    "{Content Title}" [Content Type]. 
    Retrieved from {URL}

    Example:
    Lars Kunting, WPA Master Coach. (2023). 
    "Advanced English Control" [Video Tutorial]. 
    Retrieved from https://example.com/tutorials

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (Kunting, 2023) or "According to Lars Kunting..." (2023)

    ─────────────────────────────────────────────────────────────────────────

    QUALITY CRITERIA
    ─────────────────────────────────────────────────────────────────────────

    Preferred Coaches:
    ─────────────────────────────────────────────────────────────────────────
    ✓ WPA or governing body certified
    ✓ Professional playing career
    ✓ Published educational content
    ✓ Recognized by multiple sources
    ✓ Active teaching presence

    Consider with Verification:
    ─────────────────────────────────────────────────────────────────────────
    • Online instructors without certifications
    • Regional coaches with limited reach
    • Newer content creators

    ─────────────────────────────────────────────────────────────────────────

    COACH DIRECTORY STRUCTURE
    ─────────────────────────────────────────────────────────────────────────

    BKM Coach Reference Database Fields:
    ─────────────────────────────────────────────────────────────────────────
    • Coach ID
    • Name and credentials
    • Specialization areas
    • Teaching style
    • Content availability
    • Geographic coverage
    • Language capability
    • Rating/reputation score
    • Last content update
```

---

## 8. Manufacturer References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       MANUFACTURER REFERENCES                                │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Manufacturers provide equipment specifications, 
    product information, and technical documentation.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-MFG-{number}                           │
    │   reference_type   │ manufacturer                                    │
    │   manufacturer_name│ Company name                                    │
    │   product_name     │ Product name (for specific refs)                │
    │   product_category│ Cue, table, accessory, etc.                      │
    │   model_number    │ Official model/SKU number                       │
    │   specifications  │ Technical specifications                         │
    │   release_date    │ Product launch date                             │
    │   availability   │ Current, discontinued, limited                    │
    │   official_website│ Manufacturer URL                               │
    │   contact_info   │ Official support contact                         │
    │   country_origin │ Manufacturing country                            │
    │   access_date      │ When BKM accessed                              │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    SPECIFICATION REFERENCE STRUCTURE
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Product Category │ Common Specifications                            │
    │   ─────────────────┼─────────────────────────────────────────────    │
    │   Cue             │ Length, weight, balance, shaft material          │
    │   Table           │ Size, pocket size, slate, cushion type          │
    │   Ball            │ Diameter, weight, material, Aramith-certified     │
    │   Chalk           │ Type, color options                             │
    │   Tip             │ Hardness, size, brand                           │
    │   Glove           │ Size options, material                          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Product Specification:
    ─────────────────────────────────────────────────────────────────────────
    {Manufacturer}. ({Year}). {Product Name} 
    [{Model Number}]. Retrieved from {Official URL}

    Example:
    Predator Group. (2024). 
    Predator 314/3 Shaft [Product Spec]. 
    Retrieved from https://predatorcue.com

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (Predator Group, 2024) or "According to Predator..." (2024)

    ─────────────────────────────────────────────────────────────────────────

    MAJOR MANUFACTURER CATEGORIES
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Category      │ Major Brands                                      │
    │   ─────────────┼───────────────────────────────────────────────     │
    │   Cues         │ Predator, Meucci, OB, Pechauer, Viking            │
    │   Tables       │ Brunswick, Diamond, Olhausen, Legacy              │
    │   Balls        │ Aramith, Saluc, Brunswick                        │
    │   Tips         │ Kamui, Triangle, Moori, Le Professional         │
    │   Chalk        │ Master, Kamui, Silver Cup, Predator               │
    │   Accessories  │ various                                           │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    VERIFICATION REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────

    For Manufacturer References:
    ─────────────────────────────────────────────────────────────────────────
    □ Source is official manufacturer website
    □ Product model number matches
    □ Specifications are current
    □ Discontinued products noted
    □ Regional variations documented
```

---

## 9. Website References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          WEBSITE REFERENCES                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Websites provide current information, community resources, 
    news, and diverse billiards content.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-WEB-{number}                           │
    │   reference_type   │ website                                        │
    │   site_name         │ Website/publication name                       │
    │   page_title       │ Specific page title                            │
    │   author_creator   │ Author or content creator                      │
    │   publication_date │ Content publish date                           │
    │   last_modified    │ Last update date                               │
    │   access_date      │ When BKM accessed                              │
    │   url             │ Full URL                                       │
    │   domain_owner    │ Domain registrant (if known)                   │
    │   content_type    │ Article, video, forum, wiki, tool              │
    │   editorial_review │ Peer-reviewed, edited, user-generated          │
    │   reliability_score│ 1-5 based on source quality                    │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    RELIABILITY SCORING
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Score │ Source Type              │ Verification                  │
    │   ─────┼──────────────────────────┼─────────────────────────────  │
    │   5     │ Official organization    │ Primary source, authoritative│
    │   4     │ Established publication  │ Editorial review, expert     │
    │   3     │ Quality content creator │ Known credentials            │
    │   2     │ General content          │ Some verification needed     │
    │   1     │ User-generated/forums    │ Use with caution             │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Full Citation:
    ─────────────────────────────────────────────────────────────────────────
    {Author}. ({Year, Month Day}). {Page Title}. 
    {Site Name}. Retrieved from {URL}

    Example:
    Mosconi, F. (2024, March 15). 
    The Physics of English. AZBilliards. 
    Retrieved from https://azbilliards.com/physics-english

    Author Unknown:
    ─────────────────────────────────────────────────────────────────────────
    {Site Name}. ({Year, Month Day}). {Page Title}. 
    Retrieved from {URL}

    Example:
    AZBilliards. (2024, February 20). 
    Equipment Guide: Choosing Your First Pool Cue. 
    Retrieved from https://azbilliards.com/equipment-guide

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (Mosconi, 2024) or (AZBilliards, 2024)

    ─────────────────────────────────────────────────────────────────────────

    ACCESS DATE REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────
    Required for websites because content can change.

    Format: Retrieved Month Day, Year, from URL

    Example:
    Retrieved July 17, 2026, from https://example.com/page

    ─────────────────────────────────────────────────────────────────────────

    WEBSITE QUALITY CHECKLIST
    ─────────────────────────────────────────────────────────────────────────

    High-Quality Websites:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Official governing body sites
    ✓ Established billiards publications
    ✓ Professional player/coach sites
    ✓ Recognized training academies
    ✓ Major equipment manufacturer sites

    Use with Caution:
    ─────────────────────────────────────────────────────────────────────────
    • Unmoderated forums
    • Personal blogs
    • Social media posts
    • User-edited wikis
    • Unknown vendor sites

    Avoid:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Sites with unverified claims
    ✗ Content contradicted by official sources
    ✗ Sites without clear authorship
    ✗ Dead links or redirect chains
```

### 9.1 Recommended Website Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      WEBSITE CATEGORY STANDARDS                             │
└─────────────────────────────────────────────────────────────────────────────┘

    NEWS & PUBLICATIONS
    ─────────────────────────────────────────────────────────────────────────
    AZBilliards, Billiards Digest, Inside Pool Magazine

    Verification: High - Established publications with editorial oversight

    FORUMS & COMMUNITIES
    ─────────────────────────────────────────────────────────────────────────
    AZBilliards Forums, Billiard World forums

    Verification: Medium - Community knowledge, verify claims

    ACADEMIES & TRAINING
    ─────────────────────────────────────────────────────────────────────────
    BCA Academy, Regional training centers

    Verification: High - Official organizations

    GOVERNMENT/ORGANIZATION
    ─────────────────────────────────────────────────────────────────────────
    WPA, BCA, Regional associations

    Verification: Highest - Primary authoritative source
```

---

## 10. Video References

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           VIDEO REFERENCES                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Videos provide visual instruction, demonstrations, and 
    expert commentary on billiards techniques.

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED METADATA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-RU-VID-{number}                           │
    │   reference_type   │ video-reference                                │
    │   title            │ Video title                                    │
    │   creator         │ Channel/person name                             │
    │   creator_credentials│ Professional background                       │
    │   platform        │ YouTube, Vimeo, etc.                            │
    │   publication_date │ Upload date (YYYY-MM-DD)                       │
    │   duration        │ Video length (HH:MM:SS)                        │
    │   url             │ Full video URL                                  │
    │   thumbnail_url   │ Video thumbnail image URL                       │
    │   view_count     │ Views at time of reference                      │
    │   like_count     │ Likes at time of reference                       │
    │   channel_subscribers│ Subscriber count                             │
    │   content_type   │ Tutorial, demonstration, analysis, interview    │
    │   difficulty_level│ Beginner, intermediate, advanced               │
    │   access_date      │ When BKM accessed                              │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    CITATION FORMAT
    ─────────────────────────────────────────────────────────────────────────

    Full Citation:
    ─────────────────────────────────────────────────────────────────────────
    {Creator}. ({Year}). {Video Title} [Video]. 
    {Platform}. Retrieved from {URL}

    Example:
    Eddie Taylor. (2023). 
    Master the Draw Shot: Complete Tutorial [Video]. 
    YouTube. Retrieved from https://youtube.com/watch?v=example

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION
    ─────────────────────────────────────────────────────────────────────────
    (Eddie Taylor, 2023) or "Eddie Taylor demonstrates..." (2023)

    Timestamp Citation:
    ─────────────────────────────────────────────────────────────────────────
    (Eddie Taylor, 2023, 5:32) or Eddie Taylor (2023, 5:32)

    ─────────────────────────────────────────────────────────────────────────

    CREATOR CREDENTIAL VERIFICATION
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Credential Type      │ Verification                              │
    │   ─────────────────────┼─────────────────────────────────────────   │
    │   Professional player  │ Tournament wins, rankings                 │
    │   Certified coach      │ WPA or governing body certification       │
    │   Equipment expert     │ Industry recognition, brand affiliation   │
    │   Historical content   │ Archive authenticity                      │
    │   General content      │ Channel reputation, other sources         │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    VIDEO QUALITY INDICATORS
    ─────────────────────────────────────────────────────────────────────────

    High-Quality Videos:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Established channels (100K+ subscribers)
    ✓ Professional/coach creators
    ✓ High view counts relative to age
    ✓ Positive engagement ratios
    ✓ Multiple verification points

    Content Indicators:
    ─────────────────────────────────────────────────────────────────────────
    • Technical accuracy
    • Production quality
    • Up-to-date information
    • Clear explanation
    • Demonstrated expertise
```

---

## 11. Reference Database Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      REFERENCE DATABASE STRUCTURE                            │
└─────────────────────────────────────────────────────────────────────────────┘

    MASTER REFERENCE RECORD
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   reference_id      │ BKM-{TYPE}-{NUMBER}                           │
    │   reference_type   │ book | rules | document | coach |              │
    │                    │ manufacturer | website | video                 │
    │   title            │ Official title                                 │
    │   author_creator   │ Author/creator/organization                     │
    │   publication_date │ Date of creation/release                       │
    │   access_date      │ When BKM accessed source                       │
    │   url             │ Web link (if applicable)                        │
    │   verification_status│ verified | unverified | expired | disputed  │
    │   relevance_score │ 1-5                                            │
    │   last_verified    │ Date of last verification                      │
    │   type_specific_data│ JSON of type-specific fields                  │
    │   usage_count     │ Times referenced in BKM content                │
    │   related_references│ IDs of related references                     │
    │   created_date    │ When added to BKM database                     │
    │   updated_date    │ Last modification                               │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    RELATIONSHIP MANAGEMENT
    ─────────────────────────────────────────────────────────────────────────

    References can relate to:

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Relationship Type │ Description                                    │
    │   ─────────────────┼─────────────────────────────────────────────   │
    │   supersedes       │ Newer version replaces this                    │
    │   related          │ Same topic, different source                   │
    │   cites           │ This reference cites another                     │
    │   contradicted_by │ Opposing or corrected by another                │
    │   supplement_to   │ Additional content to main reference            │
    │   translates      │ Translation of another reference                │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    USAGE TRACKING
    ─────────────────────────────────────────────────────────────────────────

    Track how references are used:
    ─────────────────────────────────────────────────────────────────────────
    • Article ID where cited
    • Citation context
    • Quote or paraphrase reference
    • Verification status at time of use
    • Last article verification
```

---

## 12. Citation Standards Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CITATION FORMAT QUICK REFERENCE                            │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Type          │ Format                                           │
    │   ─────────────┼─────────────────────────────────────────────────  │
    │   Book         │ Author. (Year). Title. Publisher.                 │
    │   WPA Rules    │ WPA. (Year). Game Rules. Retrieved from URL        │
    │   Document     │ Organization. (Year). Title. URL                   │
    │   Coach        │ Coach Name, Credentials. (Year). Content. URL     │
    │   Manufacturer │ Company. (Year). Product. Retrieved from URL       │
    │   Website      │ Author. (Date). Title. Site. Retrieved from URL   │
    │   Video        │ Creator. (Year). Title [Video]. Platform. URL     │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    IN-TEXT CITATION STYLES
    ─────────────────────────────────────────────────────────────────────────

    Single Author:
    (Shamos, 1999)

    Multiple Authors:
    (Shamos & Smith, 2001)
    (Shamos, Smith, & Jones, 2003)

    Organization:
    (WPA, 2022)
    (Billiards Congress of America, 2021)

    Direct Quote:
    (Shamos, 1999, p. 45)

    Timestamp:
    (Eddie Taylor, 2023, 5:32)

    No Author:
    (AZBilliards, 2024)
    (WPA Rules, 2022)
```

---

## 13. Quality Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          QUALITY CHECKLIST                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Before Adding Any Reference:
    ─────────────────────────────────────────────────────────────────────────

    □ Metadata Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] reference_id assigned
    [ ] reference_type correct
    [ ] All required fields completed
    [ ] Dates accurate and formatted

    □ Source Verification
    ─────────────────────────────────────────────────────────────────────────
    [ ] Source is authoritative
    [ ] Author/creator credentials verified
    [ ] Information is current
    [ ] No conflicting information found

    □ Accessibility Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] URL verified working
    [ ] Access date recorded
    [ ] Content still available
    [ ] No paywalls blocking access

    □ Relevance Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] Relevance score assigned
    [ ] Content directly applicable
    [ ] Appropriate for BKM audience
    [ ] No better source available

    □ Citation Check
    ─────────────────────────────────────────────────────────────────────────
    [ ] Citation format correct
    [ ] In-text citation consistent
    [ ] All references in bibliography
    [ ] Cross-references noted
```

---

## 14. Related Documents

- [Article Specification](./article_specification.md)
- [Definition Standard](./definition_standard.md)
- [Example Standard](./example_standard.md)
- [Difficulty Standard](./difficulty_standard.md)
- [Term Schema](./term_schema.md)
- [Image Standards](./image_standard.md)
- [Video Standards](./video_standard.md)
- [Validation Rules](./validation_rules.md)

---

## 15. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial reference standards |

---

**Standard Owner:** Content Team
**Next Review:** Monthly during content development
