# Knowledge Viewer Specification

## Overview

**Document Date:** 2026-07-17  
**Component:** Knowledge Viewer  
**Type:** Specification / Data Flow Design  
**Status:** Design Only - No UI Implementation

---

## Purpose

The Knowledge Viewer displays a single knowledge article with all related content: definitions, media, mistakes, drills, learning paths, and cross-references.

---

## Component Structure

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        KnowledgeViewerPage                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Header Section                                │    │
│  │  ┌─────────────────┐  ┌────────────────────────────────────┐  │    │
│  │  │  Back Button     │  │  Breadcrumb: Home > Category > Item │  │    │
│  │  └─────────────────┘  └────────────────────────────────────┘  │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐  │    │
│  │  │  Title (EN)                           [Difficulty Badge] │  │    │
│  │  │  Title (VI)                                           │  │    │
│  │  │  [Status Badge] [Type Badge] [Estimated Time]        │  │    │
│  │  └─────────────────────────────────────────────────────────┘  │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Media Section                                  │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐               │    │
│  │  │  Image  │ │  Video  │ │   GIF   │ │ Diagram │               │    │
│  │  │   1     │ │   1     │ │   1     │ │   1     │   [Gallery] │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Definition Section                            │    │
│  │                                                                  │    │
│  │  Summary                                                         │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  One-paragraph overview of the knowledge item...        │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  │  Purpose                                                         │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Why this skill matters and when to use it...          │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Learning Section                               │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Setup                                                │   │    │
│  │  │  • Step 1                                             │   │    │
│  │  │  • Step 2                                             │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Execution                                              │   │    │
│  │  │  • Step 1                                             │   │    │
│  │  │  • Step 2                                             │   │    │
│  │  │  • Step 3                                             │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Success Criteria                                        │   │    │
│  │  │  ✓ Criteria 1                                          │   │    │
│  │  │  ✓ Criteria 2                                          │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Common Mistakes Section                        │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  ⚠ Mistake 1                                           │   │    │
│  │  │  └─ Correction 1                                        │   │    │
│  │  │                                                         │   │    │
│  │  │  ⚠ Mistake 2                                           │   │    │
│  │  │  └─ Correction 2                                        │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Drills Section                                 │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  [D001] Drill Name                          ⭐⭐⭐       │   │    │
│  │  │  Brief description...                                    │   │    │
│  │  │  [Start Drill ▶]                                       │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  [D002] Another Drill                       ⭐⭐        │   │    │
│  │  │  Brief description...                                    │   │    │
│  │  │  [Start Drill ▶]                                       │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Related Knowledge Section                      │    │
│  │                                                                  │    │
│  │  Prerequisites (What to learn first)                            │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │    │
│  │  │ Prereq 1   │ │ Prereq 2   │ │ Prereq 3   │  [+3 more]    │    │
│  │  │ [View →]   │ │ [View →]   │ │ [View →]   │               │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘               │    │
│  │                                                                  │    │
│  │  Related Skills                                                  │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │    │
│  │  │ Related 1   │ │ Related 2   │ │ Related 3   │  [+5 more]    │    │
│  │  │ [View →]   │ │ [View →]   │ │ [View →]   │               │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘               │    │
│  │                                                                  │    │
│  │  Next Skills (What to learn after)                             │    │
│  │  ┌─────────────┐ ┌─────────────┐                               │    │
│  │  │ Next 1      │ │ Next 2      │               [+2 more]       │    │
│  │  │ [View →]   │ │ [View →]   │                               │    │
│  │  └─────────────┘ └─────────────┘                               │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Learning Path Section                         │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Part of: Complete Beginner Path                        │   │    │
│  │  │  Phase 2: Basic Aiming                                  │   │    │
│  │  │                                                          │   │    │
│  │  │  Progress: ████████░░░░░░░░ 40%                        │   │    │
│  │  │                                                          │   │    │
│  │  │  [View Full Path →]                                     │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    References Section                            │    │
│  │                                                                  │    │
│  │  Sources:                                                       │    │
│  │  • Source 1 (internal)                                          │    │
│  │  • Source 2 (internal)                                          │    │
│  │                                                                  │    │
│  │  Coach Notes:                                                   │    │
│  │  ┌─────────────────────────────────────────────────────────┐   │    │
│  │  │  Additional coaching tips for instructors...           │   │    │
│  │  └─────────────────────────────────────────────────────────┘   │    │
│  │                                                                  │    │
│  │  Version: 1.0.0 | Last Updated: 2026-07-17                     │    │
│  │                                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Data Flow Architecture                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────┐                                                        │
│   │   Route     │  /knowledge/:id                                       │
│   │   Params    │  └── id: "stroke.fundamentals"                        │
│   └──────┬──────┘                                                        │
│          │                                                               │
│          ▼                                                               │
│   ┌─────────────────────────────────────────────────────────────────┐    │
│   │                    KnowledgeRepository                           │    │
│   │  ┌─────────────────────────────────────────────────────────┐  │    │
│   │  │  getById(id) → KnowledgeItem                            │  │    │
│   │  │  related(item) → List<KnowledgeItem>                    │  │    │
│   │  │  drillsFor(item) → List<Drill>                         │  │    │
│   │  └─────────────────────────────────────────────────────────┘  │    │
│   └──────┬────────────────┬────────────────────┬───────────────────┘    │
│          │                │                    │                        │
│          ▼                ▼                    ▼                        │
│   ┌─────────────┐  ┌─────────────┐     ┌─────────────┐               │
│   │ KnowledgeItem│  │ RelatedItems│     │ DrillLibrary │               │
│   │   (main)    │  │   (graph)    │     │   (drills)   │               │
│   └──────┬──────┘  └──────┬──────┘     └──────┬──────┘               │
│          │                │                    │                        │
│          ▼                ▼                    ▼                        │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                   KnowledgeViewerBloc                             │  │
│   │  ┌───────────────────────────────────────────────────────────┐ │  │
│   │  │  States:                                                  │ │  │
│   │  │  - Initial                                                │ │  │
│   │  │  - Loading                                                │ │  │
│   │  │  - Loaded(viewState)                                      │ │  │
│   │  │  - Error(message)                                         │ │  │
│   │  └───────────────────────────────────────────────────────────┘ │  │
│   │                                                                  │  │
│   │  ┌───────────────────────────────────────────────────────────┐ │  │
│   │  │  ViewState:                                               │ │  │
│   │  │  - mainItem: KnowledgeItem                               │ │  │
│   │  │  - prerequisites: List<KnowledgeItem>                    │ │  │
│   │  │  - relatedItems: List<KnowledgeItem>                     │ │  │
│   │  │  - nextItems: List<KnowledgeItem>                        │ │  │
│   │  │  - drills: List<Drill>                                   │ │  │
│   │  │  - learningPath: LearningPath?                           │ │  │
│   │  │  - progress: double                                       │ │  │
│   │  │  - mediaItems: List<MediaItem>                           │ │  │
│   │  └───────────────────────────────────────────────────────────┘ │  │
│   └──────┬────────────────┬────────────────────┬───────────────────┘  │
│          │                │                    │                        │
│          ▼                ▼                    ▼                        │
│   ┌─────────────┐  ┌─────────────┐     ┌─────────────┐               │
│   │   Section   │  │   Section   │     │   Section   │               │
│   │  Renderers  │  │  Renderers  │     │  Renderers   │               │
│   └─────────────┘  └─────────────┘     └─────────────┘               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. Header Section

**Data Required:**

```dart
class HeaderData {
  String id;                    // "stroke.fundamentals"
  String title;                // "Stroke Fundamentals"
  String titleVi;              // "Nhát đánh cơ bản"
  KnowledgeDifficulty difficulty; // beginner/intermediate/advanced/professional
  KnowledgeType type;           // technique/mistake/strategy/equipment/mental
  KnowledgeStatus status;       // verified/beta/draft
  int estLearningMinutes;       // 30
  String category;             // "stroke"
  List<String> keywords;        // ["stroke", "swing", "delivery"]
}
```

**Components:**
- `BackButton` - Navigate back
- `BreadcrumbNav` - Category navigation
- `TitleDisplay` - Bilingual title
- `BadgeRow` - Difficulty, type, status badges
- `MetadataRow` - Time estimate, keywords

### 2. Media Section

**Data Required:**

```dart
class MediaData {
  KnowledgeMedia media;         // From KnowledgeItem
  List<String> images;          // Local asset paths
  List<String> videos;         // Video URLs
  List<String> gifs;           // Animated demonstrations
  List<String> diagrams;        // Technical diagrams
}
```

**Components:**
- `MediaGallery` - Horizontal scrollable gallery
- `MediaViewer` - Full-screen media viewer
- `ImageCard` - Thumbnail with lightbox
- `VideoPlayer` - Embedded video player
- `DiagramDisplay` - SVG/PNG diagram renderer
- `ComingSoonBadge` - Placeholder for missing media

### 3. Definition Section

**Data Required:**

```dart
class DefinitionData {
  String summary;               // One-paragraph overview
  String purpose;              // Why this matters
  String coachNotes;           // Instructor-only notes (if auth)
}
```

**Components:**
- `SectionCard` - Styled container
- `SummaryText` - Formatted summary
- `PurposeText` - Formatted purpose with highlights
- `CoachNotesAccordion` - Expandable instructor notes

### 4. Learning Section

**Data Required:**

```dart
class LearningData {
  List<String> setup;           // Setup steps
  List<String> execution;       // Execution steps
  List<String> successCriteria; // Success indicators
  List<String> failureCriteria; // Failure indicators
  List<String> corrections;     // Common corrections
}
```

**Components:**
- `StepList` - Numbered/w bulleted steps
- `StepCard` - Individual step display
- `CriteriaList` - Success/failure criteria
- `CorrectionPair` - Mistake + Correction display
- `ProgressIndicator` - Visual step tracker

### 5. Common Mistakes Section

**Data Required:**

```dart
class MistakesData {
  List<String> commonMistakes;  // What players do wrong
  List<String> corrections;      // How to fix
}
```

**Components:**
- `MistakeCard` - Warning icon + mistake text
- `CorrectionBadge` - Solution text
- `MistakeAccordion` - Expandable details
- `TipHighlight` - Pro tips

### 6. Drills Section

**Data Required:**

```dart
class DrillsData {
  List<Drill> drills;          // From DrillLibrary
  Map<String, DrillProgress> progress; // User progress
}
```

**Components:**
- `DrillCard` - Drill preview card
- `DrillMetadata` - Code, difficulty, time
- `ProgressBar` - User's drill progress
- `StartDrillButton` - Navigation to drill
- `EmptyDrillsState` - "No drills available" message

### 7. Related Knowledge Section

**Data Required:**

```dart
class RelatedKnowledgeData {
  List<KnowledgeItem> prerequisites;  // Items to learn first
  List<KnowledgeItem> relatedItems;  // Items to learn together
  List<KnowledgeItem> nextItems;     // Items to learn after
  List<KnowledgeRef> references;     // Graph edges
}
```

**Components:**
- `KnowledgeCard` - Compact knowledge preview
- `CategoryChip` - Category indicator
- `DifficultyBadge` - Skill level indicator
- `NavigationArrow` - "View" CTA
- `SeeMoreChips` - "+X more" overflow

### 8. Learning Path Section

**Data Required:**

```dart
class LearningPathData {
  LearningPath? path;              // Current path
  LearningPhase? phase;            // Current phase
  double progress;                 // 0.0 - 1.0
  int currentStep;                 // 2 of 8
  List<LearningItemOrder> pathItems; // All items in path
}
```

**Components:**
- `PathProgressCard` - Current path info
- `ProgressBar` - Visual progress
- `PhaseIndicator` - Which phase
- `ViewPathButton` - Full path navigation
- `NextInPathChip` - What's next

### 9. References Section

**Data Required:**

```dart
class ReferencesData {
  List<String> sources;            // Internal sources
  String coachNotes;               // Instructor notes
  String knowledgeVersion;         // "1.0.0"
  DateTime? updatedAt;             // Last update
  String? verifiedBy;              // Who verified
}
```

**Components:**
- `SourceList` - Citation list
- `VersionInfo` - Version display
- `LastUpdatedBadge` - Date indicator
- `VerifiedByChip` - Author/verifier

---

## Bloc Structure

```dart
// Events
abstract class KnowledgeViewerEvent {}

class LoadKnowledge extends KnowledgeViewerEvent {
  final String id;
}

class RefreshKnowledge extends KnowledgeViewerEvent {}

class ToggleCoachMode extends KnowledgeViewerEvent {}

// States
abstract class KnowledgeViewerState {}

class KnowledgeViewerInitial extends KnowledgeViewerState {}

class KnowledgeViewerLoading extends KnowledgeViewerState {}

class KnowledgeViewerLoaded extends KnowledgeViewerState {
  final KnowledgeViewState viewState;
}

class KnowledgeViewerError extends KnowledgeViewerState {
  final String message;
}

// View State
class KnowledgeViewState {
  final KnowledgeItem mainItem;
  final List<KnowledgeItem> prerequisites;
  final List<KnowledgeItem> relatedItems;
  final List<KnowledgeItem> nextItems;
  final List<Drill> drills;
  final LearningPath? learningPath;
  final LearningPhase? currentPhase;
  final double pathProgress;
  final MediaState mediaState;
  final bool showCoachNotes;
  final List<String> matchedMistakes;
}
```

---

## Repository Methods

```dart
class KnowledgeRepository {
  // ... existing methods ...

  /// Get item with all related data for viewer
  Future<KnowledgeViewState> getViewState(String id) async {
    final item = await byId(id);
    if (item == null) throw Exception('Not found');

    final all = await getAll();
    
    // Load prerequisites
    final prerequisites = await byIds(item.prerequisites);
    
    // Load related items
    final relatedIds = item.relatedKnowledge.map((r) => r.id);
    final relatedItems = await byIds(relatedIds);
    
    // Load next items from recommendations
    final nextItems = item.nextRecommended != null 
        ? [await byId(item.nextRecommended!.id)].whereType<KnowledgeItem>().toList()
        : [];
    
    // Load drills
    final drills = drillsFor(item);
    
    // Load learning path info
    final learningPath = await _loadLearningPathFor(item);
    
    return KnowledgeViewState(
      mainItem: item,
      prerequisites: prerequisites,
      relatedItems: relatedItems,
      nextItems: nextItems,
      drills: drills,
      learningPath: learningPath?.$1,
      currentPhase: learningPath?.$2,
      pathProgress: await _calculateProgress(learningPath?.$1, item),
    );
  }

  /// Calculate progress for an item in a learning path
  Future<double> _calculateProgress(LearningPath? path, KnowledgeItem item) async {
    if (path == null) return 0.0;
    
    final allPathItems = path.phases
        .expand((p) => p.knowledgeOrder)
        .map((o) => o.skillId)
        .toList();
    
    final currentIndex = allPathItems.indexOf(item.skillId ?? item.id);
    if (currentIndex < 0) return 0.0;
    
    return currentIndex / allPathItems.length;
  }
}
```

---

## Provider Structure

```dart
// Main provider
final knowledgeViewerProvider = 
    StateNotifierProvider.family<KnowledgeViewerBloc, KnowledgeViewerState, String>(
  (ref, id) => KnowledgeViewerBloc(
    ref.watch(knowledgeRepositoryProvider),
    ref.watch(drillMappingLoaderProvider),
    ref.watch(learningPathLoaderProvider),
    id,
  ),
);

// Supporting providers
final knowledgeMediaProvider = Provider.family<MediaState, String>((ref, id) {
  final bloc = ref.watch(knowledgeViewerProvider(id));
  if (bloc is KnowledgeViewerLoaded) {
    return bloc.viewState.mediaState;
  }
  return MediaState.empty;
});

final knowledgeProgressProvider = Provider.family<double, String>((ref, id) {
  final bloc = ref.watch(knowledgeViewerProvider(id));
  if (bloc is KnowledgeViewerLoaded) {
    return bloc.viewState.pathProgress;
  }
  return 0.0;
});
```

---

## Widget Components

### Core Widgets

| Widget | Description |
|--------|-------------|
| `KnowledgeViewerPage` | Main page wrapper |
| `KnowledgeHeader` | Title, badges, metadata |
| `KnowledgeMediaGallery` | Image/video/gif display |
| `KnowledgeDefinition` | Summary and purpose |
| `KnowledgeLearningSteps` | Setup and execution |
| `KnowledgeMistakes` | Common mistakes display |
| `KnowledgeDrills` | Drill cards list |
| `KnowledgeRelatedItems` | Related knowledge grid |
| `KnowledgeLearningPath` | Path progress card |
| `KnowledgeReferences` | Sources and version |

### Reusable Widgets

| Widget | Description |
|--------|-------------|
| `KnowledgeCard` | Compact knowledge preview |
| `DrillCard` | Drill preview card |
| `DifficultyBadge` | Skill level badge |
| `StatusBadge` | Verified/beta/draft |
| `StepList` | Numbered steps display |
| `CriteriaList` | Success/failure criteria |
| `MediaGallery` | Scrollable media gallery |
| `ProgressBar` | Visual progress indicator |

---

## Navigation

### Routes

```
/knowledge/:id                    → KnowledgeViewerPage
/knowledge/:id/drill/:drillId     → DrillPage (with pre-selected drill)
/knowledge/:id/path/:pathId       → LearningPathPage (highlighted item)
/knowledge/:id/mistake/:mistakeId → KnowledgePage (mistake item)
```

### Deep Links

```
poolos://knowledge/stroke.fundamentals
poolos://knowledge/stroke.fundamentals?from=drill/D001
poolos://knowledge/stroke.fundamentals?from=path/complete_beginner
```

---

## Error States

| State | Message | Action |
|-------|---------|--------|
| Not Found | "This knowledge article doesn't exist" | Go back button |
| Load Error | "Failed to load content" | Retry button |
| No Drills | "No practice drills available yet" | Show placeholder |
| No Related | "No related content" | Hide section |
| Media Missing | "Media coming soon" | Show placeholder |

---

## Loading States

| Section | Skeleton |
|---------|----------|
| Header | Title + badges skeleton |
| Media | Grid placeholder |
| Definition | Text line skeletons |
| Learning | Step card skeletons |
| Mistakes | Accordion skeletons |
| Drills | Card skeletons |
| Related | Grid skeletons |
| Path | Progress bar skeleton |

---

## Localization

All text supports bilingual display:

```dart
class KnowledgeViewerText {
  static const en = {
    'summary': 'Summary',
    'purpose': 'Purpose',
    'setup': 'Setup',
    'execution': 'How to Execute',
    'success': 'Success Criteria',
    'commonMistakes': 'Common Mistakes',
    'recommendedDrills': 'Recommended Drills',
    'relatedKnowledge': 'Related Knowledge',
    'prerequisites': 'Prerequisites',
    'nextSkills': 'Next Skills',
    'learningPath': 'Learning Path',
    'sources': 'Sources',
    'version': 'Version',
  };

  static const vi = {
    'summary': 'Tóm tắt',
    'purpose': 'Mục đích',
    'setup': 'Chuẩn bị',
    'execution': 'Cách thực hiện',
    'success': 'Tiêu chí thành công',
    'commonMistakes': 'Lỗi thường gặp',
    'recommendedDrills': 'Bài tập đề xuất',
    'relatedKnowledge': 'Kiến thức liên quan',
    'prerequisites': 'Điều kiện tiên quyết',
    'nextSkills': 'Kỹ năng tiếp theo',
    'learningPath': 'Lộ trình học',
    'sources': 'Nguồn tham khảo',
    'version': 'Phiên bản',
  };
}
```

---

## Accessibility

| Feature | Implementation |
|---------|---------------|
| Screen Reader | Semantic labels for all sections |
| Keyboard Nav | Tab through sections, Enter to expand |
| Color Contrast | WCAG AA compliant |
| Font Size | Responsive text scaling |
| Focus Indicators | Visible focus rings |
| Alt Text | All media has descriptions |

---

*Generated: 2026-07-17*
*Knowledge Viewer Specification v1.0*
