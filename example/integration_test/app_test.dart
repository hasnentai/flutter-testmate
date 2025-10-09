import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:testmate/testmate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Taxpayer Form Integration Tests', () {
    testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
      // Start tracking this test
      SafeExpect.startTest(
        'Should enter text in PAN field',
        testSuite: 'Taxpayer Form Integration Tests',
      );
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Minimal change approach - just wrap your existing expects with SafeExpect.catchError()
      final panLabel = find.text('First Name');
      SafeExpect.catchError(() => expect(panLabel, findsOneWidget));

       final lastName = find.text('Middle Name');
      SafeExpect.catchError(() => expect(lastName, findsOneWidget));
      
      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });
    
    testWidgets('Should have form elements', (WidgetTester tester) async {
      // Start tracking this test
      SafeExpect.startTest(
        'Should have form elements',
        testSuite: 'Taxpayer Form Integration Tests',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(AppBar), findsOneWidget));
      
      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });
  });


    group('Taxpayer Form Integration Tests', () {
    testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
      // Start tracking this test
      SafeExpect.startTest(
        'Anoother Group Test Case One',
        testSuite: 'Anoother Group',
      );
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Minimal change approach - just wrap your existing expects with SafeExpect.catchError()
      final panLabel = find.text('First Name');
      SafeExpect.catchError(() => expect(panLabel, findsOneWidget));

       final lastName = find.text('Middle Name');
      SafeExpect.catchError(() => expect(lastName, findsOneWidget));
      
      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });
    
    testWidgets('Should have form elements', (WidgetTester tester) async {
      // Start tracking this test
     SafeExpect.startTest(
        'Anoother Group Test Case Two',
        testSuite: 'Anoother Group',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text("Dashboard"), findsOneWidget));
      SafeExpect.catchError(() => expect(find.text("Dashboard"), findsOneWidget));
      
      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });
  });
  
  // Print and save all test results as JSON at the end
  tearDownAll(() {
    SafeExpect.printAndSaveTestResults(); // This will both print and save to testmate-reports/report.json
  });
}
