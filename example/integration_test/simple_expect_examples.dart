// example/integration_test/simple_expect_examples.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:testmate/testmate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple Expect Examples', () {
    
    // Example 1: Using SafeExpect.catchError() - Continue on failure (test passes)
    testWidgets('Example 1: Continue on failure', (WidgetTester tester) async {
      SafeExpect.clearFailures();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // All expects run, errors are printed, but test passes
      final panLabel = find.text('First Name');
      SafeExpect.catchError(() => expect(panLabel, findsOneWidget));

      final firstNameField = find.byType(TextField);
      SafeExpect.catchError(() => expect(firstNameField, findsOneWidget));

      final form = find.byType(Form);
      SafeExpect.catchError(() => expect(form, findsOneWidget));
    });

    // Example 1b: Fail test at the end if any expects failed
    testWidgets('Example 1b: Fail at end if any failed', (WidgetTester tester) async {
      SafeExpect.clearFailures();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));

      // This will fail the test if any expects above failed
      SafeExpect.failIfAnyFailed();
    });

    // Example 1c: Immediate failure (test stops on first failure)
    testWidgets('Example 1c: Immediate failure', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
      // This will fail the test immediately if the expect fails
      SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget), failTest: true);
      // This line won't run if the above expect fails
      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
    });

    // Example 2: Using extension method - Alternative approach
    testWidgets('Example 2: Extension method approach', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Use the extension method for a more fluent API
      find.text('First Name').expectSafe(findsOneWidget).printIfFailed();
      find.byType(TextField).expectSafe(findsOneWidget).printIfFailed();
      find.byType(Form).expectSafe(findsOneWidget).printIfFailed();
    });

    // Example 3: Using SafeExpect.all() for multiple expects
    testWidgets('Example 3: SafeExpect.all() approach', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Define all your expects in a list and execute them safely
      final results = SafeExpect.all([
        {
          'description': 'Find First Name label',
          'function': () => expect(find.text('First Name'), findsOneWidget),
        },
        {
          'description': 'Find TextField widget',
          'function': () => expect(find.byType(TextField), findsOneWidget),
        },
        {
          'description': 'Find Form widget',
          'function': () => expect(find.byType(Form), findsOneWidget),
        },
      ]);

      // Print summary of results
      print('Results: $results');
    });

    // Example 4: Using SafeExpect.allWithSummary() for detailed reporting
    testWidgets('Example 4: With summary reporting', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // This will automatically print a summary
      SafeExpect.allWithSummary([
        {
          'description': 'Find First Name label',
          'function': () => expect(find.text('First Name'), findsOneWidget),
        },
        {
          'description': 'Find TextField widget',
          'function': () => expect(find.byType(TextField), findsOneWidget),
        },
        {
          'description': 'Find Form widget',
          'function': () => expect(find.byType(Form), findsOneWidget),
        },
      ]);
    });

    // Example 5: Mixed approach - some with catch, some without
    testWidgets('Example 5: Mixed approach', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Critical expects that should fail the test
      final panLabel = find.text('First Name');
      expect(panLabel, findsOneWidget); // This will still fail the test if it fails

      // Non-critical expects that can fail without stopping the test
      SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
    });
  });
}
