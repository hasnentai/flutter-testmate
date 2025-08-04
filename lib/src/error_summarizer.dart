// lib/src/error_summarizer.dart
/// Provides utilities for summarizing Flutter test failures in a human-readable format.
class ErrorSummarizer {
  /// Summarizes Flutter test failures by analyzing the error message
  /// and providing a clear, actionable description of what went wrong.
  static String summarizeFailure(String reason) {
    // Widget Key Finder
    final widgetKeyRegex = RegExp(r"Found 0 widgets with key \[<'(.+?)'>\]");
    final keyMatch = widgetKeyRegex.firstMatch(reason);
    if (keyMatch != null) {
      final keyName = keyMatch.group(1);
      return 'Expected a widget with key `$keyName`, but none were found.';
    }

    // Text Finder
    final textFinderRegex = RegExp(r'Found 0 widgets with text "(.*?)"');
    final textMatch = textFinderRegex.firstMatch(reason);
    if (textMatch != null) {
      final missingText = textMatch.group(1);
      return 'Expected a widget with text "$missingText", but none were found.';
    }

    // Icon Finder
    final iconFinderRegex =
        RegExp(r'Found 0 widgets with icon IconData\(U\+([0-9A-Fa-f]+)\)');
    final iconMatch = iconFinderRegex.firstMatch(reason);
    if (iconMatch != null) {
      final iconCode = iconMatch.group(1);
      return 'Expected a widget with icon (Unicode: U+$iconCode), but none were found.';
    }

    // Type Finder (e.g., ElevatedButton, Text, etc.)
    final typeFinderRegex = RegExp(r'Found 0 widgets with type (\w+)');
    final typeMatch = typeFinderRegex.firstMatch(reason);
    if (typeMatch != null) {
      final widgetType = typeMatch.group(1);
      return 'Expected a widget of type `$widgetType`, but none were found.';
    }

    // Semantics Finder
    final semanticsFinderRegex =
        RegExp(r'Found 0 widgets with semantics label "(.*?)"');
    final semanticsMatch = semanticsFinderRegex.firstMatch(reason);
    if (semanticsMatch != null) {
      final semanticsLabel = semanticsMatch.group(1);
      return 'Expected a widget with semantics label "$semanticsLabel", but none were found.';
    }

    // Tooltip Finder
    final tooltipFinderRegex = RegExp(r'Found 0 widgets with tooltip "(.*?)"');
    final tooltipMatch = tooltipFinderRegex.firstMatch(reason);
    if (tooltipMatch != null) {
      final tooltipText = tooltipMatch.group(1);
      return 'Expected a widget with tooltip "$tooltipText", but none were found.';
    }

    // Image Finder
    final imageFinderRegex = RegExp(r'Found 0 widgets with image "(.*?)"');
    final imageMatch = imageFinderRegex.firstMatch(reason);
    if (imageMatch != null) {
      final imagePath = imageMatch.group(1);
      return 'Expected a widget with image "$imagePath", but none were found.';
    }

    // Predicate Finder (custom finders)
    final predicateFinderRegex =
        RegExp(r'Found 0 widgets with predicate "(.*?)"');
    final predicateMatch = predicateFinderRegex.firstMatch(reason);
    if (predicateMatch != null) {
      final predicate = predicateMatch.group(1);
      return 'Expected a widget matching predicate "$predicate", but none were found.';
    }

    // Ancestor/Descendant Finder
    final ancestorFinderRegex =
        RegExp(r'Found 0 widgets with ancestor of type (\w+)');
    final ancestorMatch = ancestorFinderRegex.firstMatch(reason);
    if (ancestorMatch != null) {
      final ancestorType = ancestorMatch.group(1);
      return 'Expected a widget with ancestor of type `$ancestorType`, but none were found.';
    }

    final descendantFinderRegex =
        RegExp(r'Found 0 widgets with descendant of type (\w+)');
    final descendantMatch = descendantFinderRegex.firstMatch(reason);
    if (descendantMatch != null) {
      final descendantType = descendantMatch.group(1);
      return 'Expected a widget with descendant of type `$descendantType`, but none were found.';
    }

    // ByValueKey Finder
    final valueKeyFinderRegex =
        RegExp(r"Found 0 widgets with key ValueKey\((.+?)\)");
    final valueKeyMatch = valueKeyFinderRegex.firstMatch(reason);
    if (valueKeyMatch != null) {
      final valueKey = valueKeyMatch.group(1);
      return 'Expected a widget with ValueKey(`$valueKey`), but none were found.';
    }

    // ByType with subtype
    final typeSubtypeRegex = RegExp(r'Found 0 widgets with type (\w+)<(\w+)>');
    final typeSubtypeMatch = typeSubtypeRegex.firstMatch(reason);
    if (typeSubtypeMatch != null) {
      final widgetType = typeSubtypeMatch.group(1);
      final subtype = typeSubtypeMatch.group(2);
      return 'Expected a widget of type `$widgetType<$subtype>`, but none were found.';
    }

    // Multiple widgets found (when expecting exactly one)
    final multipleWidgetsRegex = RegExp(
        r'Expected: exactly one matching candidate\n\s+Actual: _(\w+)WidgetFinder:<Found (\d+) widgets');
    final multipleMatch = multipleWidgetsRegex.firstMatch(reason);
    if (multipleMatch != null) {
      final finderType = multipleMatch.group(1);
      final count = multipleMatch.group(2);
      return 'Expected exactly one widget, but found $count widgets with $finderType finder.';
    }

    // Widget count mismatch
    final countMismatchRegex = RegExp(
        r'Expected: (\d+) matching candidates\n\s+Actual: _(\w+)WidgetFinder:<Found (\d+) widgets');
    final countMatch = countMismatchRegex.firstMatch(reason);
    if (countMatch != null) {
      final expected = countMatch.group(1);
      final finderType = countMatch.group(2);
      final actual = countMatch.group(3);
      return 'Expected $expected widgets with $finderType finder, but found $actual widgets.';
    }

    // Generic "no widgets found" pattern
    final noWidgetsRegex = RegExp(r'Found 0 widgets');
    if (noWidgetsRegex.hasMatch(reason)) {
      return 'Expected to find a widget, but none were found.';
    }

    // Return the first line of the original error if no specific pattern matches
    return reason.split('\n').first.trim();
  }

  /// Extracts the specific finder type from the error message
  static String? extractFinderType(String reason) {
    final finderTypeRegex = RegExp(r'_(\w+)WidgetFinder');
    final match = finderTypeRegex.firstMatch(reason);
    return match?.group(1);
  }

  /// Extracts the expected count from the error message
  static int? extractExpectedCount(String reason) {
    final expectedRegex = RegExp(r'Expected: (\d+) matching candidates');
    final match = expectedRegex.firstMatch(reason);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Extracts the actual count from the error message
  static int? extractActualCount(String reason) {
    final actualRegex = RegExp(r'Found (\d+) widgets');
    final match = actualRegex.firstMatch(reason);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Checks if the error is related to widget finding
  static bool isWidgetFinderError(String reason) {
    return reason.contains('Found 0 widgets') ||
        reason.contains('Expected: exactly one matching candidate') ||
        reason.contains('Expected:') && reason.contains('Actual:');
  }

  /// Gets a suggestion for fixing the error based on the error type
  static String getSuggestion(String reason) {
    if (reason.contains('Expected a widget with key')) {
      return 'Check if the widget has the correct key assigned.';
    }
    if (reason.contains('Expected a widget with text')) {
      return 'Verify the text content matches exactly (including case and whitespace).';
    }
    if (reason.contains('Expected a widget of type')) {
      return 'Ensure the widget of the specified type exists in the widget tree.';
    }
    if (reason.contains('Expected exactly one widget, but found')) {
      return 'Use a more specific finder or check for duplicate widgets.';
    }
    if (reason.contains('Expected to find a widget, but none were found')) {
      return 'Verify the widget exists and is visible in the current widget tree.';
    }
    return 'Review the widget tree structure and ensure the expected widget is present.';
  }
}
