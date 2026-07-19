import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';

/// Resolves a Coach-owned KnowledgeId into an existing product destination.
/// Screens render the decision and delegate navigation here; they never choose
/// a different article or drill on Coach's behalf.
void navigateCoachAction(BuildContext context, CoachAction action) {
  final articleId = KnowledgeRegistry.articleFor(action.knowledgeId);
  if (articleId != null) {
    context.push(
      '/training-center?knowledgeId=${Uri.encodeComponent(articleId)}',
    );
    return;
  }

  final destination = KnowledgeRegistry.resolve(action.knowledgeId);
  final route = KnowledgeRegistry.routeFor(action.knowledgeId);
  if (route == null) return;

  final category = destination?.drillCategory;
  if (category != null) {
    final hasDrills = DrillLibrary.getDrillsByCategory(category).isNotEmpty;
    context.push(
      hasDrills ? '$route?category=${Uri.encodeComponent(category)}' : route,
    );
    return;
  }

  if (KnowledgeRegistry.isBranch(action.knowledgeId)) {
    context.go(route);
  } else {
    context.push(route);
  }
}
