# RFC-020 - Definition of Done (DoD)

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

This document defines the minimum acceptance criteria for Pool OS V2.

Cursor MUST NOT consider V2 complete until every checklist item passes.

Every feature must be fully functional.

No placeholder.

No TODO.

No mock data.

No hardcoded Coach.

---

# General Requirements

□ Application builds successfully.

□ Android APK builds successfully.

□ No compilation warnings.

□ No runtime exceptions.

□ No broken navigation.

□ No dead buttons.

□ No TODO left in production code.

□ No mock statistics.

□ No hardcoded Coach messages.

□ Vietnamese translation completed.

---

# Dashboard

□ Dashboard loads under 1 second.

□ Daily Readiness displayed.

□ Coach Card displayed.

□ Today's Training displayed.

□ Skill Radar displayed.

□ Weekly Progress displayed.

□ Equipment Status displayed.

□ Recent Sessions displayed.

□ Quick Statistics displayed.

□ Dashboard refreshes automatically.

---

# Player Module

□ Add Player works.

□ Edit Player works.

□ Delete Player works.

□ Validation works.

□ Search works.

□ Statistics linked.

□ Equipment linked.

---

# Equipment Module

□ Add Cue.

□ Edit Cue.

□ Delete Cue.

□ Add Shaft.

□ Edit Shaft.

□ Add Tip.

□ Edit Tip.

□ Brand Search.

□ Model Search.

□ Equipment History.

□ Equipment Statistics.

---

# Session Module

□ Create Session.

□ Edit Session.

□ Delete Session.

□ Finish Session.

□ Session Summary generated.

□ Statistics updated.

□ Coach updated.

---

# Match Module

□ Create Match.

□ Edit Match.

□ Delete Match.

□ Finish Match.

□ Match Summary generated.

□ Timeline generated.

---

# Rack Module

□ Create Rack.

□ Win works.

□ Lose works.

□ Popup Summary appears.

□ Balls Potted saved.

□ Biggest Mistake saved.

□ Biggest Strength saved.

□ Confidence saved.

□ Events saved.

□ Statistics updated immediately.

---

# Statistics

□ Overall Statistics.

□ Break Statistics.

□ Potting Statistics.

□ Position Statistics.

□ Safety Statistics.

□ Cue Ball Statistics.

□ Mental Statistics.

□ Equipment Statistics.

□ Weekly Trend.

□ Monthly Trend.

□ Lifetime Trend.

---

# Coach

□ Coach uses Statistics only.

□ Coach uses Rule Engine.

□ Coach never uses hardcoded text.

□ Coach explains WHY.

□ Coach recommends drills.

□ Coach generates daily plan.

□ Coach generates session review.

□ Coach generates match review.

□ Coach supports Vietnamese.

---

# Daily Readiness

□ Sleep.

□ Energy.

□ Stress.

□ Confidence.

□ Recovery.

□ Save works.

□ Dashboard refreshes.

□ Coach refreshes.

---

# Training

□ Warmup.

□ Main Drill.

□ Secondary Drill.

□ Pressure Drill.

□ Cooldown.

□ Estimated Time.

□ Completion Tracking.

---

# Workflow

□ Create Session.

□ Create Match.

□ Record Rack.

□ Finish Match.

□ Finish Session.

□ Dashboard refresh.

No broken workflow.

---

# Search

□ Cue Brand Search.

□ Shaft Brand Search.

□ Tip Brand Search.

□ Player Search.

□ Session Search.

---

# Localization

□ All UI translated.

□ All Coach translated.

□ All Notifications translated.

□ No English hardcoded.

---

# Notifications

□ Session Reminder.

□ Training Reminder.

□ Recovery Reminder.

□ Equipment Reminder.

□ Weekly Summary.

---

# Offline

□ Offline Session.

□ Offline Match.

□ Offline Rack.

□ Sync after reconnect.

□ No data loss.

---

# Performance

□ Dashboard < 1 sec.

□ Session Save < 500 ms.

□ Match Save < 500 ms.

□ Rack Save < 300 ms.

□ Statistics Update < 1 sec.

---

# Database

□ No orphan records.

□ Foreign Keys valid.

□ Cascade rules correct.

□ Soft Delete works.

□ Migration works.

□ Backup works.

□ Restore works.

---

# Coach Acceptance

Coach recommendation must include

Observation

Evidence

Recommendation

Expected Improvement

Training Time

Drills

Coach must never output generic advice.

---

# APK Acceptance

□ APK installs successfully.

□ First launch successful.

□ Database initializes.

□ No crash.

□ All screens accessible.

□ Navigation works.

□ Session workflow complete.

□ Statistics generated.

□ Coach functional.

---

# Release Criteria

Pool OS V2 is considered COMPLETE only if

100% checklist passed.

No P0 bug.

No P1 bug.

No placeholder.

No mock data.

Coach functional.

Statistics functional.

Workflow complete.

APK stable.

---

# Final Definition of Done

Pool OS V2 is accepted only when a new user can

1. Create Player.

2. Add Equipment.

3. Complete Daily Readiness.

4. Create Session.

5. Create Match.

6. Record every Rack.

7. Finish Match.

8. Finish Session.

9. View Dashboard.

10. Receive Coach Recommendation.

11. Review Statistics.

12. Continue using the app the next day without any missing workflow.
