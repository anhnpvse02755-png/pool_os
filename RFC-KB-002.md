# Pool OS
# RFC-KB-002
# Knowledge Pack V1 + Beta Knowledge Experience

Version: 1.0
Status: Planned
Target: Post Task 15 (Release 1.x)
Priority: HIGH

---

# Vision

Pool OS is not only a statistics application.

Pool OS is a Personal Pool Coach.

Coach becomes intelligent through high-quality knowledge.

Knowledge is therefore a first-class product asset.

Knowledge should already be visible in Release 1.x even before the future CMS exists.

Users should be able to:

- Learn
- Practice
- Give feedback
- Watch Pool OS continuously improve

---

# Objectives

This RFC has TWO objectives.

## Objective 1

Build the first complete Knowledge Pack.

## Objective 2

Expose Knowledge inside the application as a Beta feature so users can already experience it and help improve it.

---

# Important Principles

Knowledge is NOT fake.

Knowledge is NOT placeholder text.

Knowledge is real content.

However...

Knowledge is still evolving.

Users must clearly understand that.

---

# Product Philosophy

Coach remains the center.

Training Center remains the learning center.

Coach recommends.

Training Center teaches.

Statistics measures.

Matches collect data.

Equipment records equipment.

Readiness records condition.

Everything exists to help Coach make better decisions.

---

# Primary Knowledge Sources

Claude should synthesize knowledge from internationally recognized sources including but not limited to:

• Dr. Dave Billiards
• Tor Lowry
• Sharivari
• WPA technical principles
• Professional coaching methodology

Additionally, Claude should adapt explanations to Vietnamese amateur players by considering common coaching concepts used by experienced Vietnamese instructors.

Do NOT copy copyrighted content.

Do NOT reproduce articles.

Do NOT reproduce videos.

Create original synthesized knowledge.

---

# Knowledge Categories

Build knowledge for:

## Techniques

Stop Shot

Follow Shot

Draw Shot

Stun Shot

Rolling Cue Ball

Cue Ball Control

Spin

Throw

Cut Shot

Thin Cut

Thick Cut

Bank

Kick

Jump

Break

Safety

Bridge

Grip

Alignment

Stance

Pre-shot Routine

Position Play

Pattern Play

...

---

## Drills

Each drill must include

Purpose

Difficulty

Setup

Execution

Success Criteria

Failure Criteria

Repetitions

Common Mistakes

Related Techniques

Coach Trigger

Estimated Practice Time

---

## Common Mistakes

Examples

Lifting head

Body movement

Steering

Poor alignment

Wrong bridge

Over-hitting

Under-hitting

Wrong spin

Poor planning

Bad speed control

...

Each mistake includes

Symptoms

Possible Causes

Correction

Related Drill

Related Technique

Difficulty

Priority

---

## Equipment

Cue

Shaft

Tip

Tip hardness

Weight

Balance

Break cue

Jump cue

Break-Jump cue

Maintenance

Advantages

Limitations

Coach Notes

---

## Mental Game

Pressure

Confidence

Focus

Routine

Tournament mindset

Recovery

Decision making

Tilt control

---

## Strategy

Pattern

Safety

Kick selection

Jump selection

Break strategy

Risk vs Reward

Table management

Planning

---

# Knowledge Standard

Every Knowledge Item must follow exactly the same schema.

Required fields

Knowledge ID

Title

Category

Difficulty

Summary

Purpose

Prerequisites

Setup

Execution

Success Criteria

Failure Criteria

Common Mistakes

Corrections

Related Drills

Related Techniques

Related Equipment

Coach Trigger Conditions

Coach Recommendation Notes

Keywords

Estimated Learning Time

Revision

Knowledge Status

---

# Difficulty Levels

Beginner

Intermediate

Advanced

Professional

---

# Knowledge Status

Every knowledge item must include one status.

Verified

Content reviewed and trusted.

Beta

Usable but still being improved.

Draft

Future content.

The application must visually display this status.

---

# Coach Integration

Coach never hardcodes articles.

Coach only returns

KnowledgeId

Example

Player repeatedly misses Stop Shot

↓

Coach

↓

KnowledgeId

↓

Training Center

↓

Load article

Coach knows WHAT to recommend.

Training Center knows HOW to display it.

---

# Knowledge Relationships

Knowledge must be linked.

Example

Technique

↓

Related Drill

↓

Related Mistake

↓

Correction

↓

Equipment

↓

Coach Rule

Claude should build these relationships.

---

# Media

Prepare support for

Image

GIF

Video

Animation

Diagram

Do NOT generate media.

Only reserve the structure.

---

# CMS Ready

Knowledge must be stored in a CMS-ready format.

Suggested structure

knowledge/

techniques/

drills/

mistakes/

equipment/

mental/

strategy/

Each item is independent.

Later the source can change from

Assets

↓

Knowledge API

without changing UI.

---

# Beta Knowledge Experience

Knowledge is available immediately.

Knowledge is NOT hidden until CMS exists.

Training Center should become visible now.

---

# Training Center

Design and implement a usable Training Center.

Example

Coach Recommended

Stop Shot Level 3

--------------------------------

Techniques

Stop Shot

Follow

Draw

Position

Safety

Break

Jump

Pattern

...

Some articles may still be Beta.

---

# Technique Detail Screen

Every technique page should contain

Title

Difficulty

Knowledge Status

Coach Recommendation Banner

Purpose

Setup

Execution

Success Criteria

Failure Criteria

Common Mistakes

Corrections

Related Drill

Related Technique

Related Equipment

Media Placeholder

Last Updated

Knowledge Version

---

# Beta Badge

Every article shows

Verified

Beta

Draft

Users always know the maturity of the content.

No fake completeness.

---

# Coach Recommendation Banner

When entering from Coach

Display

Coach recommends this technique based on your recent performance.

Users understand WHY they are reading it.

---

# Media Placeholder

Video

Coming Soon

GIF

Coming Soon

Animation

Coming Soon

The UI should already support them.

---

# Feedback Experience

Knowledge is community-driven.

Every article should contain

Was this helpful?

👍

👎

Suggest Improvement

Report Issue

The first release may simply open

Email

Google Form

GitHub Issue

No backend required.

---

# Beta Message

Every Beta article displays

This knowledge is still evolving.

Your feedback helps improve Pool OS Coach.

This is intentional.

---

# Coach Communication

Coach should also explain confidence.

Example

Your Stop Shot looks excellent in practice.

However,

I still don't have enough match data.

Play more matches so I can evaluate your real competition performance.

Coach should always tell users

What is known

What is uncertain

What data is still missing

---

# Knowledge Graph

Claude should build relationships.

Example

Stop Shot

↓

Common Mistakes

↓

Related Drill

↓

Related Equipment

↓

Related Technique

↓

Coach Trigger

Knowledge is a graph.

Not isolated articles.

---

# Quality Rules

No repetition.

No filler.

Actionable advice only.

Every drill has measurable success.

Every mistake has a correction.

Every technique links to drills.

Every drill links to techniques.

Knowledge should be understandable by Vietnamese amateur players while remaining technically accurate.

---

# Out of Scope

No CMS.

No backend.

No API.

No database changes.

No Flutter architecture changes.

No AI implementation.

No generated media.

---

# Deliverables

Claude should produce

Complete Knowledge Taxonomy

Knowledge Schema

Knowledge Pack V1

Knowledge Graph

Coach Metadata

CMS-ready Structure

Training Center UI

Technique Detail UI

Beta Knowledge Experience

Feedback UX

Knowledge Status UX

Media Placeholder UX

The result should already be usable inside Release 1.x while remaining fully compatible with the future Knowledge CMS without requiring architectural redesign.

---

# Release Note

Release 1.0 is not the final Coach. It is the first public Coach capable of analyzing real player data, recommending training, and delivering structured knowledge. Community feedback collected during this release will continuously improve the Knowledge Pack and Coach recommendations in future releases.

---

# Frozen Decisions (Final Review)

- Drill is an external referenced resource, NOT a KnowledgeItem. `KnowledgeType` SHALL NOT contain `drill`. Any drill shown in the Learning Hub is resolved from DrillLibrary through `drillRefs`.
- Knowledge IDs are immutable. Once published, an `id` MUST NEVER change. If content changes substantially, create a new item and deprecate the old one.
- Terminology is frozen: "Learning Hub" (never "Knowledge Browser"), "KnowledgeItem" (never "KnowledgeArticle"), "Coach Data Confidence" (never "Knowledge Confidence").
- `estimatedSkillGain` is a per-skill weight map `{skillId: 0-100}`, not a single number.
- Feedback in Release 1.x is clipboard-only — no new dependency (no url_launcher). Real mailto/URL launching may come after the Knowledge backend/CMS exists.
