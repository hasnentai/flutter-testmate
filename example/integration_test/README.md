# Integration Tests

This directory contains integration tests for the Taxpayer Form application.

## Running Integration Tests

### Prerequisites
1. Make sure you have Flutter installed and configured
2. Install dependencies by running `flutter pub get` in the example directory
3. Have a device or emulator running

### Running Tests

#### Run all integration tests:
```bash
flutter test integration_test/
```

#### Run specific test file:
```bash
flutter test integration_test/taxpayer_form_test.dart
```

#### Run on specific device:
```bash
flutter test integration_test/ -d <device_id>
```

### Test Coverage

The integration tests cover:

1. **PAN Field Input Test**: Tests entering text in the PAN field and verifying the input
2. **Error Handling Test**: Tests the error display when invalid PAN is entered and Proceed button is pressed
3. **Form Completion Test**: Tests entering text in all form fields (PAN, First Name, Middle Name, Last Name, Date of Birth, Verification Code)
4. **Navigation Test**: Tests the Back button functionality

### Test Structure

Each test follows the pattern:
1. Start the app using `app.main()`
2. Wait for the app to load with `pumpAndSettle()`
3. Find UI elements using `find.byWidgetPredicate()` or `find.widgetWithText()`
4. Interact with elements using `tester.enterText()`, `tester.tap()`, etc.
5. Verify expected behavior with `expect()` assertions

### Notes

- Tests use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` to set up the integration test environment
- Each test waits for the app to fully load before interacting with elements
- The tests verify both UI interactions and the underlying state changes
- Error scenarios are tested to ensure proper validation behavior
