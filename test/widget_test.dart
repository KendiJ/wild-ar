import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wild_ar/main.dart';

void main() {
  testWidgets('WildArApp renders ArDashboardScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WildArApp(),
      ),
    );

    // Verify app title and the 4 clean navigation buttons are rendered
    expect(find.text('Wild AR'), findsOneWidget);
    expect(find.text('AR Road Wildlife (Live Camera)'), findsOneWidget);
    expect(find.text('Sensorama'), findsOneWidget);
    expect(find.text('Image Recognition'), findsOneWidget);
    expect(find.text('Sword of Damocles'), findsOneWidget);
  });
}
