# RFC-KB-002 Final Update (Final Review)

RFC-KB-002 is architecture-complete. The following refinements are frozen before implementation. No additional features. No redesign.

---

## 1. Use "Learning Hub" consistently

Replace every remaining occurrence of "Knowledge Browser" with "Learning Hub".

Product direction:

Coach → Learning Hub → Knowledge → Drill

Training Center is evolving into the Learning Hub, not a Knowledge Browser.

---

## 2. Knowledge must reference DrillLibrary, not wrap it

Do NOT model built-in drills as `KnowledgeItem(type: drill)`. Use references.

Knowledge → drillRef → DrillLibrary

KnowledgeRepository returns a KnowledgeItem plus resolved DrillReferences. DrillLibrary remains the single source of truth for drill content. This avoids duplicate representations and keeps domain boundaries clean.

Reinforced: **Drills are external referenced resources, not KnowledgeItems. `KnowledgeType` SHALL NOT contain `drill`. Any drill shown in the Learning Hub is resolved from DrillLibrary through `drillRefs`.**

---

## 3. estimatedSkillGain is a structured object

Per-skill weights, not a single number:

```
estimatedSkillGain: {
  cueBallControl: 80,
  stroke: 20,
  aiming: 10,
  positionPlay: 60
}
```

Coach can later rank recommendations by "which skills does this raise?" without changing the schema.

---

## 4. recommendedFor metadata

Each Knowledge item declares its intended player level(s):

```
recommendedFor: ["H", "G"]
```

Purpose: Coach avoids recommending beginner content to advanced players and vice versa. Recommendation metadata only — it does not affect Coach logic today.

---

## 5. Knowledge IDs are immutable

Once published, an `id` MUST NEVER change. If content changes substantially, create a new item and deprecate the old one. This protects Coach history, bookmarks, future CMS, analytics, and the recommendation cache.

---

## 6. Feedback decision

Release 1.x uses clipboard-only feedback. No new dependency (url_launcher) is introduced. Feedback buttons copy a structured template to the clipboard. Real mailto/URL launching may be introduced after the Knowledge backend/CMS exists.

---

After these refinements, RFC-KB-002 is frozen and implementation can begin.
