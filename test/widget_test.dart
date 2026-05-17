import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewing_workshop/app.dart';

void main() {
  testWidgets('Splash shows workshop branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SewingWorkshopApp(),
      ),
    );

    expect(find.text('Sewing Workshop'), findsOneWidget);
  });
}
