# Contributing to TestMate

Thank you for your interest in contributing to TestMate! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

Before creating a new issue, please:

1. **Search existing issues** to see if your problem has already been reported
2. **Check the documentation** to see if your question is already answered
3. **Provide detailed information** including:
   - Flutter version
   - Dart version
   - Operating system
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages (if any)

### Feature Requests

We welcome feature requests! Please:

1. **Describe the feature** clearly and concisely
2. **Explain the use case** and why it would be valuable
3. **Provide examples** of how you would use it
4. **Consider implementation** - would you be willing to help implement it?

### Code Contributions

#### Development Setup

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/testmate.git
   cd testmate
   ```
3. **Install dependencies**:
   ```bash
   dart pub get
   ```
4. **Run tests**:
   ```bash
   dart test
   ```
5. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Coding Guidelines

- **Follow Dart conventions** - use `dart format` and `dart analyze`
- **Write tests** for new functionality
- **Update documentation** for new features
- **Keep commits atomic** - one logical change per commit
- **Write descriptive commit messages**

#### Testing

- **Run all tests** before submitting: `dart test`
- **Add tests** for new functionality
- **Update existing tests** if you change behavior
- **Test on multiple platforms** if applicable

#### Submitting Changes

1. **Push your changes** to your fork
2. **Create a pull request** with:
   - Clear description of changes
   - Link to related issues
   - Screenshots (if UI changes)
   - Test results

## 🏗️ Project Structure

```
testmate/
├── lib/
│   ├── testmate.dart              # Main library exports
│   └── src/
│       ├── error_summarizer.dart  # Error summarization logic
│       ├── reporter.dart          # Test reporting functionality
│       ├── testmate_cli.dart      # CLI implementation
│       └── html_report_generator.dart # HTML report generation
├── bin/
│   └── testmate.dart              # CLI entry point
├── test/
│   └── error_summarizer_test.dart # Unit tests
├── example/                       # Example usage
├── README.md                      # Main documentation
├── CHANGELOG.md                   # Version history
├── CONTRIBUTING.md                # This file
└── LICENSE                        # MIT License
```

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/error_summarizer_test.dart
```

### Test Coverage

We aim for high test coverage. When adding new features:

1. **Write unit tests** for all public APIs
2. **Test edge cases** and error conditions
3. **Mock external dependencies** appropriately
4. **Test CLI commands** with various inputs

### Test Examples

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:testmate/src/error_summarizer.dart';

void main() {
  group('ErrorSummarizer', () {
    test('should summarize widget key finder errors', () {
      const errorMessage = "Expected: exactly one matching candidate\n"
          "  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'login_button'>]: []>\n"
          "   Which: means none were found but one was expected";
      
      final result = ErrorSummarizer.summarizeFailure(errorMessage);
      expect(result, equals('Expected a widget with key `login_button`, but none were found.'));
    });
  });
}
```

## 📝 Documentation

### Code Documentation

- **Document all public APIs** with DartDoc comments
- **Provide examples** in documentation
- **Keep documentation up to date** with code changes

### Example Documentation

```dart
/// Summarizes Flutter test failures by analyzing the error message
/// and providing a clear, actionable description of what went wrong.
/// 
/// This function supports various Flutter test finder errors including:
/// - Widget key finders
/// - Text finders
/// - Type finders
/// - Icon finders
/// - And many more
/// 
/// Example:
/// ```dart
/// final summarizedError = ErrorSummarizer.summarizeFailure(errorMessage);
/// print(summarizedError); // "Expected a widget with key `login_button`, but none were found."
/// ```
static String summarizeFailure(String reason) {
  // Implementation...
}
```

## 🚀 Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward-compatible manner
- **PATCH** version for backward-compatible bug fixes

### Before Release

1. **Update version** in `pubspec.yaml`
2. **Update CHANGELOG.md** with new features and fixes
3. **Run all tests** and ensure they pass
4. **Update documentation** if needed
5. **Test on multiple platforms** if applicable

### Publishing

1. **Create a release** on GitHub
2. **Publish to pub.dev**:
   ```bash
   dart pub publish
   ```
3. **Announce the release** in the community

## 🐛 Bug Fixes

When fixing bugs:

1. **Add a test** that reproduces the bug
2. **Fix the bug** in the code
3. **Verify the test passes**
4. **Update documentation** if the fix changes behavior
5. **Add to CHANGELOG.md** under "Fixed"

## ✨ Feature Development

When adding features:

1. **Discuss the feature** in an issue first
2. **Design the API** carefully
3. **Implement the feature** with tests
4. **Update documentation** and examples
5. **Add to CHANGELOG.md** under "Added"

## 📞 Getting Help

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: support@testmate.dev (for private matters)

## 🙏 Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **CHANGELOG.md** for significant contributions
- **GitHub contributors** page

Thank you for contributing to TestMate! 🎉 