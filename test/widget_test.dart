import 'package:flutter_test/flutter_test.dart';
import 'package:spotly_fresh/main.dart';
import 'package:spotly_fresh/widgets/brand_logo.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that splash screen contains the BrandLogo.
    expect(find.byType(BrandLogo), findsOneWidget);

    // Run the splash screen timer to completion to prevent pending timer leaks.
    await tester.pump(const Duration(seconds: 3));
  });
}
