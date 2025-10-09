// lib/src/safe_expect.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

/// A wrapper that allows chaining .catch() to expect statements
class SafeExpectResult {
  final bool passed;
  final String? errorMessage;

  SafeExpectResult(this.passed, [this.errorMessage]);

  /// Chain method to catch any errors and continue execution
  SafeExpectResult catchError() {
    return this; // Already handled in the constructor
  }

  /// Print the result if it failed
  SafeExpectResult printIfFailed() {
    if (!passed && errorMessage != null) {
      print('❌ Expect failed: $errorMessage');
    }
    return this;
  }
}

/// Extension to add catch functionality to expect statements
extension SafeExpectExtension<T> on T {
  /// Execute expect with error catching - can be chained with .catch()
  SafeExpectResult expectSafe(Matcher matcher, {String? reason}) {
    try {
      expect(this, matcher, reason: reason);
      return SafeExpectResult(true);
    } catch (e) {
      return SafeExpectResult(false, e.toString());
    }
  }
}

/// Structure to hold test failure information
class TestFailureInfo {
  final String testName;
  final String testSuite;
  final List<Map<String, dynamic>> expectFailed;
  final String status;
  final DateTime timestamp;

  TestFailureInfo({
    required this.testName,
    required this.testSuite,
    required this.expectFailed,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'testName': testName,
    'testSuite': testSuite,
    'expectFailed': expectFailed,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Utility functions for safe expect operations
class SafeExpect {
  static final List<Map<String, dynamic>> _failedExpects = [];
  static final List<TestFailureInfo> _testResults = [];
  static String? _currentTestName;
  static String? _currentTestSuite;
  // Note: we now capture per-expect failure metadata instead of global last stack
  
  /// Start tracking a new test
  static void startTest(String testName, {String? testSuite}) {
    _currentTestName = testName;
    _currentTestSuite = testSuite ?? 'Default Suite';
    _failedExpects.clear();
  }
  
  /// Execute an expect statement with error catching
  /// Usage: SafeExpect.catchError(() => expect(actual, matcher))
  static bool catchError(void Function() expectFunction, {bool failTest = false}) {
    try {
      expectFunction();
      return true;
    } catch (e, stack) {
      final errorMsg = e.toString();
      final location = _extractLocationFromStackTrace(stack);
      _failedExpects.add({
        'reason': errorMsg,
        'stackTrace': stack.toString(),
        'filePath': location?['filePath'],
        'lineNumber': location?['lineNumber'],
      });
      
      if (failTest) {
        // Re-throw the exception to fail the test
        rethrow;
      }
      return false;
    }
  }
  
  /// Clear the list of failed expects (call this at the start of each test)
  static void clearFailures() {
    _failedExpects.clear();
  }
  
  /// Get the list of failed expects for this test
  static List<String> get failedExpects => List.unmodifiable(_failedExpects);
  
  /// Check if any expects failed in this test
  static bool get hasFailures => _failedExpects.isNotEmpty;
  
  /// Fail the test if any expects failed (call this at the end of your test)
  static void failIfAnyFailed() {
    if (hasFailures) {
      // Record the test result before failing
      _recordTestResult();
      fail('Test failed due to ${_failedExpects.length} expect failure}');
    } else {
      // Record successful test
      _recordTestResult();
    }
  }
  
  /// Record test result without failing
  static void recordTestResult() {
    _recordTestResult();
  }
  
  /// Internal method to record test result
  static void _recordTestResult() {
    if (_currentTestName != null) {
      final status = hasFailures ? 'Failed' : 'Passed';
      _testResults.add(TestFailureInfo(
        testName: _currentTestName!,
        testSuite: _currentTestSuite ?? 'Default Suite',
        expectFailed: List<Map<String, dynamic>>.from(_failedExpects),
        status: status,
      ));
    }
  }
  
  /// Check if any expects failed and return true/false instead of failing
  /// Use this if you want to handle failures without triggering framework error logs
  static bool hasAnyFailures() {
    return hasFailures;
  }
  
  /// Get the count of failed expects without failing the test
  static int get failureCount => _failedExpects.length;
  
  /// Get all test results as JSON
  static Map<String, dynamic> getAllTestResultsAsJson() {
    // Group results by test suite
    final Map<String, List<Map<String, dynamic>>> groupedResults = {};
    
    for (final result in _testResults) {
      final suiteName = result.testSuite;
      if (!groupedResults.containsKey(suiteName)) {
        groupedResults[suiteName] = [];
      }
      groupedResults[suiteName]!.add(result.toJson());
    }
    
    // Convert to the format you requested
    final List<Map<String, dynamic>> testSuites = [];
    
    groupedResults.forEach((suiteName, tests) {
      testSuites.add({
        'testSuite': suiteName,
        'testWidgets': tests,
      });
    });
    
    return {
      'testSuites': testSuites,
      'summary': {
        'totalTests': _testResults.length,
        'passedTests': _testResults.where((r) => r.status == 'Passed').length,
        'failedTests': _testResults.where((r) => r.status == 'Failed').length,
      }
    };
  }
  
  /// Print all test results as JSON
  static void printTestResultsAsJson() {
    final results = getAllTestResultsAsJson();
    final json = jsonEncode(results);
    print('Test Results JSON:');
    print(json);
  }
  
  /// Print test results as JSON (file saving is handled by CLI)
  static void printAndSaveTestResults({String? customPath}) {
    printTestResultsAsJson();
    // Note: File saving is handled by the CLI when it detects "Test Results JSON:" output
  }
  
  /// Clear all test results
  static void clearAllResults() {
    _testResults.clear();
    _failedExpects.clear();
    _currentTestName = null;
    _currentTestSuite = null;
  }
  
  /// Get the default report path (for reference)
  static String get defaultReportPath => 'testmate-reports/report.json';

  /// Execute multiple expect statements with individual error catching
  static Map<String, bool> all(List<Map<String, dynamic>> expects) {
    final results = <String, bool>{};
    
    for (final expectData in expects) {
      final description = expectData['description'] as String;
      final expectFunction = expectData['function'] as void Function();
      
      results[description] = catchError(expectFunction);
    }
    
    return results;
  }

  /// Execute multiple expect statements and print summary
  static void allWithSummary(List<Map<String, dynamic>> expects) {
    final results = all(expects);
    
    print('\n📊 Expect Results Summary:');
    final passed = results.values.where((passed) => passed).length;
    final failed = results.length - passed;
    
    print('   Total: ${results.length}');
    print('   ✅ Passed: $passed');
    print('   ❌ Failed: $failed');
    
    if (failed > 0) {
      print('\n❌ Failed expects:');
      results.forEach((description, passed) {
        if (!passed) {
          print('   • $description');
        }
      });
    }
    print('');
  }
}

/// Best-effort extraction of file path and line number from a StackTrace.
Map<String, dynamic>? _extractLocationFromStackTrace(StackTrace stackTrace) {
  final lines = stackTrace.toString().split('\n');
  for (final line in lines) {
    if (line.contains('.dart') &&
        !line.contains('flutter_test') &&
        !line.contains('dart-sdk') &&
        !line.contains('testmate') &&
        !line.contains('matcher') &&
        !line.contains('expect.dart') &&
        !line.contains('widget_tester.dart')) {
      final match = RegExp(r'([\w\/]+\.dart)\s+(\d+):').firstMatch(line);
      if (match != null) {
        final filePath = match.group(1);
        final lineNumber = int.tryParse(match.group(2) ?? '');
        if (filePath != null && lineNumber != null) {
          String fullPath = 'integration_test/$filePath';
          return {
            'filePath': fullPath,
            'lineNumber': lineNumber,
          };
        }
      }
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
