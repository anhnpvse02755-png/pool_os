import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/coach/presentation/coach_screen.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

void main() {
  testWidgets('runs a structured Coach conversation end to end',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [coachOutputProvider.overrideWith((ref) async => _output)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('vi')],
          home: CoachScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No messages yet'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Do this next').first,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('coach.conversation.turn.1')),
      findsOneWidget,
    );
    expect(find.text('Practice this'), findsWidgets);

    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Coach understanding'),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('coach.conversation.turn.2')),
      findsOneWidget,
    );
    expect(find.text('Coach understanding 75%'), findsOneWidget);
  });
}

const _output = CoachOutput(
  level: PlayerLevel(
    levelKey: 'coach_v2_level_intermediate',
    levelConfidence: 0.8,
  ),
  understanding: CoachUnderstanding(
    dataCompleteness: 0.75,
    missing: [FindingSource.readiness],
  ),
  primaryAction: CoachAction(
    labelKey: 'coach_v2_action_practice',
    knowledgeId: 'technique.stop-shot',
  ),
);
