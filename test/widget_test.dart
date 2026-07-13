import 'package:flutter_test/flutter_test.dart';

import 'package:mindtrap_ai/main.dart';

void main() {
  testWidgets('shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const MindTrapApp());

    expect(find.text('MindTrap AI'), findsOneWidget);
  });
}
