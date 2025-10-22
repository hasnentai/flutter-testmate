import 'package:flutter_test/flutter_test.dart' hide group, testWidgets, expect;
import 'package:flutter_testmate/flutter_testmate.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import '../utils/other_key.dart';

runTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Taxpayer Form Integration Tests', () {
    testWidgets('Test 1: Should enter text in PAN field',
        (WidgetTester tester) async {
      // No need to call SafeExpect.startTest - it's automatic now!

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // NEW SIMPLIFIED SYNTAX - Just use expect() directly!
      // No need for SafeExpect.catchError() wrapper anymore
      final panLabel = find.text('First Name1');
      expect(panLabel, findsOneWidget);

      final panLabel1 = find.text('First Name2');
      expect(panLabel1, findsOneWidget);

      final lastName = find.text('Middle Name');
      expect(lastName, findsOneWidget);

      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Should have form elements', (WidgetTester tester) async {
      // No need to call SafeExpect.startTest - it's automatic now!

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final panLabel = find.text('First Name');
      expect(panLabel, findsOneWidget);

      final lastName = find.text('Middle Name');
      expect(lastName, findsOneWidget);

      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });
  });

  group('Anoother Group', () {
    testWidgets('Anoother Group Test Case One', (WidgetTester tester) async {
      // No need to call SafeExpect.startTest - it's automatic now!

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Use the simplified expect() syntax
      final panLabel = find.text('First Name');
      expect(panLabel, findsOneWidget);

      final lastName = find.text('Middle Name');
      expect(lastName, findsOneWidget);

      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Anoother Group Test Case Two', (WidgetTester tester) async {
      // No need to call SafeExpect.startTest - it's automatic now!

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("Dashboard"), findsOneWidget);
      expect(find.text("Dashboard"), findsOneWidget);

      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    }, tags: [
      'smoke',
      'login',
      'login-feature-test',
      'login-feature-test-case-two'
    ]);
  });

  // Print and save all test results as JSON at the end
  tearDownAll(() {
    SafeExpect
        .printAndSaveTestResults(); // This will both print and save to testmate-reports/report.json
  });
}
