# BKM - Review Workflow

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document defines the review workflow for all BKM Knowledge Base content. The workflow ensures content quality, maintains consistency, and provides clear accountability throughout the content lifecycle.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW OVERVIEW                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │                                                                      │
    │     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐│
    │     │          │ ──▶ │          │ ──▶ │          │ ──▶ │          ││
    │     │  DRAFT   │     │  REVIEW  │     │ APPROVED │     │PUBLISHED ││
    │     │          │ ◀── │          │     │          │     │          ││
    │     └──────────┘     └──────────┘     └──────────┘     └──────────┘│
    │          │                                                      │     │
    │          │                                                      │     │
    │          ▼                                                      ▼     │
    │     ┌──────────┐                                          ┌──────────┐
    │     │          │                                          │          │
    │     │ ARCHIVED │                                          │  DRAFT   │
    │     │          │                                          │ (Update) │
    │     └──────────┘                                          └──────────┘
    │                                                                      │
    │     FORK PATH                                                       │
    │     ─────────────────────────────────────────────────────────────   │
    │     Content can be updated after publication, returning to DRAFT    │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 2. State Definitions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            STATE DEFINITIONS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   State          │ Description                                        │
    │   ──────────────┼───────────────────────────────────────────────    │
    │                                                                      │
    │   DRAFT         │ Initial state. Content being created or edited.   │
    │                 │ Work in progress. Not ready for review.            │
    │                                                                      │
    │   REVIEW        │ Content submitted for review. Awaiting approval    │
    │                 │ from content team. Under evaluation.               │
    │                                                                      │
    │   APPROVED      │ Content reviewed and approved. Ready for           │
    │                 │ publication. Minor fixes may still be needed.     │
    │                                                                      │
    │   PUBLISHED     │ Live in the BKM Knowledge Base. Accessible to     │
    │                 │ users. Active content.                             │
    │                                                                      │
    │   ARCHIVED      │ No longer active. Removed from public view.       │
    │                 │ Preserved for reference. Can be restored.          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. State Metadata

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            STATE METADATA                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Each content item tracks the following state information:

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Field              │ Description                                    │
    │   ──────────────────┼─────────────────────────────────────────────  │
    │   current_state     │ Current workflow state                         │
    │   previous_state    │ State before current transition                │
    │   state_changed_at  │ Timestamp of last state change                 │
    │   state_changed_by  │ User who triggered last transition             │
    │   state_reason      │ Reason for transition (optional)               │
    │   review_count     │ Number of times reviewed                       │
    │   last_review_date  │ Date of last review                            │
    │   approved_by       │ User who approved (if applicable)              │
    │   approved_at       │ Timestamp of approval                           │
    │   published_at     │ Timestamp of publication                        │
    │   archived_at       │ Timestamp of archival                          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 4. State Descriptions

### 4.1 DRAFT State

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STATE: DRAFT                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Content is being actively created or significantly modified.

    CHARACTERISTICS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Characteristic        │ Behavior                                      │
    │   ────────────────────┼───────────────────────────────────────────   │
    │   Visibility           │ Author only                                  │
    │   Editable            │ Fully editable by author                     │
    │   Comments            │ Open for author notes                         │
    │   Auto-save           │ Enabled                                      │
    │   Version control     │ Active                                        │
    │   Sharing            │ Manual link only                              │
    │   Public access       │ None                                         │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ENTRY CRITERIA
    ─────────────────────────────────────────────────────────────────────────
    • New content created
    • Major revision requested
    • Published content returned for major update
    • Content restored from archive for revision

    EXIT CRITERIA (to REVIEW)
    ─────────────────────────────────────────────────────────────────────────
    • Content complete
    • All required fields populated
    • Self-review completed by author
    • Ready for external review
```

### 4.2 REVIEW State

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STATE: REVIEW                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Content is under evaluation by the content review team.

    CHARACTERISTICS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Characteristic        │ Behavior                                      │
    │   ────────────────────┼───────────────────────────────────────────   │
    │   Visibility           │ Author + Reviewers                            │
    │   Editable            │ Author only (with notification)              │
    │   Comments            │ Review comments enabled                       │
    │   Auto-save           │ Enabled                                       │
    │   Version control     │ Frozen (new version created on edit)          │
    │   Sharing            │ Review link available                         │
    │   Public access       │ None                                          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ENTRY CRITERIA
    ─────────────────────────────────────────────────────────────────────────
    • Author submits for review
    • Automated validation passed
    • All required metadata present
    • Content follows basic structure

    EXIT CRITERIA (to APPROVED)
    ─────────────────────────────────────────────────────────────────────────
    • All review criteria met
    • Technical accuracy verified
    • Style compliance confirmed
    • No blocking issues
    • Reviewer approval obtained

    EXIT CRITERIA (to DRAFT)
    ─────────────────────────────────────────────────────────────────────────
    • Major issues identified
    • Significant revisions required
    • Fails review criteria
```

### 4.3 APPROVED State

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          STATE: APPROVED                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Content has passed review and is ready for publication.

    CHARACTERISTICS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Characteristic        │ Behavior                                      │
    │   ────────────────────┼───────────────────────────────────────────   │
    │   Visibility           │ Author + Publishers                          │
    │   Editable            │ Publisher only (minor fixes)                 │
    │   Comments            │ Closed                                       │
    │   Auto-save           │ Disabled                                     │
    │   Version control     │ Final version locked                         │
    │   Sharing            │ Pre-publication preview                       │
    │   Public access       │ None (scheduled only)                        │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ENTRY CRITERIA
    ─────────────────────────────────────────────────────────────────────────
    • Review passed
    • Reviewer approved
    • All issues resolved
    • Ready for publication queue

    EXIT CRITERIA (to PUBLISHED)
    ─────────────────────────────────────────────────────────────────────────
    • Publication scheduled
    • Publication executed
    • Public visibility confirmed

    EXIT CRITERIA (to DRAFT)
    ─────────────────────────────────────────────────────────────────────────
    • Late-breaking issues discovered
    • Author requests changes
    • Publisher rejects (requires re-review)
```

### 4.4 PUBLISHED State

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STATE: PUBLISHED                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Content is live and accessible to BKM users.

    CHARACTERISTICS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Characteristic        │ Behavior                                      │
    │   ────────────────────┼───────────────────────────────────────────   │
    │   Visibility           │ Public                                        │
    │   Editable            │ Requires new version (not in-place)           │
    │   Comments            │ User comments enabled                        │
    │   Auto-save           │ N/A                                           │
    │   Version control     │ Version history maintained                    │
    │   Sharing            │ Full public access                            │
    │   Public access       │ Full access                                   │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ENTRY CRITERIA
    ─────────────────────────────────────────────────────────────────────────
    • Approved content published
    • Publication date/time reached
    • Public visibility enabled

    EXIT CRITERIA (to DRAFT)
    ─────────────────────────────────────────────────────────────────────────
    • Update requested
    • Major revision needed
    • User feedback indicates error

    EXIT CRITERIA (to ARCHIVED)
    ─────────────────────────────────────────────────────────────────────────
    • Content obsolete
    • Replaced by updated version
    • Scheduled retirement
    • Policy violation discovered
```

### 4.5 ARCHIVED State

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STATE: ARCHIVED                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    PURPOSE
    ─────────────────────────────────────────────────────────────────────────
    Content is retired but preserved for historical reference.

    CHARACTERISTICS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Characteristic        │ Behavior                                      │
    │   ────────────────────┼───────────────────────────────────────────   │
    │   Visibility           │ Authors only (or admin)                      │
    │   Editable            │ Admin only                                    │
    │   Comments            │ Hidden but preserved                          │
    │   Auto-save           │ N/A                                           │
    │   Version control     │ Archived version preserved                    │
    │   Sharing            │ No sharing                                     │
    │   Public access       │ None                                          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    ENTRY CRITERIA
    ─────────────────────────────────────────────────────────────────────────
    • Content replaced by new version
    • Content declared obsolete
    • Scheduled retention period ended
    • Manual archival requested

    EXIT CRITERIA (to DRAFT)
    ─────────────────────────────────────────────────────────────────────────
    • Restoration requested
    • Content still valuable
    • Admin approval for restoration

    EXIT CRITERIA (to PUBLISHED)
    ─────────────────────────────────────────────────────────────────────────
    • Direct restoration to live (rare)
    • Requires review
```

---

## 5. Transition Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TRANSITION RULES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   FROM          │ TO            │ TRIGGER      │ REQUIREMENTS        │
    │   ─────────────┼───────────────┼──────────────┼─────────────────────  │
    │   DRAFT        │ REVIEW        │ Submit       │ All required fields │
    │   DRAFT        │ ARCHIVED      │ Delete       │ No dependents       │
    │   REVIEW       │ DRAFT         │ Reject       │ Review comments     │
    │   REVIEW       │ APPROVED      │ Approve      │ All criteria met    │
    │   REVIEW       │ DRAFT         │ Request Fix  │ Fix list required   │
    │   APPROVED     │ DRAFT         │ Revoke       │ Reason required     │
    │   APPROVED     │ PUBLISHED     │ Publish      │ Schedule met        │
    │   PUBLISHED    │ DRAFT         │ Update       │ New version created │
    │   PUBLISHED    │ ARCHIVED      │ Archive      │ No dependents       │
    │   ARCHIVED     │ DRAFT         │ Restore      │ Admin approval      │
    │   ARCHIVED     │ PUBLISHED     │ Quick Restore│ Admin + Re-review   │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Detailed Transition Specifications

### 6.1 DRAFT → REVIEW

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TRANSITION: DRAFT → REVIEW                                │
│                    Submit for Review                                         │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Author clicks "Submit for Review" button

    ─────────────────────────────────────────────────────────────────────────

    VALIDATION CHECKLIST
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   □ Content Fields                                                   │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Title present and non-empty                                    │
    │   [ ] Content body complete                                          │
    │   [ ] All required sections populated                                │
    │   [ ] No placeholder text remaining                                  │
    │   [ ] Internal links verified                                        │
    │                                                                      │
    │   □ Metadata                                                         │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Difficulty level assigned                                      │
    │   [ ] Related terms linked                                           │
    │   [ ] Tags assigned (minimum 3)                                     │
    │   [ ] References cited (if applicable)                              │
    │   [ ] Featured image selected (if applicable)                        │
    │                                                                      │
    │   □ Technical                                                         │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] No broken external links                                       │
    │   [ ] Media assets uploaded and accessible                          │
    │   [ ] Character encoding correct                                    │
    │   [ ] Format compliance validated                                    │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to REVIEW
    • state_changed_at updated
    • state_changed_by set to author
    • Notification sent to review queue
    • review_count incremented
    • last_review_date updated

    ─────────────────────────────────────────────────────────────────────────

    AUTO-REJECT CONDITIONS
    ─────────────────────────────────────────────────────────────────────────
    If any of the following are true, transition is blocked:
    • Title missing
    • Content body empty
    • More than 10% placeholder text
    • Required metadata fields empty
```

### 6.2 REVIEW → APPROVED

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TRANSITION: REVIEW → APPROVED                             │
│                    Approve Content                                           │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Reviewer clicks "Approve" button

    ─────────────────────────────────────────────────────────────────────────

    APPROVAL CRITERIA
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Category          │ Criteria                                        │
    │   ─────────────────┼─────────────────────────────────────────────    │
    │                                                                      │
    │   ACCURACY                                                          │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Technical information correct                                 │
    │   [ ] No factual errors detected                                    │
    │   [ ] References are valid and cited properly                       │
    │   [ ] Rules and standards accurately represented                   │
    │                                                                      │
    │   CLARITY                                                            │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Clear and understandable language                            │
    │   [ ] Appropriate for target audience                              │
    │   [ ] No ambiguous statements                                       │
    │   [ ] Well-structured sections                                      │
    │                                                                      │
    │   STYLE                                                              │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Follows BKM style guide                                       │
    │   [ ] Formatting consistent                                         │
    │   [ ] Terminology consistent                                        │
    │   [ ] Tone appropriate                                              │
    │                                                                      │
    │   COMPLETENESS                                                       │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] All required sections present                                │
    │   [ ] Sufficient detail for purpose                                │
    │   [ ] Examples provided (where required)                           │
    │   [ ] Cross-references linked                                       │
    │                                                                      │
    │   TECHNICAL                                                           │
    │   ───────────────────────────────────────────────────────────────  │
    │   [ ] Links work                                                    │
    │   [ ] Media displays correctly                                      │
    │   [ ] No spelling/grammar errors                                     │
    │   [ ] Accessibility requirements met                                 │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to APPROVED
    • approved_by set to reviewer
    • approved_at timestamp updated
    • Notification sent to author
    • Content queued for publication

    ─────────────────────────────────────────────────────────────────────────

    REVIEWER REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────
    • Must have REVIEWER role or higher
    • Cannot approve own content
    • Must have expertise in content area
    • Must have completed review training
```

### 6.3 REVIEW → DRAFT

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TRANSITION: REVIEW → DRAFT                               │
│                    Reject / Request Changes                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Reviewer clicks "Request Changes" button

    ─────────────────────────────────────────────────────────────────────────

    REQUIRED INPUT
    ─────────────────────────────────────────────────────────────────────────
    • Rejection reason (mandatory)
    • Detailed feedback (minimum 50 characters)
    • Specific change requests (checklist)

    ─────────────────────────────────────────────────────────────────────────

    REJECTION REASON OPTIONS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Reason              │ Description                                   │
    │   ───────────────────┼───────────────────────────────────────────    │
    │   Inaccurate          │ Factual errors or outdated information        │
    │   Incomplete         │ Missing required content or sections          │
    │   Unclear            │ Difficult to understand or ambiguous          │
    │   Non-compliant      │ Does not follow style or format standards     │
    │   Poor Quality       │ Writing quality below acceptable level        │
    │   Off-topic          │ Content not appropriate for article           │
    │   Duplicate          │ Redundant with existing content               │
    │   Other              │ Other reason (requires explanation)            │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    FEEDBACK REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────
    • Specific location in content (section/paragraph)
    • Issue description
    • Suggested fix or direction
    • Priority (blocking, minor)

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to DRAFT
    • state_changed_by set to reviewer
    • state_reason set to rejection reason
    • Notification sent to author with feedback
    • Review history updated

    ─────────────────────────────────────────────────────────────────────────

    AUTHOR ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • Review feedback
    • Make required changes
    • Can add comments/questions
    • Re-submit when ready
```

### 6.4 APPROVED → PUBLISHED

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   TRANSITION: APPROVED → PUBLISHED                           │
│                   Publish Content                                             │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Automatic on schedule OR manual "Publish Now" action

    ─────────────────────────────────────────────────────────────────────────

    PUBLICATION OPTIONS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Option              │ Behavior                                       │
    │   ───────────────────┼───────────────────────────────────────────    │
    │   Immediate          │ Published instantly upon approval             │
    │   Scheduled          │ Published at specified date/time              │
    │   Queue              │ Added to publication queue (FIFO)              │
    │   Manual             │ Requires explicit publish action               │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    PRE-PUBLICATION CHECKLIST
    ─────────────────────────────────────────────────────────────────────────
    • URL slug generated and verified unique
    • Meta description present
    • Featured image optimized
    • Related content linked
    • Search index prepared
    • Cache cleared upon publish

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to PUBLISHED
    • published_at timestamp set
    • Public visibility enabled
    • Search engines notified
    • Sitemap updated
    • Notification sent to author

    ─────────────────────────────────────────────────────────────────────────

    PUBLISHER REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────
    • Must have PUBLISHER role or higher
    • Can publish own content (if author has PUBLISHER role)
```

### 6.5 PUBLISHED → DRAFT

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   TRANSITION: PUBLISHED → DRAFT                             │
│                   Request Update                                             │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Author or admin requests content update

    ─────────────────────────────────────────────────────────────────────────

    UPDATE TYPES
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Type               │ Description                                   │
    │   ──────────────────┼───────────────────────────────────────────     │
    │   Minor Edit        │ Typo fix, link update, small clarification   │
    │   Major Revision    │ Significant content change                   │
    │   Full Rewrite      │ Complete content replacement                  │
    │   New Version       │ New article based on existing                  │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    VERSION CONTROL
    ─────────────────────────────────────────────────────────────────────────
    When PUBLISHED → DRAFT:
    • Current published version archived as v1
    • New version created as v2 (DRAFT)
    • Original remains published until new version approved
    • Both versions linked in history

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • New version created (DRAFT state)
    • Original version remains PUBLISHED
    • Version number incremented
    • Update reason recorded

    ─────────────────────────────────────────────────────────────────────────

    PRESERVED ELEMENTS
    ─────────────────────────────────────────────────────────────────────────
    • Original published_at date
    • View counts and statistics
    • User comments (transfer to new version)
    • Reference to previous version
```

### 6.6 PUBLISHED → ARCHIVED

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  TRANSITION: PUBLISHED → ARCHIVED                           │
│                  Archive Content                                             │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Admin or automated process archives content

    ─────────────────────────────────────────────────────────────────────────

    ARCHIVAL REASONS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Reason              │ Description                                   │
    │   ───────────────────┼───────────────────────────────────────────    │
    │   Superseded         │ Replaced by updated content                   │
    │   Obsolete           │ No longer relevant or accurate                 │
    │   Duplicate          │ Merged with another article                   │
    │   Policy Violation   │ Content violates guidelines                   │
    │   Retention Period   │ End of content lifecycle                      │
    │   Manual             │ Admin-initiated archival                       │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ─────────────────────────────────────────────────────────────────────────

    DEPENDENCY CHECK
    ─────────────────────────────────────────────────────────────────────────
    Before archiving:
    • Check if other content links to this article
    • Notify linked content authors
    • Update or remove links
    • Document archival in related content

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to ARCHIVED
    • archived_at timestamp set
    • Public visibility removed
    • Search index updated
    • Sitemap updated
    • Statistics preserved
    • Notification sent to author

    ─────────────────────────────────────────────────────────────────────────

    PRESERVED ELEMENTS
    ─────────────────────────────────────────────────────────────────────────
    • All versions
    • Edit history
    • User comments
    • View/access statistics
    • Associated metadata
    • Link relationships
```

### 6.7 ARCHIVED → DRAFT

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   TRANSITION: ARCHIVED → DRAFT                               │
│                   Restore for Revision                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    TRIGGER
    ─────────────────────────────────────────────────────────────────────────
    Admin approves restoration request

    ─────────────────────────────────────────────────────────────────────────

    RESTORATION REQUIREMENTS
    ─────────────────────────────────────────────────────────────────────────
    • Valid reason for restoration
    • Admin approval
    • Original content review
    • Update plan documented

    ─────────────────────────────────────────────────────────────────────────

    RESTORATION REASONS
    ─────────────────────────────────────────────────────────────────────────
    • Content still valuable
    • Information can be updated
    • Replaced by non-existent content
    • Historical reference needed
    • Requested by content owner

    ─────────────────────────────────────────────────────────────────────────

    TRANSITION ACTIONS
    ─────────────────────────────────────────────────────────────────────────
    • State changes to DRAFT
    • New version created
    • Original archived version linked
    • Restoration reason recorded
    • Notification sent

    ─────────────────────────────────────────────────────────────────────────

    PRESERVED FROM ARCHIVE
    ─────────────────────────────────────────────────────────────────────────
    • Original content
    • Version history
    • Comments (hidden)
    • Statistics (historical)
    • Previous metadata
```

---

## 7. Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           COMPLETE WORKFLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                        ║
    ║    ┌─────────────────────────────────────────────────────────────┐    ║
    ║    │                                                             │    ║
    ║    │                     CONTENT CREATOR                          │    ║
    ║    │                                                             │    ║
    ║    └─────────────────────────────────────────────────────────────┘    ║
    ║                              │                                        ║
    ║                              ▼                                        ║
    ║    ┌─────────────────────────────────────────────────────────────┐    ║
    ║    │                                                             │    ║
    ║    │  ┌──────────┐                                               │    ║
    ║    │  │          │                                               │    ║
    ║    │  │  DRAFT   │◀──────────────────────────────────────────┐   │    ║
    ║    │  │          │                                            │   │    ║
    ║    │  └────┬─────┘                                            │   │    ║
    ║    │       │                                                  │   │    ║
    ║    │       │ Submit                                           │   │    ║
    ║    │       ▼                                                  │   │    ║
    ║    │  ┌──────────┐     Reject                                  │   │    ║
    ║    │  │          │◀────────────┐                                │   │    ║
    ║    │  │  REVIEW  │             │                                │   │    ║
    ║    │  │          │───────────▶ │                                │   │    ║
    ║    │  └────┬─────┘             │                                │   │    ║
    ║    │       │                   │                                │   │    ║
    ║    │       │ Approve           │                                │   │    ║
    ║    │       ▼                   │                                │   │    ║
    ║    │  ┌──────────┐             │                                │   │    ║
    ║    │  │          │─────────────┘                                │   │    ║
    ║    │  │ APPROVED │                                                │   │    ║
    ║    │  │          │                                                │   │    ║
    ║    │  └────┬─────┘                                                │   │    ║
    ║    │       │ Publish                                              │   │    ║
    ║    │       ▼                                                      │   │    ║
    ║    │  ┌──────────┐                                                │   │    ║
    ║    │  │          │                                                │   │    ║
    ║    │  │PUBLISHED │───────────────────────────────────────────────▶│   │    ║
    ║    │  │          │                                                │   │    ║
    ║    │  └──────────┘                                                │   │    ║
    ║    │                                                             │    ║
    ║    │                     CONTENT TEAM / ADMIN                     │    ║
    ║    │                                                             │    ║
    ║    └─────────────────────────────────────────────────────────────┘    ║
    ║                              │                                        ║
    ║                              │ Archive                                ║
    ║                              ▼                                        ║
    ║    ┌─────────────────────────────────────────────────────────────┐    ║
    ║    │                                                             │    ║
    ║    │  ┌──────────┐     Restore                                  │    ║
    ║    │  │          │◀──────────────────────────────────────────┐   │    ║
    ║    │  │ ARCHIVED │                                          │   │    ║
    ║    │  │          │──────────────────────────────────────────▶│   │    ║
    ║    │  └──────────┘                                          │   │    ║
    ║    │                                                    │     │    ║
    ║    │                              ┌─────────────────────┘     │    ║
    ║    │                              │                           │    ║
    ║    │                              ▼                           │    ║
    ║    │                         ┌──────────┐                     │    ║
    ║    │                         │  DRAFT   │ ◀────────────────────┘    ║
    ║    │                         │ (Update) │                           ║
    ║    │                         └──────────┘                           ║
    ║    │                                                             │    ║
    ║    └─────────────────────────────────────────────────────────────┘    ║
    ║                                                                        ║
    ╚═══════════════════════════════════════════════════════════════════════╝
```

---

## 8. Role Permissions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ROLE PERMISSIONS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Role          │ DRAFT │ REVIEW │ APPROVED │PUBLISHED│ ARCHIVED │
    │   ─────────────┼───────┼────────┼──────────┼──────────┼───────────│
    │   AUTHOR        │   ✓   │   ✓    │    ○     │    ○    │     ○    │
    │   REVIEWER      │   ✓   │   ✓    │    ✓     │    ○    │     ○    │
    │   PUBLISHER     │   ✓   │   ✓    │    ✓     │    ✓    │     ○    │
    │   ADMIN         │   ✓   │   ✓    │    ✓     │    ✓    │     ✓    │
    │                                                                      │
    │   ✓ = Can view/edit    ○ = View only    ✗ = No access             │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    TRANSITION PERMISSIONS
    ─────────────────────────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Transition           │ Required Role                               │
    │   ─────────────────────┼──────────────────────────────────────────   │
    │   DRAFT → REVIEW       │ AUTHOR (owner)                             │
    │   REVIEW → DRAFT       │ REVIEWER                                    │
    │   REVIEW → APPROVED    │ REVIEWER                                    │
    │   APPROVED → DRAFT    │ ADMIN                                       │
    │   APPROVED → PUBLISHED│ PUBLISHER, ADMIN                           │
    │   PUBLISHED → DRAFT   │ AUTHOR (if owner), ADMIN                    │
    │   PUBLISHED → ARCHIVED│ ADMIN                                       │
    │   ARCHIVED → DRAFT    │ ADMIN                                       │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 9. Notification Triggers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          NOTIFICATIONS                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Transition               │ Notifications Sent To                 │
    │   ─────────────────────────┼──────────────────────────────────────   │
    │   DRAFT → REVIEW           │ Review queue, Author (confirm)         │
    │   REVIEW → DRAFT           │ Author, Reviewers                      │
    │   REVIEW → APPROVED        │ Author, Publishers                     │
    │   APPROVED → DRAFT        │ Author (reason)                         │
    │   APPROVED → PUBLISHED    │ Author (live link)                      │
    │   PUBLISHED → DRAFT       │ Author (new version)                    │
    │   PUBLISHED → ARCHIVED    │ Author, linked content authors          │
    │   ARCHIVED → DRAFT       │ Author                                   │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    NOTIFICATION CONTENT
    ─────────────────────────────────────────────────────────────────────────
    • Current state
    • Transition that occurred
    • Person who triggered it
    • Required action (if any)
    • Link to content
    • Relevant comments/reasons
```

---

## 10. State Duration Guidelines

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STATE DURATION GUIDELINES                            │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   State          │ Target Duration │ Max Duration │ Escalation    │
    │   ──────────────┼────────────────┼───────────────┼───────────────  │
    │   DRAFT         │ 1-7 days       │ 30 days       │ Auto-reminder │
    │   REVIEW        │ 1-3 days       │ 7 days        │ Queue alert   │
    │   APPROVED      │ 1-24 hours     │ 48 hours      │ Publish alert │
    │   PUBLISHED     │ Indefinite     │ Until archived│ Review cycle  │
    │   ARCHIVED      │ Indefinite     │ Permanent     │ None          │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    ESCALATION TIMELINE
    ─────────────────────────────────────────────────────────────────────────
    • Day 1: Initial notification
    • Day 3: Reminder notification
    • Day 5: Escalation to supervisor
    • Day 7: Admin intervention

    REVIEW CYCLE FOR PUBLISHED CONTENT
    ─────────────────────────────────────────────────────────────────────────
    • Quarterly review for active content
    • Annual review for stable content
    • Triggered review for flagged content
```

---

## 11. Workflow Validation Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VALIDATION RULES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    BLOCKING RULES
    ─────────────────────────────────────────────────────────────────────────
    Transition cannot occur if:

    DRAFT → REVIEW:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Title is empty
    ✗ Content body is empty
    ✗ More than 10% placeholder text detected
    ✗ Required metadata fields missing
    ✗ Author role is suspended

    REVIEW → APPROVED:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Any blocking review criteria unmet
    ✗ Reviewer is content author
    ✗ Reviewer lacks required expertise
    ✗ Pending comments not addressed

    APPROVED → PUBLISHED:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Scheduled time not reached (if scheduled)
    ✗ Publisher role insufficient
    ✗ URL slug already exists

    PUBLISHED → ARCHIVED:
    ─────────────────────────────────────────────────────────────────────────
    ✗ Active user sessions on content
    ✗ Required as prerequisite for other content
    ✗ Legal hold on content
```

---

## 12. Quality Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          QUALITY CHECKLIST                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Workflow Compliance:
    ─────────────────────────────────────────────────────────────────────────

    □ State Management
    ─────────────────────────────────────────────────────────────────────────
    [ ] Correct initial state assigned
    [ ] State transitions follow defined rules
    [ ] Invalid transitions blocked
    [ ] State history maintained

    □ Metadata
    ─────────────────────────────────────────────────────────────────────────
    [ ] state_changed_at updated on each transition
    [ ] state_changed_by recorded
    [ ] State reason documented
    [ ] Timestamps accurate

    □ Notifications
    ─────────────────────────────────────────────────────────────────────────
    [ ] Notifications sent on transitions
    [ ] Correct recipients notified
    [ ] Notification content accurate

    □ Permissions
    ─────────────────────────────────────────────────────────────────────────
    [ ] Role-based access enforced
    [ ] Transition permissions validated
    [ ] Self-approval prevented
    [ ] Admin overrides documented

    □ Compliance
    ─────────────────────────────────────────────────────────────────────────
    [ ] Review deadlines met
    [ ] Escalation triggers working
    [ ] Audit trail complete
    [ ] Rollback capability verified
```

---

## 13. Related Documents

- [Article Specification](./article_specification.md)
- [Definition Standard](./definition_standard.md)
- [Example Standard](./example_standard.md)
- [Difficulty Standard](./difficulty_standard.md)
- [Term Schema](./term_schema.md)
- [Image Standards](./image_standard.md)
- [Video Standards](./video_standard.md)
- [Reference Standards](./reference_standard.md)
- [Validation Rules](./validation_rules.md)

---

## 14. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial workflow definition |

---

**Standard Owner:** Content Team
**Next Review:** Monthly during content development
