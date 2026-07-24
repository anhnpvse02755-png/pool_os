import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/knowledge/application/knowledge_mvp_service.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_detail_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_library_screen.dart';

import 'knowledge_mvp_service_test.dart' show testKnowledgeCatalog;

void main() {
  testWidgets('browses Home, Learning Path, category, search, and detail',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          knowledgeMvpServiceProvider.overrideWithValue(
            KnowledgeMvpService(() async => testKnowledgeCatalog),
          ),
          knowledgeCatalogProvider.overrideWith(
            (ref) async => testKnowledgeCatalog,
          ),
        ],
        child: const MaterialApp(home: KnowledgeLibraryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Control Path'), findsOneWidget);
    expect(find.text('Safety Objective'), findsOneWidget);

    final pathStep = find.widgetWithText(ActionChip, 'Stop Shot');
    await tester.ensureVisible(pathStep);
    await tester.tap(pathStep);
    await tester.pumpAndSettle();
    expect(find.byType(KnowledgeDetailScreen), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ChoiceChip, 'Techniques (1)'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stop Shot'), findsOneWidget);
    expect(find.text('Safety Objective'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.enterText(find.byType(SearchBar), 'safety');
    await tester.pumpAndSettle();
    expect(find.text('Safety Objective'), findsOneWidget);
    expect(find.text('Stop Shot'), findsNothing);
  });

  test('Coach article IDs remain valid Knowledge targets', () {
    expect(testKnowledgeCatalog.entryById('control.stop_shot'), isNotNull);
  });
}
