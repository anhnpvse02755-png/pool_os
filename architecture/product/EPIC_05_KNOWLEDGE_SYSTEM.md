# EPIC 05 — Knowledge System

Status:
Authorized

Roadmap:
Roadmap V3 (Beta)

Owner:
Product Owner

Priority:
High

Dependencies:

- Foundation Features 001–012
- EPIC 01 — Match Engine
- EPIC 02 — Statistics & Analytics
- EPIC 03 — Training System

No dependency on League/Tournament.

---

# 1. Objective

Build the complete Knowledge System for Pool OS Beta.

This Epic integrates the existing Billiard Knowledge Module into Pool OS.

The system is read-oriented.

- No AI.
- No recommendation engine.
- No prediction.
- No coaching logic.

Knowledge is the single source of truth for future AI modules after M22.

---

# 2. Deliverables

## 2.1 Knowledge Library

- Knowledge Browser
- Knowledge Detail
- Knowledge Metadata
- Aliases
- Keywords
- References
- Difficulty
- Tags
- Language
- Relationships

Read-only.

## 2.2 Categories

- Hierarchical Categories
- Category Navigation
- Category Statistics
- Category Filter

## 2.3 Search

- Full-text Search
- Keyword Search
- Alias Search
- Tag Search
- Category Filter
- Difficulty Filter
- Language Filter
- Recent Search
- Search History
- Search Result Ranking

No AI ranking. Only deterministic scoring.

## 2.4 Learning Path

- Learning Path Browser
- Learning Path Detail
- Progress (read-only)
- Completed
- Estimated Hours
- Required Skills
- Prerequisites
- Dependencies
- Learning Order

No automatic recommendation.

## 2.5 Pattern Library

- Pattern Browser
- Pattern Detail
- Pattern Categories
- Pattern Difficulty
- Pattern Tags
- Related Pattern
- Pattern Search
- Pattern Images (metadata only)

## 2.6 Articles

- Article Browser
- Article Detail
- Markdown Rendering
- References
- Related Knowledge
- Bookmark
- Read Status

## 2.7 Videos

- Video Browser
- Video Metadata
- Video Category
- Video Duration
- External URL
- Bookmark
- Watch Status

No embedded streaming engine.

## 2.8 Bookmark

- Bookmark Knowledge
- Bookmark Article
- Bookmark Video
- Bookmark Pattern
- Unified Bookmark List

## 2.9 Reading Progress

- Read
- Unread
- Completed
- Continue Reading
- History

---

# 3. Integration

Must integrate with:

- Training System
- Goal
- Lesson
- Coach Notes
- Pattern Library
- Statistics
- Player Timeline

…without circular dependency.

Knowledge remains read-only.

---

# 4. Architecture Rules

- Knowledge Repository
- Knowledge Search Service
- LearningPath Service
- Bookmark Service
- Progress Service
- Pattern Service

All services must be orchestration only.

- No business logic duplication.
- No AI.

---

# 5. Forbidden

- No AI
- No Recommendation
- No Coach
- No Prediction
- No LLM
- No Chat
- No RAG
- No Embedding
- No Vector Database
- No Online Sync
- No Cloud Search
- No Auto Translation
- No OCR

---

# 6. Existing Assets

Engineering must reuse existing assets whenever possible.

- Current Billiard Knowledge Database
- Knowledge JSON
- Learning Paths
- Categories
- Relationships
- Aliases
- Keywords
- Pattern Library
- Articles
- Video Metadata

No recreation. Only integration.

---

# 7. Out of Scope

- Knowledge Editing
- Knowledge Authoring
- Knowledge Approval Workflow
- Knowledge Versioning
- Collaborative Editing
- Community Upload
- Video Streaming
- Comment
- Rating
- Reaction
- Knowledge Marketplace

All postponed after Beta.

---

# 8. Acceptance Criteria

- Knowledge Browser functional
- Category Browser functional
- Search functional
- Learning Path functional
- Pattern Library functional
- Article Browser functional
- Video Browser functional
- Bookmark functional
- Reading Progress functional
- Statistics integration functional
- No duplicated data
- No AI
- No regression
- Architecture Fitness maintained

---

# 9. Engineering Workflow

```
Engineering Implementation
        ↓
Engineering Self Verification
        ↓
Single Engineering Report
        ↓
Single Full Regression
        ↓
Product Owner Review
        ↓
Merge
        ↓
Close EPIC
```

- No intermediate feature closure.
- No partial regression.
- Exactly one EPIC close.

---

# PO Notes for Engineering

1. **Ưu tiên tích hợp, không tạo lại dữ liệu**. Tái sử dụng toàn bộ
   Billiard Knowledge Module đã có (knowledge items, categories, learning
   paths, pattern library, aliases, keywords, relationships…).
2. **Read-only Beta**. Không xây editor, workflow biên tập hay cộng tác.
3. **Không AI dưới mọi hình thức**. Chỉ search và hiển thị theo dữ liệu
   hiện có.
4. **Chỉ một lần kiểm thử và đóng Epic**:
   - Engineering
   - Engineering Report
   - Full Regression
   - PO Review
   - Merge
   - Close EPIC

Đây sẽ là **Epic cuối cùng để hoàn thiện lớp tri thức (Knowledge Layer)**
trước khi chuyển sang các Epic còn lại của Roadmap V3 Beta.