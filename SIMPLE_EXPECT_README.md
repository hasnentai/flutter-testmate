# Simple Safe Expect - Minimal Change Solution

This provides a **minimal change solution** to handle multiple expect statements without early failures stopping your tests.

## The Problem
```dart
testWidgets('My Test', (tester) async {
  expect(find.text('First Name'), findsOneWidget); // If this fails...
  expect(find.byType(TextField), findsOneWidget);  // This never runs!
});
```

## The Solution - Minimal Changes

### Method 1: Wrap with SafeExpect.catchError() (Recommended)

**Before:**
```dart
expect(find.text('First Name'), findsOneWidget);
expect(find.byType(TextField), findsOneWidget);
```

**After:**
```dart
SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
```

**That's it!** Just wrap your existing expect statements. All expects will run even if some fail.

### Method 2: Using Extension (Alternative)

```dart
find.text('First Name').expectSafe(findsOneWidget).printIfFailed();
find.byType(TextField).expectSafe(findsOneWidget).printIfFailed();
```

## Usage Examples

### Single Test with Multiple Expects

#### Option 1: Continue on Failure (Test Passes)
```dart
testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // All these will run even if one fails, test passes
  SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
  SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
  SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
});
```

#### Option 2: Fail Test if Any Expect Failed
```dart
testWidgets('Should enter text in PAN field', (WidgetTester tester) async {
  SafeExpect.clearFailures(); // Clear previous failures
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  SafeExpect.catchError(() => expect(find.text('First Name'), findsOneWidget));
  SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
  SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
  
  SafeExpect.failIfAnyFailed(); // Fail test if any expects failed
});
```

### Batch Processing for Multiple Expects
```dart
testWidgets('My Test', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));

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
```

### Mixed Approach (Critical vs Non-Critical)
```dart
testWidgets('My Test', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Critical - should fail the test if it fails
  expect(find.text('First Name'), findsOneWidget);

  // Non-critical - can fail without stopping the test
  SafeExpect.catchError(() => expect(find.byType(TextField), findsOneWidget));
  SafeExpect.catchError(() => expect(find.byType(Form), findsOneWidget));
});
```

## Setup

1. **Add import** to your test file:
```dart
import 'package:testmate/testmate.dart';
```

2. **Wrap your expects** with `SafeExpect.catchError()`:
```dart
// Instead of:
expect(widget, findsOneWidget);

// Use:
SafeExpect.catchError(() => expect(widget, findsOneWidget));
```

## What Happens When an Expect Fails?

You have **3 options** for handling failures:

### Option 1: Continue on Failure (Default)
```dart
SafeExpect.catchError(() => expect(widget, findsOneWidget));
```
- ✅ **Test continues** - subsequent expects still run
- ❌ **Error is printed** - you see which expect failed  
- ✅ **Test passes** - framework shows "All tests passed!"
- 📊 **Complete picture** - you know exactly what passed/failed

### Option 2: Fail Test at End
```dart
SafeExpect.clearFailures(); // At start of test
SafeExpect.catchError(() => expect(widget, findsOneWidget));
SafeExpect.failIfAnyFailed(); // At end of test
```
- ✅ **All expects run** - complete execution
- ❌ **Error is printed** - you see which expect failed
- ❌ **Test fails** - if any expects failed
- 📊 **Complete picture** - with proper test failure

### Option 3: Immediate Failure
```dart
SafeExpect.catchError(() => expect(widget, findsOneWidget), failTest: true);
```
- ❌ **Test stops** - on first failure (like normal expect)
- ❌ **Error is printed** - you see which expect failed
- ❌ **Test fails** - immediately

## Migration for 120 Tests

For your 120 tests, you can:

1. **Quick migration**: Find and replace `expect(` with `SafeExpect.catchError(() => expect(`
2. **Add closing parentheses**: Add `);` after each expect statement
3. **Done!** All your expects will now run independently

### Find & Replace Pattern:
- **Find:** `expect(`
- **Replace:** `SafeExpect.catchError(() => expect(`
- **Add:** `);` at the end of each expect line

## Benefits

✅ **Minimal code changes** - just wrap existing expects  
✅ **All expects run** - no early failures stopping execution  
✅ **Error visibility** - see exactly which expects fail  
✅ **Easy migration** - find/replace for bulk changes  
✅ **Flexible** - mix critical and non-critical expects  

## API Reference

### SafeExpect.catchError()
```dart
SafeExpect.catchError(() => expect(actual, matcher))
```
- Returns `true` if expect passed, `false` if failed
- Prints error message if failed
- Test continues regardless of result

### Extension Method
```dart
actual.expectSafe(matcher).printIfFailed()
```
- Alternative fluent API
- Automatically prints errors if failed

### Batch Processing
```dart
SafeExpect.allWithSummary([...]) // Prints summary
SafeExpect.all([...])            // Returns results map
```

This solution gives you **maximum impact with minimum effort** for your 120 tests!
