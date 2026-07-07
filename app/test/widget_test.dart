import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PoolOSApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
