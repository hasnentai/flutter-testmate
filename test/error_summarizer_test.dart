// test/error_summarizer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:testmate/src/error_summarizer.dart';

void main() {
  group('ErrorSummarizer', () {
    group('summarizeFailure', () {
      test('should summarize widget key finder errors', () {
        const errorMessage = "Expected: exactly one matching candidate\n"
            "  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'login_button'>]: []>\n"
            "   Which: means none were found but one was expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected a widget with key `login_button`, but none were found.'));
      });

      test('should summarize text finder errors', () {
        const errorMessage = "Expected: exactly one matching candidate\n"
            "  Actual: _TextWidgetFinder:<Found 0 widgets with text \"Welcome\">\n"
            "   Which: means none were found but one was expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected a widget with text "Welcome", but none were found.'));
      });

      test('should summarize type finder errors', () {
        const errorMessage = "Expected: exactly one matching candidate\n"
            "  Actual: _TypeWidgetFinder:<Found 0 widgets with type ElevatedButton>\n"
            "   Which: means none were found but one was expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected a widget of type `ElevatedButton`, but none were found.'));
      });

      test('should summarize icon finder errors', () {
        const errorMessage = "Expected: exactly one matching candidate\n"
            "  Actual: _IconWidgetFinder:<Found 0 widgets with icon IconData(U+E318)>\n"
            "   Which: means none were found but one was expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected a widget with icon (Unicode: U+E318), but none were found.'));
      });

      test('should summarize multiple widgets found errors', () {
        const errorMessage = "Expected: exactly one matching candidate\n"
            "  Actual: _TextWidgetFinder:<Found 3 widgets with text \"Submit\">\n"
            "   Which: means more than one were found but exactly one was expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected exactly one widget, but found 3 widgets with Text finder.'));
      });

      test('should summarize count mismatch errors', () {
        const errorMessage = "Expected: 2 matching candidates\n"
            "  Actual: _TypeWidgetFinder:<Found 1 widgets with type ElevatedButton>\n"
            "   Which: means one was found but two were expected";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Expected 2 widgets with Type finder, but found 1 widgets.'));
      });

      test('should handle unknown error patterns', () {
        const errorMessage = "Some unknown error message\nwith multiple lines";
        
        final result = ErrorSummarizer.summarizeFailure(errorMessage);
        expect(result, equals('Some unknown error message'));
      });
    });

    group('extractFinderType', () {
      test('should extract finder type from error message', () {
        const errorMessage = "_KeyWidgetFinder:<Found 0 widgets with key [<'test'>]: []>";
        
        final result = ErrorSummarizer.extractFinderType(errorMessage);
        expect(result, equals('Key'));
      });

      test('should return null for messages without finder type', () {
        const errorMessage = "Some random error message";
        
        final result = ErrorSummarizer.extractFinderType(errorMessage);
        expect(result, isNull);
      });
    });

    group('extractExpectedCount', () {
      test('should extract expected count from error message', () {
        const errorMessage = "Expected: 3 matching candidates";
        
        final result = ErrorSummarizer.extractExpectedCount(errorMessage);
        expect(result, equals(3));
      });

      test('should return null for messages without expected count', () {
        const errorMessage = "Some random error message";
        
        final result = ErrorSummarizer.extractExpectedCount(errorMessage);
        expect(result, isNull);
      });
    });

    group('extractActualCount', () {
      test('should extract actual count from error message', () {
        const errorMessage = "Found 5 widgets with type ElevatedButton";
        
        final result = ErrorSummarizer.extractActualCount(errorMessage);
        expect(result, equals(5));
      });

      test('should return null for messages without actual count', () {
        const errorMessage = "Some random error message";
        
        final result = ErrorSummarizer.extractActualCount(errorMessage);
        expect(result, isNull);
      });
    });

    group('isWidgetFinderError', () {
      test('should return true for widget finder errors', () {
        const errorMessage = "Found 0 widgets with key [<'test'>]";
        
        final result = ErrorSummarizer.isWidgetFinderError(errorMessage);
        expect(result, isTrue);
      });

      test('should return true for count mismatch errors', () {
        const errorMessage = "Expected: exactly one matching candidate\nActual: _KeyWidgetFinder:<Found 2 widgets>";
        
        final result = ErrorSummarizer.isWidgetFinderError(errorMessage);
        expect(result, isTrue);
      });

      test('should return false for non-widget finder errors', () {
        const errorMessage = "Some other type of error";
        
        final result = ErrorSummarizer.isWidgetFinderError(errorMessage);
        expect(result, isFalse);
      });
    });

    group('getSuggestion', () {
      test('should provide suggestion for key finder errors', () {
        const errorMessage = "Expected a widget with key `login_button`, but none were found.";
        
        final result = ErrorSummarizer.getSuggestion(errorMessage);
        expect(result, equals('Check if the widget has the correct key assigned.'));
      });

      test('should provide suggestion for text finder errors', () {
        const errorMessage = "Expected a widget with text \"Welcome\", but none were found.";
        
        final result = ErrorSummarizer.getSuggestion(errorMessage);
        expect(result, equals('Verify the text content matches exactly (including case and whitespace).'));
      });

      test('should provide suggestion for type finder errors', () {
        const errorMessage = "Expected a widget of type `ElevatedButton`, but none were found.";
        
        final result = ErrorSummarizer.getSuggestion(errorMessage);
        expect(result, equals('Ensure the widget of the specified type exists in the widget tree.'));
      });

      test('should provide default suggestion for unknown errors', () {
        const errorMessage = "Some unknown error";
        
        final result = ErrorSummarizer.getSuggestion(errorMessage);
        expect(result, equals('Review the widget tree structure and ensure the expected widget is present.'));
      });
    });
  });
} 