# TestMate 🧪

A powerful Flutter test utility package that provides intelligent error summarization, enhanced test reporting, and CLI tools for better test management.

[![Pub Version](https://img.shields.io/pub/v/testmate)](https://pub.dev/packages/testmate)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart CI](https://github.com/yourusername/testmate/workflows/Dart%20CI/badge.svg)](https://github.com/yourusername/testmate/actions)

## ✨ Features

- **🧠 Intelligent Error Summarization**: Converts verbose Flutter test errors into human-readable messages
- **📊 Enhanced Test Reporting**: Better test result reporting with detailed information
- **🛠️ CLI Tools**: Command-line interface for running tests and generating reports
- **📄 HTML Report Generation**: Beautiful HTML reports for test results
- **🔍 Error Analysis**: Analyze test failures and get actionable suggestions
- **📈 Test Statistics**: Comprehensive test metrics and success rates

## 🚀 Quick Start

### Installation

Add TestMate to your `pubspec.yaml`:

```yaml
dev_dependencies:
  testmate: ^1.0.0
```

### CLI Installation

Install TestMate globally for CLI access:

```bash
dart pub global activate testmate
```

## 📖 Usage

### As a Library

```dart
import 'package:testmate/testmate.dart';

// Use the error summarizer
final summarizedError = ErrorSummarizer.summarizeFailure(errorMessage);

// Use the enhanced test reporter
htmlTestWidgets('My Test', (tester) async {
  // Your test code here
  expect(find.byKey(Key('login_button')), findsOneWidget);
});
```

### As a CLI Tool

#### Run Integration Tests

```bash
# Run integration tests
testmate test

# Run tests on web
testmate test --web

# Run with verbose output
testmate test --verbose

# Specify output directory
testmate test --output my-reports
```

#### Generate Reports

```bash
# Generate HTML and JSON reports
testmate report

# Generate HTML report only
testmate report --format html

# Generate JSON report only
testmate report --format json
```

#### Analyze Test Errors

```bash
# Analyze failed tests and get suggestions
testmate analyze
```

## 🎯 Error Summarization

TestMate intelligently summarizes Flutter test errors to make debugging easier:

### Supported Error Types

1. **Widget Key Finder**
   ```dart
   expect(find.byKey(Key('login_button')), findsOneWidget);
   // Error: "Expected a widget with key `login_button`, but none were found."
   ```

2. **Text Finder**
   ```dart
   expect(find.text('Welcome'), findsOneWidget);
   // Error: "Expected a widget with text "Welcome", but none were found."
   ```

3. **Type Finder**
   ```dart
   expect(find.byType(ElevatedButton), findsOneWidget);
   // Error: "Expected a widget of type `ElevatedButton`, but none were found."
   ```

4. **Icon Finder**
   ```dart
   expect(find.byIcon(Icons.home), findsOneWidget);
   // Error: "Expected a widget with icon (Unicode: U+E318), but none were found."
   ```

5. **Count Mismatches**
   ```dart
   expect(find.byType(ElevatedButton), findsNWidgets(2));
   // Error: "Expected 2 widgets with Type finder, but found 1 widgets."
   ```

### Error Analysis

TestMate provides suggestions for fixing test failures:

```bash
testmate analyze
```

Output:
```
🔍 Analyzing test errors...

❌ Found 2 failed test(s):

📋 Test: Login Test
❌ Error: Expected a widget with key `login_button`, but none were found.
💡 Suggestion: Check if the widget has the correct key assigned.

📋 Test: Welcome Message Test
❌ Error: Expected a widget with text "Welcome", but none were found.
💡 Suggestion: Verify the text content matches exactly (including case and whitespace).
```

## 📊 Report Generation

TestMate generates comprehensive test reports in multiple formats:

### HTML Reports

Beautiful, interactive HTML reports with:
- Test summary and statistics
- Detailed test results
- Error analysis and suggestions
- Test duration metrics
- File and line number references

### JSON Reports

Structured JSON reports for programmatic analysis:
```json
{
  "testName": "Login Test",
  "status": "failed",
  "reason": "Expected a widget with key `login_button`, but none were found.",
  "duration": 1500,
  "filePath": "integration_test/app_test.dart",
  "lineNumber": 25,
  "suggestion": "Check if the widget has the correct key assigned."
}
```

## 🛠️ CLI Commands

### `testmate test`

Run Flutter integration tests with enhanced reporting.

**Options:**
- `--web`: Run tests on Flutter Web
- `--verbose`: Enable verbose output
- `--output <dir>`: Output directory for reports (default: testmate-report)
- `--format <format>`: Report format: html, json, or both (default: both)

### `testmate report`

Generate reports from existing test results.

**Options:**
- `--output <dir>`: Output directory for reports
- `--format <format>`: Report format: html, json, or both

### `testmate analyze`

Analyze test errors and provide suggestions.

**Options:**
- `--output <dir>`: Output directory for analysis
- `--verbose`: Enable verbose output

## 📁 Project Structure

```
your_flutter_project/
├── integration_test/
│   └── app_test.dart          # Your integration tests
├── test_driver/
│   └── integration_test.dart  # Test driver
└── testmate-report/           # Generated reports
    ├── report.json
    ├── testmate_report.html
    └── analysis.json
```

## 🔧 Configuration

### Integration Test Setup

1. Create your integration test file:

```dart
// integration_test/app_test.dart
import 'package:testmate/testmate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Tests', () {
    htmlTestWidgets('Login Test', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('login_button')), findsOneWidget);
    });
  });
}
```

2. Create your test driver:

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

## 📈 Examples

### Basic Integration Test

```dart
import 'package:testmate/testmate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Authentication', () {
    htmlTestWidgets('User can login successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test login flow
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back!'), findsOneWidget);
    });

    htmlTestWidgets('User can register new account', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test registration flow
      await tester.tap(find.byKey(Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(3));
    });
  });
}
```

### Data-Driven Tests

```dart
import 'package:testmate/testmate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final testUsers = [
    {'username': 'user1', 'password': 'pass1'},
    {'username': 'user2', 'password': 'pass2'},
  ];

  for (final user in testUsers) {
    htmlTestWidgets('Login test for ${user['username']}', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(Key('username_field')), 
        user['username']!
      );
      await tester.enterText(
        find.byKey(Key('password_field')), 
        user['password']!
      );

      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome ${user['username']}'), findsOneWidget);
    });
  }
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork
3. Install dependencies: `dart pub get`
4. Run tests: `dart test`
5. Make your changes
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent testing framework
- The Dart community for inspiration and feedback

## 📞 Support

- 📧 Email: support@testmate.dev
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/testmate/issues)
- 📖 Documentation: [GitHub Wiki](https://github.com/yourusername/testmate/wiki)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/testmate/discussions)

---

Made with ❤️ by the TestMate team
