// example/basic_usage.dart
import 'package:testmate/testmate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

// Mock app for demonstration
class MockApp extends StatelessWidget {
  const MockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TestMate Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TestMate Demo'),
          key: const Key('app_bar'),
        ),
        body: Column(
          children: [
            const Text(
              'Welcome to TestMate!',
              key: Key('welcome_text'),
            ),
            ElevatedButton(
              onPressed: () {},
              key: const Key('login_button'),
              child: const Text('Login'),
            ),
            const Icon(
              Icons.home,
              key: Key('home_icon'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TestMate Basic Usage Examples', () {
    testMate('Should find welcome text', (tester) async {
      await tester.pumpWidget(const MockApp());
      await tester.pumpAndSettle();

      // This will work
      expect(find.text('Welcome to TestMate!'), findsOneWidget);
    });

    testMate('Should find login button by key', (tester) async {
      await tester.pumpWidget(const MockApp());
      await tester.pumpAndSettle();

      // This will work
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testMate('Should find app bar by type', (tester) async {
      await tester.pumpWidget(const MockApp());
      await tester.pumpAndSettle();

      // This will work
      expect(find.byType(AppBar), findsOneWidget);
    });

    testMate('Should find home icon', (tester) async {
      await tester.pumpWidget(const MockApp());
      await tester.pumpAndSettle();

      // This will work
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    // Example of a test that will fail and show error summarization
    testMate('Should demonstrate error summarization', (tester) async {
      await tester.pumpWidget(const MockApp());
      await tester.pumpAndSettle();

      // This will fail and show the error summarization
      expect(find.byKey(const Key('non_existent_button')), findsOneWidget);
    });
  });
}
