// example/integration_test/json_example.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:testmate/testmate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login End to End', () {
    testWidgets('Check Welcome Message', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Check Welcome Message',
        testSuite: 'Login End to End',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('Welcome'), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(AppBar), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Check Profile Page', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Check Profile Page',
        testSuite: 'Login End to End',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Check Home Page', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Check Home Page',
        testSuite: 'Login End to End',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('Home'), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(Scaffold), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });
  });

  group('Login Error Message', () {
    testWidgets('Check For the Welcome message', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Check For the Welcome message',
        testSuite: 'Login Error Message',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // This expect will likely fail and be recorded
      SafeExpect.catchError(() => expect(find.byKey(const Key('welcome_card1')), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byKey(const Key('welcome_card2')), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Check For Error Messages', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Check For Error Messages',
        testSuite: 'Login Error Message',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('Error'), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(SnackBar), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });
  });

  // Print and save all test results as JSON at the end
  tearDownAll(() {
    print('\n' + '='*50);
    print('FINAL TEST RESULTS JSON:');
    print('='*50);
    SafeExpect.printAndSaveTestResults(); // This will both print and save to testmate-reports/report.json
    print('='*50);
  });
}
