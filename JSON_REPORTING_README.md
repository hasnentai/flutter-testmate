# SafeExpect JSON Reporting

The SafeExpect utility now provides comprehensive JSON reporting of test results, including detailed failure information for each test.

## 🎯 **What You Get**

When you run your tests, you'll get a structured JSON report like this:

```json
{
  "testSuites": [
    {
      "testSuite": "Taxpayer Form Integration Tests",
      "testWidgets": [
        {
          "testName": "Should enter text in PAN field",
          "testSuite": "Taxpayer Form Integration Tests",
          "expectFailed": [
            "Expected a widget with type TextField, but none were found."
          ],
          "status": "Failed",
          "timestamp": "2024-01-15T10:30:45.123Z"
        },
        {
          "testName": "Should have form elements",
          "testSuite": "Taxpayer Form Integration Tests", 
          "expectFailed": [],
          "status": "Passed",
          "timestamp": "2024-01-15T10:30:47.456Z"
        }
      ]
    },
    {
      "testSuite": "Login End to End",
      "testWidgets": [
        {
          "testName": "Check Welcome Message",
          "testSuite": "Login End to End",
          "expectFailed": [],
          "status": "Passed",
          "timestamp": "2024-01-15T10:30:49.789Z"
        }
      ]
    }
  ],
  "summary": {
    "totalTests": 3,
    "passedTests": 2,
    "failedTests": 1
  }
}
```

## 🚀 **How to Use**

### **Step 1: Start Tracking Each Test**
```dart
testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
  // Start tracking this test
  SafeExpect.startTest(
    'Should enter text in PAN field',
    testSuite: 'Taxpayer Form Integration Tests',
  );
  
  // Your test code here...
});
```

### **Step 2: Use SafeExpect.catchError() for All Expects**
```dart
SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
```

### **Step 3: Record Results at the End**
```dart
// This will record the test result and fail if needed
SafeExpect.failIfAnyFailed();
```

### **Step 4: Print and Save JSON Report**
```dart
// Add this at the end of your test file
tearDownAll(() {
  SafeExpect.printAndSaveTestResults(); // Prints to console AND saves to testmate-reports/report.json
});
```

## 📝 **Complete Example**

```dart
import 'package:testmate/testmate.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Taxpayer Form Integration Tests', () {
    testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Should enter text in PAN field',
        testSuite: 'Taxpayer Form Integration Tests',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });
    
    testWidgets('Should have form elements', (WidgetTester tester) async {
      SafeExpect.startTest(
        'Should have form elements',
        testSuite: 'Taxpayer Form Integration Tests',
      );
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
      SafeExpect.catchError(() => expect(find.byType(AppBar), findsOneWidget));
      
      SafeExpect.failIfAnyFailed();
    });
  });

  // Print and save all test results as JSON at the end
  tearDownAll(() {
    SafeExpect.printAndSaveTestResults(); // Saves to testmate-reports/report.json
  });
}
```

## 🔧 **API Reference**

### **SafeExpect.startTest()**
```dart
SafeExpect.startTest(String testName, {String? testSuite})
```
- Starts tracking a new test
- Call this at the beginning of each testWidgets
- Automatically clears previous failures

### **SafeExpect.catchError()**
```dart
SafeExpect.catchError(void Function() expectFunction, {bool failTest = false})
```
- Wraps your expect statements
- Records failures for JSON reporting
- Continues execution even if expect fails

### **SafeExpect.failIfAnyFailed()**
```dart
SafeExpect.failIfAnyFailed()
```
- Records the test result (pass/fail)
- Fails the test if any expects failed
- Call this at the end of each test

### **SafeExpect.printTestResultsAsJson()**
```dart
SafeExpect.printTestResultsAsJson()
```
- Prints all collected test results as formatted JSON
- Call this in tearDownAll()

### **SafeExpect.getAllTestResultsAsJson()**
```dart
Map<String, dynamic> getAllTestResultsAsJson()
```
- Returns the JSON data as a Map
- Useful for custom processing or saving to files

### **SafeExpect.printAndSaveTestResults()**
```dart
SafeExpect.printAndSaveTestResults({String? customPath})
```
- Prints JSON to console (file saving is handled by CLI)
- The CLI automatically detects "Test Results JSON:" output and saves to `testmate-reports/report.json`
- Recommended method for most use cases

## 📊 **JSON Structure**

The generated JSON has this structure:

```json
{
  "testSuites": [
    {
      "testSuite": "Suite Name",
      "testWidgets": [
        {
          "testName": "Test Name",
          "testSuite": "Suite Name", 
          "expectFailed": ["Error message 1", "Error message 2"],
          "status": "Passed" | "Failed",
          "timestamp": "2024-01-15T10:30:45.123Z"
        }
      ]
    }
  ],
  "summary": {
    "totalTests": 10,
    "passedTests": 7,
    "failedTests": 3
  }
}
```

## 📁 **File Output**

When you run `testmate test`, the CLI automatically captures the JSON output and saves it to:

```
testmate-reports/
└── report.json
```

The CLI detects the "Test Results JSON:" output from your tests and automatically:
- Creates the `testmate-reports` directory
- Saves the JSON to `report.json`
- Generates an HTML report at `safeexpect_report.html`

## 🎯 **Key Benefits**

✅ **Structured Data** - Clean JSON format for easy parsing  
✅ **Detailed Failures** - Exact error messages for each failed expect  
✅ **Test Grouping** - Organized by test suites  
✅ **Summary Statistics** - Pass/fail counts  
✅ **Timestamps** - When each test ran  
✅ **Easy Integration** - Works with existing test framework  
✅ **Automatic File Saving** - Results saved to `testmate-reports/report.json`  
✅ **Directory Creation** - Automatically creates the reports folder  

## 🔄 **Migration for 120 Tests**

1. **Add startTest()** at the beginning of each testWidgets
2. **Wrap expects** with SafeExpect.catchError()
3. **Add failIfAnyFailed()** at the end of each test
4. **Add tearDownAll()** to print JSON results

### **Find & Replace Pattern:**
- **Find:** `testWidgets('Test Name', (WidgetTester tester) async {`
- **Replace:** `testWidgets('Test Name', (WidgetTester tester) async {\n  SafeExpect.startTest('Test Name', testSuite: 'Your Suite');`
- **Add:** `SafeExpect.failIfAnyFailed();` at the end of each test

This gives you comprehensive JSON reporting for all your 120 tests! 🎉
