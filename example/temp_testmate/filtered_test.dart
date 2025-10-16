import 'package:flutter_test/flutter_test.dart' hide group, testWidgets, expect;
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:flutter_testmate/testmate.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      testWidgets('Anoother Group Test Case Two',
          (WidgetTester tester) async {
        // No need to call SafeExpect.startTest - it's automatic now!

        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text("Dashboard"), findsOneWidget);
        expect(find.text("Dashboard"), findsOneWidget);

        // Record test result and fail if needed
        SafeExpect.failIfAnyFailed();
      },tags: ['smoke']);


  // Print and save all test results as JSON at the end
  tearDownAll(() {
    SafeExpect
        .printAndSaveTestResults(); // This will both print and save to testmate-reports/report.json
  });
}
