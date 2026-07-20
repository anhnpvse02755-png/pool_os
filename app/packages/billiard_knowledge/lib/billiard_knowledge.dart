/// Billiard Knowledge Library
/// 
/// A comprehensive billiard and pool knowledge library providing:
/// - Structured knowledge models (techniques, mistakes, strategies)
/// - Search functionality with offline support
/// - Learning path management
/// - Skill recommendations
/// - Drill mappings
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:billiard_knowledge/billiard_knowledge.dart';
/// 
/// // Initialize the library
/// await BilliardKnowledge.initialize();
/// 
/// // Get knowledge repository
/// final repo = BilliardKnowledge.repository;
/// 
/// // Search for knowledge items
/// final results = await repo.search('draw shot');
/// 
/// // Get a specific item
/// final item = await repo.byId('stroke.fundamentals');
/// ```
/// 
/// ## Architecture
/// 
/// ```
/// ┌─────────────────────────────────────────────────────────┐
/// │                   Public API                            │
│ │  BilliardKnowledge (Entry Point)                        │
│ └────────────────────────┬────────────────────────────────┘
///                          │
///         ┌────────────────┼────────────────┐
///         ▼                ▼                ▼
///    ┌─────────┐    ┌───────────┐    ┌────────────┐
///    │Repository│    │ Services  │    │  Loaders   │
///    │          │    │           │    │            │
///    │- Knowledge│    │- Search   │    │- Asset     │
///    │- Learning │    │- Recom-   │    │- Drill     │
///    │  Path     │    │  mendation│    │- Path      │
///    │- Category │    │- Relation │    │            │
///    │- Tag      │    │           │    │            │
///    └─────────┘    └───────────┘    └────────────┘
/// ```
library billiard_knowledge;

export 'src/billiard_knowledge.dart';
