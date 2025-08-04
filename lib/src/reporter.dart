// lib/src/reporter.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'error_summarizer.dart';

final List<Map<String, dynamic>> _testResults = [];

/// Captures a screenshot using Flutter Driver
Future<String?> _captureScreenshot(WidgetTester tester, String testName) async {
  try {
    // Wait for the widget tree to be rendered
    await tester.pumpAndSettle();

    print('testName: $testName');

    // For now, let's skip screenshot capture to get tests running
    // We'll implement this properly once we understand the integration test setup
    print(
        'Screenshot capture temporarily disabled - focusing on test execution');

    // Return null to indicate no screenshot was taken
    return null;
  } catch (e) {
    print('Failed to capture screenshot: $e');
    return null;
  }
}

void testMate(
  String description,
  Future<void> Function(WidgetTester) body, {
  bool skip = false,
  Timeout? timeout,
  String? suiteName,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  // Capture the current stack trace to get the line number where this function is called
  final currentStackTrace = StackTrace.current;
  final location = _extractLocationFromStackTrace(currentStackTrace);

  testWidgets(description, (tester) async {
    final stopwatch = Stopwatch()..start();

    try {
      await body(tester);
      stopwatch.stop();
      _testResults.add({
        'testName': description,
        'suite': suiteName ?? 'Default Suite',
        'status': 'passed',
        'duration': stopwatch.elapsed.inMilliseconds,
        'filePath': location?['filePath'],
        'lineNumber': location?['lineNumber'],
      });
    } catch (e, stack) {
      stopwatch.stop();

      // Try to get more accurate line number from the error stack trace
      final errorLocation = _extractLocationFromStackTrace(stack);
      final finalLocation = errorLocation ?? location;
      print('finalLocation: $finalLocation');

      // Capture screenshot on test failure
      String? screenshotPath;
      try {
        screenshotPath = await _captureScreenshot(tester, description);
      } catch (screenshotError) {
        print('Failed to capture screenshot: $screenshotError');
      }

      _testResults.add({
        'testName': description,
        'status': 'failed',
        'suite': suiteName ?? 'Default Suite',
        'reason': ErrorSummarizer.summarizeFailure(e.toString()),
        'stackTrace': stack.toString(),
        'duration': stopwatch.elapsed.inMilliseconds,
        'filePath': finalLocation?['filePath'],
        'lineNumber': finalLocation?['lineNumber'],
        'screenshotPath': screenshotPath,
      });
      rethrow;
    }
  }, skip: skip, timeout: timeout, variant: variant);
}

void finalizeHtmlReport() {
  final reportJson = jsonEncode(_testResults);
  print('@@TEST_REPORT@@START\n$reportJson\n@@TEST_REPORT@@END');
}

String indent(String input, int spaces) {
  final prefix = ' ' * spaces;
  return input.split('\n').map((line) => '$prefix$line').join('\n');
}

Map<String, dynamic>? _extractLocationFromStackTrace(StackTrace stackTrace) {
  final lines = stackTrace.toString().split('\n');

  for (final line in lines) {
    // Look for lines that contain test files (not framework files)
    if (line.contains('.dart') &&
        !line.contains('flutter_test') &&
        !line.contains('flutter_test') &&
        !line.contains('dart-sdk') &&
        !line.contains('testmate') &&
        !line.contains('matcher') &&
        !line.contains('expect.dart') &&
        !line.contains('widget_tester.dart')) {
      // Try to match patterns like "login/login.dart 77:7" or "app_test.dart 77:7"
      final match = RegExp(r'([\w\/]+\.dart)\s+(\d+):').firstMatch(line);
      if (match != null) {
        final filePath = match.group(1);
        final lineNumber = int.tryParse(match.group(2) ?? '');

        if (filePath != null && lineNumber != null) {
          // Build absolute path for IDE navigation
          String fullPath = 'integration_test/$filePath';

          return {
            'filePath': fullPath,
            'lineNumber': lineNumber,
          };
        }
      }

      // Alternative pattern for full paths with integration_test prefix
      final fullPathMatch =
          RegExp(r'integration_test/([\w\/]+\.dart):(\d+):').firstMatch(line);
      if (fullPathMatch != null) {
        final filePath = fullPathMatch.group(1);
        final lineNumber = int.tryParse(fullPathMatch.group(2) ?? '');

        if (filePath != null && lineNumber != null) {
          return {
            'filePath': 'integration_test/$filePath',
            'lineNumber': lineNumber,
          };
        }
      }
    }
  }
  return null;
}
