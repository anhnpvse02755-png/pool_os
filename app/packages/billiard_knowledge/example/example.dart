/// Example usage of the billiard_knowledge package.
///
/// Run this example to see the package in action.

import 'package:billiard_knowledge/billiard_knowledge.dart';

Future<void> main() async {
  // Initialize the library
  await BilliardKnowledge.initialize();
  
  print('=== Billiard Knowledge Library Demo ===\n');
  
  // Get repositories
  final repo = BilliardKnowledge.instance.repository;
  final search = BilliardKnowledge.instance.search;
  final rec = BilliardKnowledge.instance.recommendations;
  final pathRepo = BilliardKnowledge.instance.learningPathRepository;
  
  // ----- Knowledge Repository -----
  print('1. Knowledge Repository');
  print('-' * 40);
  
  // Get all categories
  final categories = repo.getCategories();
  print('Categories: ${categories.join(", ")}');
  
  // Get item count
  print('Total items: ${repo.count()}');
  
  // Get an item
  final item = await repo.byId('stroke.fundamentals');
  if (item != null) {
    print('Item: ${item.title}');
    print('  Vietnamese: ${item.titleVi}');
    print('  Difficulty: ${item.difficulty.displayName}');
    print('  Est. Time: ${item.estLearningMinutes} min');
    print('  Tags: ${item.tags.join(", ")}');
  }
  
  // ----- Search -----
  print('\n2. Search Service');
  print('-' * 40);
  
  final results = await search.search('stroke');
  print('Search "stroke": ${results.length} results');
  for (final result in results.take(3)) {
    print('  - ${result.item.title} (score: ${result.score.toStringAsFixed(2)})');
  }
  
  // ----- Recommendations -----
  print('\n3. Recommendation Service');
  print('-' * 40);
  
  final profile = PlayerProfile(
    id: 'demo_user',
    currentLevel: 'H',
    strengthAreas: {'stance'},
    weaknessAreas: {'aim'},
    completedItems: {},
    completedDrills: {},
    practiceHoursPerWeek: 3,
    goals: {'improve_accuracy'},
  );
  
  final goal = GoalContext(primaryGoal: LearningGoal.improveAccuracy);
  
  final recommendations = await rec.getRecommendations(
    profile: profile,
    goal: goal,
  );
  
  print('Related knowledge: ${recommendations.relatedKnowledge.length}');
  print('Recommended drills: ${recommendations.recommendedDrills.length}');
  print('Learning paths: ${recommendations.learningPaths.length}');
  
  // ----- Learning Paths -----
  print('\n4. Learning Path Repository');
  print('-' * 40);
  
  final paths = await pathRepo.getAll();
  print('Total paths: ${paths.length}');
  
  if (paths.isNotEmpty) {
    final firstPath = paths.first;
    print('First path: ${firstPath.name}');
    print('  Levels: ${firstPath.targetLevel}');
    print('  Phases: ${firstPath.phaseCount}');
    print('  Items: ${firstPath.totalItems}');
    print('  Duration: ${firstPath.totalHours} hours');
  }
  
  // ----- Relationship Resolver -----
  print('\n5. Relationship Resolver');
  print('-' * 40);
  
  final resolver = BilliardKnowledge.instance.relations;
  
  if (item != null) {
    final related = await resolver.getRelated(item.id);
    print('Related to "${item.title}": ${related.length}');
    for (final rel in related.take(3)) {
      print('  - ${rel.title}');
    }
  }
  
  // ----- Drill Loader -----
  print('\n6. Drill Loader');
  print('-' * 40);
  
  final drillLoader = BilliardKnowledge.instance.drillLoader;
  final allDrills = await drillLoader.getAllDrills();
  print('Total drills: ${allDrills.length}');
  
  final aimDrills = await drillLoader.getDrillsBySkill('aim');
  print('Aiming drills: ${aimDrills.length}');
  
  // ----- Categories -----
  print('\n7. Category Repository');
  print('-' * 40);
  
  final catRepo = BilliardKnowledge.instance.categoryRepository;
  final allCats = await catRepo.getAll();
  print('Total categories: ${allCats.length}');
  
  // ----- Tags -----
  print('\n8. Tag Repository');
  print('-' * 40);
  
  final tagRepo = BilliardKnowledge.instance.tagRepository;
  final allTags = await tagRepo.getAll();
  print('Total tags: ${allTags.length}');
  
  final popularTags = await tagRepo.mostUsed(5);
  print('Popular tags: ${popularTags.map((t) => t.name).join(", ")}');
  
  print('\n=== Demo Complete ===');
  
  // Cleanup
  await BilliardKnowledge.instance.dispose();
}
