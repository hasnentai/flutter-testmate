# Flutter TestMate 🧪

A powerful Flutter integration testing tool that provides enhanced test reporting, tag-based test filtering, and simplified test syntax for Flutter Driver tests.

## ✨ Features

- **🎯 Tag-based Test Filtering**: Run specific tests using tags (e.g., `@smoke`, `@regression`)
- **📊 Rich HTML Reports**: Beautiful, interactive test reports with detailed failure analysis
- **🔒 Safe Expect**: Simplified test syntax with automatic error handling
- **📈 JSON Export**: Machine-readable test results for CI/CD integration
- **🏷️ Test Suite Grouping**: Organize tests with meaningful suite names
- **🖥️ Flutter Driver Integration**: Seamless integration with Flutter Driver

## 🚀 Quick Start

### Installation

Flutter TestMate is a CLI tool that can be installed from pub.dev:

1. **Install globally** from pub.dev:

```bash
# Install the CLI tool globally
dart pub global activate flutter_testmate
```

**Note**: Make sure your pub global bin directory is in your PATH. If you get a "command not found" error, add this to your shell profile:

```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.profile
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

2. **Add to your project** (for development):

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_testmate: ^1.0.0  # Use the latest version
```

### Basic Usage

1. **Create your integration test file** (`integration_test/app_test.dart`):

```dart
import 'package:flutter_test/flutter_test.dart' hide group, testWidgets, expect;
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:flutter_testmate/testmate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Taxpayer Form Integration Tests', () {
    testWidgets('Test 1: Should enter text in PAN field',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Simplified syntax - just use expect() directly!
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Middle Name'), findsOneWidget);

      // Record test result and fail if needed
      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Should have form elements',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Middle Name'), findsOneWidget);

      SafeExpect.failIfAnyFailed();
    });
  });

  group('Another Group', () {
    testWidgets('Test Case One',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Middle Name'), findsOneWidget);

      SafeExpect.failIfAnyFailed();
    });

    testWidgets('Test Case Two',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("Dashboard"), findsOneWidget);

      SafeExpect.failIfAnyFailed();
    }, tags: ['smoke']); // Tagged test
  });

  // Print and save all test results as JSON at the end
  tearDownAll(() {
    SafeExpect.printAndSaveTestResults();
  });
}
```

2. **Run tests**:

```bash
# Run all tests
flutter_testmate test

# Run tests on web
flutter_testmate test --web

# Run only smoke tests
flutter_testmate test --tag @smoke

# Run smoke tests on web
flutter_testmate test --web --tag @smoke
```

## 🏷️ Tag-based Test Filtering

Flutter TestMate supports powerful tag-based test filtering to run specific subsets of your tests:

### Adding Tags to Tests

```dart
testWidgets('Critical login test',
    (WidgetTester tester) async {
  // Test implementation
}, tags: ['smoke', 'critical']);

testWidgets('Regression test for payment flow',
    (WidgetTester tester) async {
  // Test implementation  
}, tags: ['regression', 'payment']);
```

### Running Tagged Tests

```bash
# Run smoke tests
flutter_testmate test --tag @smoke

# Run regression tests
flutter_testmate test --tag @regression

# Run critical tests
flutter_testmate test --tag @critical

# Run smoke tests on web
flutter_testmate test --web --tag @smoke
```

### How Tag Filtering Works

1. **Scans** all `.test.dart` files in the `integration_test` directory
2. **Finds** tests with the specified tag
3. **Creates** a temporary filtered test file (e.g., `smoke_test.dart`)
4. **Runs** only the tagged tests
5. **Cleans up** the temporary file automatically

## 📊 Test Reports

Flutter TestMate generates comprehensive test reports in multiple formats:

### HTML Report

The HTML report provides a beautiful, interactive interface showing:

- **Test Summary**: Total tests, passed, failed counts
- **Test Suites**: Organized by groups with proper naming
- **Individual Test Results**: Detailed status and timing
- **Failure Analysis**: Stack traces and error details
- **Responsive Design**: Works on desktop and mobile

**Report Location**: `testmate-reports/safeexpect_report.html`

#### Report Screenshot

The HTML report features a modern, clean design with comprehensive test analytics:

![Flutter TestMate Report](https://via.placeholder.com/800x600/4a90e2/ffffff?text=Flutter+TestMate+Report)

**Key Features:**
- **📊 Test Summary Dashboard**: Shows pass rate (75.0%), total tests (4), passed (3), failed (1)
- **📈 Visual Progress Bar**: Green progress bar indicating test completion status
- **🎯 Test Suite Organization**: Tests grouped by meaningful suite names
- **❌ Detailed Error Analysis**: 
  - Clickable error messages with line numbers
  - Stack trace viewing capability
  - File path references for easy debugging
- **✅ Status Indicators**: Color-coded pills (green for passed, red for failed)
- **📱 Responsive Design**: Clean, modern interface that works on all devices
- **🕒 Timestamp Information**: Shows when the report was generated

**Interactive Elements:**
- **Expandable error details**: Click to view full stack traces
- **File navigation**: Direct links to error locations in your code
- **Collapsible test suites**: Organize large test suites efficiently

### JSON Report

Machine-readable test results for CI/CD integration:

```json
{
  "testSuites": [
    {
      "testSuite": "Taxpayer Form Integration Tests",
      "testWidgets": [
        {
          "testName": "Test 1: Should enter text in PAN field",
          "testSuite": "Taxpayer Form Integration Tests",
          "expectFailed": [],
          "status": "Passed",
          "timestamp": "2025-10-16T18:21:37.151"
        }
      ]
    }
  ],
  "summary": {
    "totalTests": 4,
    "passedTests": 3,
    "failedTests": 1
  }
}
```

**Report Location**: `testmate-reports/report.json`

## 🔧 Configuration

### CLI Options

```bash
flutter_testmate test [options]

Options:
  -w, --web          Run on Flutter Web
  -t, --tag <tag>    Run only tests with specific tag (e.g., @smoke)
  -h, --help         Show help information
```

### Usage Examples

```bash
# Basic usage
flutter_testmate test

# Run on web
flutter_testmate test --web

# Run specific tagged tests
flutter_testmate test --tag @smoke

# Run tagged tests on web
flutter_testmate test --web --tag @regression

# Get help
flutter_testmate --help
```

### Test File Structure

```
integration_test/
├── app.test.dart           # Main test file
├── login.test.dart         # Additional test file
├── smoke_test.dart         # Generated filtered test (temporary)
└── regression_test.dart    # Generated filtered test (temporary)

testmate-reports/
├── report.json             # JSON test results
└── safeexpect_report.html  # HTML test report
```

## 🛠️ Advanced Usage

### Custom Test Suites

Tests are automatically grouped by their `group()` name, which becomes the test suite name in reports:

```dart
group('Payment Flow Tests', () {
  // All tests in this group will be under "Payment Flow Tests" suite
  testWidgets('Credit card payment', (tester) async {
    // Test implementation
  });
});
```

### Error Handling

Flutter TestMate provides automatic error handling with `SafeExpect`:

```dart
// Old way (manual error handling)
try {
  expect(find.text('Button'), findsOneWidget);
} catch (e) {
  // Handle error
}

// New way (automatic error handling)
expect(find.text('Button'), findsOneWidget); // Errors are caught automatically
SafeExpect.failIfAnyFailed(); // Fail the test if any expects failed
```

### Multiple Test Files

You can have multiple test files in the `integration_test` directory:

```
integration_test/
├── app.test.dart
├── login.test.dart
├── payment.test.dart
└── user_profile.test.dart
```

All files ending with `.test.dart` will be scanned for tag filtering.

## 📱 Example Project

The included example project demonstrates:

- **Basic integration tests** with form validation
- **Tagged tests** for different test categories
- **Multiple test groups** with proper suite naming
- **Error handling** and failure reporting
- **Real Flutter app** integration

### Running the Example

```bash
# First, install the package
dart pub global activate flutter_testmate

# Navigate to your project directory
cd your-flutter-project

# Run all tests
flutter_testmate test

# Run tests on web
flutter_testmate test --web

# Run only smoke tests
flutter_testmate test --tag @smoke

# Run smoke tests on web
flutter_testmate test --web --tag @smoke
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/your-repo/flutter-testmate/issues) page
2. Create a new issue with detailed information
3. Include your test file structure and error messages

## 🎯 Roadmap

- [ ] Screenshot capture on test failures
- [ ] Video recording of test execution
- [ ] Parallel test execution
- [ ] Custom report themes
- [ ] Integration with popular CI/CD platforms
- [ ] Test performance metrics
- [ ] Flaky test detection

---

**Made with ❤️ for the Flutter community**