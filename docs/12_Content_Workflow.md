# Billiard Knowledge Module (BKM) - Content Workflow

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Content Creation Workflow

### 1.1 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTENT WORKFLOW OVERVIEW                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Plan   │───►│ Create  │───►│ Review  │───►│ Approve │───►│ Publish │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │              │
     ▼              ▼              ▼              ▼              ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Content │    │ Initial │    │ Expert  │    │ Editorial│   │ Go Live │
│ Request │    │ Draft   │    │ Review  │    │ Approval │   │ & Sync │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### 1.2 Workflow Stages

| Stage | Description | Owner | Duration |
|-------|-------------|-------|----------|
| **1. Planning** | Identify need, assign | Content Lead | 1-2 days |
| **2. Creation** | Write content | Content Editor | 1-3 days |
| **3. Internal Review** | Self-check, formatting | Content Editor | 1 day |
| **4. Expert Review** | Accuracy verification | Domain Expert | 3-5 days |
| **5. Translation** | Translate to target languages | Language Lead | 5-10 days |
| **6. Editorial Review** | Final check | Editor-in-Chief | 1-2 days |
| **7. Approval** | Sign-off | Approver | 1 day |
| **8. Publishing** | Go live | System | Automatic |

---

## 2. Review Process

### 2.1 Review Types

| Review Type | Purpose | Reviewer | Focus |
|-------------|---------|----------|-------|
| **Self-Review** | Initial quality check | Content Editor | Format, completeness |
| **Expert Review** | Accuracy verification | Domain Expert | Facts, techniques |
| **Peer Review** | Alternative perspective | Another Editor | Clarity, consistency |
| **Language Review** | Translation quality | Language Lead | Grammar, nuance |
| **Editorial Review** | Final approval | Editor-in-Chief | All aspects |

### 2.2 Review Criteria

```markdown
## Review Checklist

### Accuracy (Expert Review)
- [ ] Definition matches official sources
- [ ] Technical details are correct
- [ ] Examples are accurate
- [ ] Cross-references are appropriate
- [ ] Physics/mechanics explanations are sound

### Completeness (Peer Review)
- [ ] All required sections present
- [ ] Examples are sufficient
- [ ] Edge cases covered
- [ ] Related concepts linked

### Clarity (Editorial Review)
- [ ] Accessible to target audience
- [ ] No jargon without explanation
- [ ] Structure is logical
- [ ] Reading level appropriate

### Format (Self-Review)
- [ ] Follows template
- [ ] Headings correct
- [ ] Links work
- [ ] Images have alt text
- [ ] Code blocks properly formatted
```

### 2.3 Review Routing

```
Content Submitted
       │
       ▼
┌──────────────────┐
│ Format Validation│
│ (Automated)      │
└────────┬─────────┘
         │ Pass?
    ┌────┴────┐
   Fail      Pass
    │          │
    ▼          ▼
┌────────┐  ┌──────────────────┐
│ Return │  │ Expert Review    │
│ to     │  │ (Domain Expert)  │
│ Author │  └────────┬─────────┘
└────────┘           │ Pass?
              ┌─────┴─────┐
             Fail        Pass
              │           │
              ▼           ▼
         ┌────────┐  ┌──────────────────┐
         │ Return │  │ Language Review   │
         │ to     │  │ (If translation)  │
         │ Expert │  └────────┬─────────┘
         └────────┘           │ Pass?
                       ┌─────┴─────┐
                      Fail        Pass
                       │           │
                       ▼           ▼
                  ┌────────┐  ┌──────────────────┐
                  │ Return │  │ Editorial Review │
                  │ to     │  └────────┬─────────┘
                  │ Editor │           │ Pass?
                  └────────┘     ┌─────┴─────┐
                                Fail        Pass
                                 │           │
                                 ▼           ▼
                            ┌────────┐  ┌──────────────────┐
                            │ Return │  │ Ready for        │
                            │ to     │  │ Publishing       │
                            │ Editor │  └──────────────────┘
                            └────────┘
```

---

## 3. Approval Workflow

### 3.1 Approval Levels

| Level | Content Type | Approver | Authority |
|-------|-------------|----------|-----------|
| **L1** | Minor corrections | Content Editor | Spelling, formatting |
| **L2** | Standard content | Senior Editor | New terms, updates |
| **L3** | Complex content | Domain Expert + Editor | Technical terms |
| **L4** | Rule changes | Expert Council | Official rules |
| **L5** | Major changes | Editorial Board | Scope, policy |

### 3.2 Approval Matrix

| Content Change | Required Approval |
|----------------|------------------|
| **New term** | L2 + L3 |
| **Definition update** | L1 + L3 |
| **New category** | L2 + L4 |
| **Rule change** | L3 + L4 + L5 |
| **Translation addition** | L2 |
| **Tag addition** | L2 |
| **Media addition** | L2 |
| **Bulk update** | L3 + L5 |

### 3.3 Approval Process

```markdown
## Approval Request Template

**Content:** [Term/File name]
**Type:** [New/Update/Delete]
**Priority:** [Normal/High/Urgent]

### Summary
[Brief description of changes]

### Changes Made
[Detailed list of modifications]

### Review Status
- [x] Self-review complete
- [x] Expert review complete
- [x] Format validation passed

### Verification
- [ ] Facts verified
- [ ] Links tested
- [ ] Images accessible
- [ ] Translations complete (if applicable)

### Approval Required
- [ ] Senior Editor
- [ ] Domain Expert
- [ ] Editor-in-Chief

### Notes
[Any special considerations]
```

---

## 4. Version Control Procedures

### 4.1 Version Numbering

```
Format: v{_major}.{minor}.{patch}

Examples:
- v1.0.0 - Initial release
- v1.1.0 - Minor additions
- v1.1.1 - Bug fix
- v2.0.0 - Major revision
```

### 4.2 Version Update Triggers

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| **Minor edits** | patch | v1.0.0 → v1.0.1 |
| **New examples** | minor | v1.0.0 → v1.1.0 |
| **Definition update** | minor | v1.0.0 → v1.1.0 |
| **New section** | minor | v1.0.0 → v1.1.0 |
| **Major rewrite** | major | v1.0.0 → v2.0.0 |
| **Rule changes** | major | v1.0.0 → v2.0.0 |

### 4.3 Version History Entry

```markdown
## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.2.0 | 2026-07-15 | J. Smith | Added advanced examples section |
| 1.1.0 | 2026-06-01 | A. Johnson | Updated definition, added Vietnamese |
| 1.0.0 | 2026-01-15 | Pool OS Team | Initial publication |
| 0.9.0 | 2025-12-01 | M. Chen | Draft for review |
```

### 4.4 Rollback Procedure

```markdown
## Rollback Procedure

### When to Rollback
- Critical error discovered after publish
- Accuracy issue affecting users
- Security vulnerability

### Rollback Steps
1. Identify affected version
2. Revert to previous version
3. Notify stakeholders
4. Document incident
5. Fix and re-submit
```

---

## 5. Content Lifecycle

### 5.1 Lifecycle Stages

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONTENT LIFECYCLE                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────┐
    │ CONCEPT │
    └────┬────┘
         │
         ▼
    ┌─────────┐     ┌─────────┐     ┌─────────┐
    │ DRAFT   │────►│ REVIEW  │────►│ PUBLISH │
    └────┬────┘     └────┬────┘     └────┬────┘
         │               │               │
         │               ▼               │
         │          ┌─────────┐          │
         │          │ REJECT  │          │
         │          └────┬────┘          │
         │               │               │
         ▼               ▼               ▼
    ┌─────────┐     ┌─────────┐     ┌─────────┐
    │ARCHIVE  │◄────│ UPDATE  │◄────│ MONITOR │
    └─────────┘     └────┬────┘     └────┬────┘
                         │               │
                         ▼               ▼
                    ┌─────────┐     ┌─────────┐
                    │ DRAFT   │     │ARCHIVE  │
                    └─────────┘     └─────────┘
```

### 5.2 Lifecycle Definitions

| Stage | Description | Actions |
|-------|-------------|---------|
| **Concept** | Idea identified | Plan, assign |
| **Draft** | Content being written | Write, format |
| **Review** | Under review | Edit, approve |
| **Publish** | Live and accessible | Monitor |
| **Update** | Needs revision | Edit, re-review |
| **Archive** | No longer current | Keep for reference |

### 5.3 Retention Policy

| Content Type | Retention | Archive Trigger |
|--------------|-----------|-----------------|
| **Published** | Permanent | Superseded |
| **Draft** | 6 months | No activity |
| **Rejected** | 3 months | Resolution |
| **Archived** | Permanent | N/A |

---

## 6. Contribution Guidelines

### 6.1 Contributor Types

| Type | Role | Permissions |
|------|------|-------------|
| **Content Editor** | Full-time staff | Create, edit, submit |
| **Domain Expert** | Specialist reviewer | Review, approve technical |
| **Language Lead** | Translation coordinator | Review translations |
| **External Contributor** | Community member | Submit proposals |
| **AI Assistant** | Automated help | Draft suggestions |

### 6.2 Contributor Onboarding

```markdown
## Contributor Onboarding Checklist

### Access Provision
- [ ] GitHub/GitLab access
- [ ] CMS access
- [ ] Style guide provided
- [ ] Template files shared

### Training
- [ ] Workflow overview completed
- [ ] Style guide reviewed
- [ ] Quality standards understood
- [ ] Tool training completed

### Mentorship
- [ ] Assigned mentor
- [ ] First contribution supervised
- [ ] Feedback provided
- [ ] Access to help resources
```

### 6.3 Contribution Review

All community contributions go through:

1. **Submission** - Contributor submits proposal
2. **Initial Review** - Staff checks completeness
3. **Technical Review** - Expert verifies accuracy
4. **Editorial Review** - Style/format check
5. **Translation** - If needed
6. **Publication** - Credit given, content live

---

## 7. Quality Assurance Checklist

### 7.1 Pre-Publication Checklist

```markdown
## Pre-Publication QA

### Content Verification
- [ ] Definition accurate (verified source)
- [ ] Examples are correct
- [ ] Cross-references exist and work
- [ ] No broken links
- [ ] All images have alt text
- [ ] Videos have captions (if applicable)

### Format Verification
- [ ] Follows template
- [ ] Heading hierarchy correct
- [ ] Markdown properly formatted
- [ ] Code blocks have language
- [ ] Tables are properly aligned

### Metadata
- [ ] Status set to "published"
- [ ] Version updated
- [ ] Dates correct
- [ ] Tags appropriate
- [ ] Author assigned

### Technical
- [ ] Database record created/updated
- [ ] Cache cleared
- [ ] Search index updated
- [ ] CDN invalidated (if needed)
- [ ] Translations queued (if needed)
```

### 7.2 Post-Publication Checklist

```markdown
## Post-Publication QA

### Immediate (First 24 hours)
- [ ] Content appears in search
- [ ] Links functional
- [ ] Images loading
- [ ] Mobile view correct
- [ ] Language toggle works

### Follow-up (First week)
- [ ] User feedback reviewed
- [ ] Search analytics healthy
- [ ] No error reports
- [ ] Performance acceptable
```

---

## 8. Translation Workflow

### 8.1 Translation Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TRANSLATION WORKFLOW                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Source Content (English)
         │
         ▼
┌──────────────────┐
│ Translation      │
│ Request          │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Initial          │
│ Translation      │
│ (AI-assisted)    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Native Speaker   │◄── Feedback
│ Review           │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Cultural          │
│ Adaptation       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Editorial        │
│ Check            │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Published        │
└──────────────────┘
```

### 8.2 Translation Priorities

| Priority | Content Type | Target Language | Timeline |
|----------|-------------|-----------------|----------|
| **P0** | Core terms (500) | Vietnamese | Phase 1 |
| **P0** | UI strings | Vietnamese | Phase 1 |
| **P1** | All published terms | Vietnamese | Phase 2 |
| **P1** | Core terms | Japanese | Phase 4 |
| **P2** | Full content | Japanese | Phase 5 |
| **P2** | Core terms | Korean, Chinese | Phase 5 |

### 8.3 Translation Quality Standards

| Standard | Requirement |
|----------|-------------|
| **Accuracy** | Meaning preserved exactly |
| **Fluency** | Natural in target language |
| **Consistency** | Same terms translated same way |
| **Cultural** | Appropriate for target audience |
| **Technical** | Billiards terminology correct |

---

## 9. Update Procedures

### 9.1 Routine Updates

| Update Type | Frequency | Owner |
|-------------|-----------|-------|
| **Content refresh** | Quarterly | Content Editor |
| **Link verification** | Monthly | Automated |
| **Statistics update** | Weekly | System |
| **Translation sync** | With EN update | Language Lead |

### 9.2 Urgent Updates

```markdown
## Urgent Update Procedure

### Trigger Conditions
- Critical error discovered
- Rule change announcement
- Security issue
- User safety concern

### Procedure
1. Identify affected content
2. Notify stakeholders
3. Create emergency fix
4. Fast-track approval (L4 override)
5. Publish immediately
6. Document incident
7. Post-mortem review
```

### 9.3 Bulk Updates

For updates affecting multiple terms:

1. Create update batch
2. Document all changes
3. Get batch approval (L5)
4. Execute in transaction
5. Verify all changes
6. Monitor for issues

---

## 10. Appendix

### 10.1 Workflow Templates

```markdown
## New Term Request

**Term Name:** 
**Discipline:** 
**Category:** 
**Priority:** 
**Description:** 

**Suggested Definition:**
...

**Proposed Examples:**
1. ...
2. ...

**Related Terms:**
- ...
- ...

**Submission Date:** 
**Submitted By:** 
```

```markdown
## Content Update Request

**Content:** 
**Current Version:** 
**Reason for Update:** 

**Proposed Changes:**
...

**Supporting Documentation:**
- ...

**Approval Requested:** 
**Requested By:** 
```

### 10.2 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Glossary Guideline](./11_Glossary_Guideline.md)
- [BKM Database Schema](./03_Database.md)
- [BKM File Standards](./10_File_Standards.md)

---

**End of Document**
