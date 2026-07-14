import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindtrap_ai/app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) {
    return tester.pumpWidget(const ProviderScope(child: MindTrapApp()));
  }

  testWidgets('Play opens gameplay and Home exits safely', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(find.text('MindTrap AI'), findsNWidgets(2));
  });

  testWidgets('navigates to Profile', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Brain Profile'), findsOneWidget);
    expect(find.text('Not enough data yet'), findsOneWidget);
  });
}
