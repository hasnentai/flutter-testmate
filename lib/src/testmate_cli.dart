import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'html_report_generator.dart';

Future<void> run(List<String> arguments) async {
  final parser = ArgParser();
  final testCommand = ArgParser()
    ..addFlag('web', abbr: 'w', negatable: false, help: 'Run on Flutter Web')
    ..addOption('tag', abbr: 't', help: 'Run only tests with specific tag (e.g., @smoke)')
    ..addOption('report-name', abbr: 'r', help: 'Custom name for the test report');
  
  parser.addCommand('test', testCommand);
  final results = parser.parse(arguments);

  final flutterProjectDir = Directory.current.path;

  final driverFile =
      File('$flutterProjectDir/test_driver/integration_test.dart');
  final targetFile = File('$flutterProjectDir/integration_test/app.test.dart');

  if (!driverFile.existsSync()) {
    stderr.writeln('❌ driver.dart not found at ${driverFile.path}');
    exit(1);
  }
  if (!targetFile.existsSync()) {
    stderr.writeln('❌ app_test.dart not found at ${targetFile.path}');
    exit(1);
  }

  // Handle tag filtering
  String? targetTag = results.command?['tag'] as String?;
  File? filteredTestFile;
  
  if (targetTag != null) {
    print('🏷️  Filtering tests with tag: $targetTag');
    filteredTestFile = await createFilteredTestFile(targetFile, targetTag, flutterProjectDir);
    if (filteredTestFile == null) {
      stderr.writeln('❌ No tests found with tag: $targetTag');
      exit(1);
    }
    print('✅ Created filtered test file: ${filteredTestFile.path}');
  }


  if (results.command?.name == 'test') {
    // Use filtered test file if available, otherwise use original
    final testTarget = filteredTestFile?.path ?? 'integration_test/app.test.dart';
    final reportName = results.command?['report-name'] as String?;
    
    final process = await Process.start(
      'flutter',
      [
        'drive',
        '--driver=test_driver/integration_test.dart',
        '--target=$testTarget',
        '-d',
        'chrome',
        '--headless'
      ],
      workingDirectory: flutterProjectDir,
      runInShell: true,
    );

    final buffer = StringBuffer(); // To capture SafeExpect JSON
    bool capturingJson = false;

    // Handle stdout and capture SafeExpect JSON
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) async {
      stdout.writeln(line); // Print live logs

      // Capture SafeExpect JSON output
      if (line.contains('Test Results JSON:')) {
        capturingJson = true;
        buffer.clear();
      } else if (capturingJson && line.trim().isNotEmpty) {
        // Check if this line is valid JSON (starts with { and ends with })
        final trimmedLine = line.trim();
        if (trimmedLine.startsWith('{') && trimmedLine.endsWith('}')) {
          try {
            // Validate it's proper JSON
            json.decode(trimmedLine);
            buffer.write(trimmedLine);
            capturingJson = false;
            
            // Save the SafeExpect JSON to testmate-reports/report.json
            _saveSafeExpectJson(buffer.toString(), flutterProjectDir, reportName);
          } catch (e) {
            // If not valid JSON, continue capturing
            buffer.writeln(line);
          }
        } else {
          buffer.writeln(line);
        }
      }
    });

    // Print stderr live
    process.stderr.transform(utf8.decoder).listen(stderr.writeln);

    final exitCode = await process.exitCode;
    print('\n🎯 Test execution completed!');
    if (exitCode != 0) {
      print('❌ Test failed with exit code $exitCode');
    } else {
      print('✅ Test completed successfully.');
    }
    
    // Clean up filtered test file if it was created
    if (filteredTestFile != null && filteredTestFile.existsSync()) {
      try {
        filteredTestFile.deleteSync();
        print('🧹 Cleaned up filtered test file: ${filteredTestFile.path}');
      } catch (e) {
        print('⚠️ Could not clean up filtered test file: $e');
      }
    }
    
    // Kill any remaining Chrome processes to ensure browser closes
    await _killChromeProcesses();
  } else {
    print('❌ Invalid command.\n');
    print('Use "testmate --help" for usage information.');
  }
}


/// Create a filtered test file containing only tests with the specified tag
Future<File?> createFilteredTestFile(File originalTestFile, String targetTag, String flutterProjectDir) async {
  try {
    
    // Recursively find all test files in integration_test directory and subdirectories
    final integrationTestDir = Directory('$flutterProjectDir/integration_test');
    if (!integrationTestDir.existsSync()) {
      print('❌ Integration test directory not found');
      return null;
    }
    
    final testFiles = <File>[];
    await _findTestFilesRecursively(integrationTestDir, testFiles);
    
    if (testFiles.isEmpty) {
      print('❌ No .test.dart files found in integration_test directory');
      return null;
    }
    
    print('🔍 Found ${testFiles.length} test files to scan');
    
    // Parse all test files and find tests with the target tag
    final List<Map<String, dynamic>> filteredTests = [];
    bool foundAnyTests = false;
    
    for (final testFile in testFiles) {
      print('📄 Scanning: ${testFile.path}');
      final fileContent = await testFile.readAsString();
      final fileLines = fileContent.split('\n');
      
      // Find all test functions and their tags
      final List<Map<String, dynamic>> fileTests = _parseTestFile(fileLines, testFile.path);
      
      for (final test in fileTests) {
        final tags = test['tags'] as List<String>;
        if (tags.contains(targetTag)) {
          foundAnyTests = true;
          // Add source file path to the test data
          test['sourceFile'] = testFile.path;
          filteredTests.add(test);
          print('✅ Found test: ${test['name']} with tag: $targetTag');
        }
      }
    }
    
    if (!foundAnyTests) {
      print('❌ No tests found with tag: $targetTag');
      return null;
    }
    
    // Create the filtered test file inside integration_test folder with tag name
    final cleanTagName = targetTag.startsWith('@') ? targetTag.substring(1) : targetTag;
    final filteredTestFile = File('$flutterProjectDir/integration_test/${cleanTagName}_test.dart');
    
    // Build the filtered test file content
    final filteredContent = StringBuffer();
    
    // Collect all unique imports from all test files that contain filtered tests
    final Set<String> allImports = <String>{};
    
    // Get the source files that contain the filtered tests
    final Set<String> sourceFiles = filteredTests.map((test) => test['sourceFile'] as String).toSet();
    
    for (final sourceFile in sourceFiles) {
      final file = File(sourceFile);
      final fileContent = await file.readAsString();
      final fileLines = fileContent.split('\n');
      
      for (final line in fileLines) {
        if (line.startsWith('import ')) {
          allImports.add(line.trim());
        } else if (line.startsWith('void main()')) {
          break;
        }
      }
    }
    
    // Add imports
    for (final importLine in allImports) {
      if (importLine.contains('package:flutter_test/flutter_test.dart')) {
        // Import flutter_test but hide group, testWidgets, expect to avoid conflicts
        filteredContent.writeln("import 'package:flutter_test/flutter_test.dart' hide group, testWidgets, expect;");
      } else if (importLine.contains('package:flutter_testmate/testmate.dart')) {
        // Import testmate normally (not qualified)
        filteredContent.writeln("import 'package:flutter_testmate/testmate.dart';");
      } else if (importLine.contains('package:')) {
        // Package imports - keep as is
        filteredContent.writeln(importLine);
      } else {
        // Relative imports - need to check if it's an absolute path and skip it if so
        final normalizedPath = importLine.replaceAll('\\', '/');
        
        // Check for mixed absolute/relative paths (like ../../../../C:/path)
        if (normalizedPath.contains(':/') && normalizedPath.contains('../')) {
          print('⚠️ Skipping mixed absolute/relative path import: $importLine');
          continue; // Skip this import
        }
        
        // Check if it's an absolute path (contains drive letter like C:/ or starts with /)
        if (normalizedPath.contains(':/') && normalizedPath.indexOf(':/') < 10) {
          print('⚠️ Skipping absolute path import: $importLine');
          continue; // Skip this import
        } else if (normalizedPath.contains('://') || normalizedPath.startsWith('/')) {
          print('⚠️ Skipping absolute Unix path import: $importLine');
          continue; // Skip this import
        } else {
          // Relative imports - need to fix the path
          final fixedImport = _fixRelativeImportPath(importLine, filteredTestFile.path, sourceFiles);
          filteredContent.writeln(fixedImport);
        }
      }
    }
    
    // Add main function
    filteredContent.writeln('void main() {');
    filteredContent.writeln('  IntegrationTestWidgetsFlutterBinding.ensureInitialized();');
    
    // Add group wrapper with tag name as test suite
    filteredContent.writeln('  group(\'$cleanTagName Tests\', () {');
    
    // Add filtered tests
    for (final test in filteredTests) {
      final testLines = test['lines'] as List<String>;
      for (final line in testLines) {
        if (line.trim().isNotEmpty) {
          filteredContent.writeln('    $line');
        } else {
          filteredContent.writeln();
        }
      }
      filteredContent.writeln(); // Add empty line between tests
    }
    
    // Close the group
    filteredContent.writeln('  });');
    
    // Add tearDownAll
    filteredContent.writeln();
    filteredContent.writeln('  // Print and save all test results as JSON at the end');
    filteredContent.writeln('  tearDownAll(() {');
    filteredContent.writeln('    SafeExpect');
    filteredContent.writeln('        .printAndSaveTestResults(); // This will both print and save to testmate-reports/report.json');
    filteredContent.writeln('  });');
    filteredContent.writeln('}');
    
    await filteredTestFile.writeAsString(filteredContent.toString());
    
    print('✅ Found ${filteredTests.length} tests with tag: $targetTag');
    
    return filteredTestFile;
    
  } catch (e) {
    print('❌ Error creating filtered test file: $e');
    return null;
  }
}

/// Recursively find all .test.dart files in a directory
Future<void> _findTestFilesRecursively(Directory dir, List<File> testFiles) async {
  await for (final entity in dir.list()) {
    if (entity is File && entity.path.endsWith('.test.dart')) {
      testFiles.add(entity);
    } else if (entity is Directory) {
      await _findTestFilesRecursively(entity, testFiles);
    }
  }
}

/// Parse a test file and extract test functions with their tags
List<Map<String, dynamic>> _parseTestFile(List<String> lines, String filePath) {
  final List<Map<String, dynamic>> tests = [];
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    // Look for testWidgets or test function
    if (line.contains('testWidgets(') || line.contains('test(')) {
      final test = _parseTestFunction(lines, i);
      if (test != null) {
        tests.add(test);
      }
    }
  }
  
  return tests;
}

/// Parse a single test function and extract its tags
Map<String, dynamic>? _parseTestFunction(List<String> lines, int startIndex) {
  final List<String> testLines = [];
  final List<String> tags = [];
  String? testName;
  
  bool inTest = false;
  int braceCount = 0;
  bool foundTags = false;
  
  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i];
    testLines.add(line);
    
    // Extract test name
    if (testName == null && (line.contains('testWidgets(') || line.contains('test('))) {
      final match = RegExp('(testWidgets|test)\\s*\\(\\s*[\'"]([^\'"]+)[\'"]').firstMatch(line);
      if (match != null) {
        testName = match.group(2);
      }
    }
    
    // Count braces to track test function boundaries
    if (line.contains('{')) {
      braceCount++;
      inTest = true;
    }
    if (line.contains('}')) {
      braceCount--;
    }
    
    // Look for tags
    if (line.contains('tags:')) {
      foundTags = true;
      // Handle both single tag and tag array formats
      if (line.contains('[')) {
        // Multi-line tag array - collect all lines until we find the closing bracket
        String tagContent = '';
        int bracketCount = 0;
        bool inTagArray = false;
        
        for (int j = i; j < lines.length; j++) {
          final tagLine = lines[j];
          tagContent += '$tagLine\n';
          
          // Count brackets to find the end of the tag array
          bracketCount += tagLine.split('[').length - 1;
          bracketCount -= tagLine.split(']').length - 1;
          
          if (bracketCount == 0 && tagLine.contains(']')) {
            break;
          }
        }
        
        // Extract tags from the collected content
        final tagMatches = RegExp("'([^']+)'").allMatches(tagContent);
        for (final match in tagMatches) {
          tags.add(match.group(1)!);
        }
      } else {
        // Single tag
        final tagMatch = RegExp("tags:\\s*['\"]([^'\"]+)['\"]").firstMatch(line);
        if (tagMatch != null) {
          tags.add(tagMatch.group(1)!);
        }
      }
    }
    
    // End of test function
    if (inTest && braceCount == 0 && line.trim().endsWith(');')) {
      break;
    }
  }
  
  if (testName != null) {
    return {
      'name': testName,
      'lines': testLines,
      'tags': tags,
    };
  }
  
  return null;
}

/// Fix relative import paths based on the source and destination file locations
String _fixRelativeImportPath(String importLine, String generatedFilePath, Set<String> sourceFiles) {
  // Extract the import path from the import statement
  final importMatch = RegExp("import\\s+['\"]([^'\"]+)['\"]").firstMatch(importLine);
  if (importMatch == null) return importLine;
  
  final originalPath = importMatch.group(1)!;
  
  // If it's already a package import, return as is
  if (originalPath.startsWith('package:')) {
    return importLine;
  }
  
  // Normalize path separators (convert backslashes to forward slashes)
  final normalizedPath = originalPath.replaceAll('\\', '/');
  
  // Check if it contains an absolute Windows path (starts with drive letter like C:/)
  if (normalizedPath.contains(':/') && normalizedPath.indexOf(':/') < 3) {
    print('⚠️ Skipping absolute path import: $originalPath');
    return importLine;
  }
  
  // Check if it already starts with / (absolute Unix path)
  if (normalizedPath.startsWith('/')) {
    print('⚠️ Skipping absolute Unix path import: $originalPath');
    return importLine;
  }
  
  // Find which source file this import came from
  String? sourceFile;
  for (final file in sourceFiles) {
    final fileContent = File(file).readAsStringSync();
    if (fileContent.contains(importLine)) {
      sourceFile = file;
      break;
    }
  }
  
  if (sourceFile == null) return importLine;
  
  try {
    // Calculate the correct relative path
    final sourceDir = Directory(sourceFile).absolute.parent.path;
    final generatedDir = Directory(generatedFilePath).absolute.parent.path;
    
    // Resolve the original import path relative to the source file
    final originalAbsolutePath = _resolvePath(sourceDir, normalizedPath);
    
    // Verify the file exists
    final targetFile = File(originalAbsolutePath);
    if (!targetFile.existsSync()) {
      print('⚠️ Target file does not exist: $originalAbsolutePath');
      return importLine;
    }
    
    // Calculate the relative path from the generated file to the target
    final relativePath = _getRelativePath(generatedDir, originalAbsolutePath);
    
    // Replace the path in the import statement (keep original quotes)
    return importLine.replaceFirst(originalPath, relativePath);
  } catch (e) {
    print('⚠️ Error fixing import path: $e');
    return importLine;
  }
}

/// Resolve a relative path against a base directory (returns absolute path)
String _resolvePath(String baseDir, String relativePath) {
  // Normalize the path
  final base = Directory(baseDir);
  final baseUri = Uri.directory(base.path);
  final relativeUri = Uri.file(relativePath);
  final resolvedUri = baseUri.resolve(relativeUri.path);
  return resolvedUri.path;
}

/// Get the relative path from one directory to another
String _getRelativePath(String fromDir, String toPath) {
  try {
    // Normalize paths to use forward slashes
    String normalizePath(String path) => path.replaceAll('\\', '/');
    
    var from = normalizePath(Directory(fromDir).absolute.path);
    var to = normalizePath(File(toPath).absolute.path);
    
    // Handle Windows drive letters
    bool isWindows = Platform.isWindows;
    String fromDrive = '';
    String toDrive = '';
    
    if (isWindows) {
      if (from.length > 2 && from[1] == ':') {
        fromDrive = from.substring(0, 2);
        from = from.substring(2);
      }
      if (to.length > 2 && to[1] == ':') {
        toDrive = to.substring(0, 2);
        to = to.substring(2);
      }
      
      // If drives are different, we can't create a relative path
      if (fromDrive.isNotEmpty && toDrive.isNotEmpty && fromDrive != toDrive) {
        throw Exception('Cannot create relative path between different drives');
      }
    }
    
    // Split into path segments
    final fromParts = from.split('/').where((p) => p.isNotEmpty && p != '.',).toList();
    final toParts = to.split('/').where((p) => p.isNotEmpty && p != '.',).toList();
    
    // Find the common prefix
    int commonLength = 0;
    while (commonLength < fromParts.length && 
           commonLength < toParts.length && 
           fromParts[commonLength] == toParts[commonLength]) {
      commonLength++;
    }
    
    // Calculate the relative path
    final relativeParts = <String>[];
    
    // Add '../' for each directory we need to go up from the source
    for (int i = commonLength; i < fromParts.length; i++) {
      relativeParts.add('..');
    }
    
    // Add the remaining path to the target
    for (int i = commonLength; i < toParts.length; i++) {
      relativeParts.add(toParts[i]);
    }
    
    final relativePath = relativeParts.join('/');
    return relativePath.isEmpty ? '.' : relativePath;
  } catch (e) {
    print('⚠️ Error calculating relative path: $e');
    return '.';
  }
}

/// Kill any remaining Chrome processes to ensure browser closes
Future<void> _killChromeProcesses() async {
  try {
    print('🧹 Cleaning up Chrome processes...');
    
    // Detect the platform and use appropriate command
    if (Platform.isWindows) {
      // Windows: Use taskkill to kill Chrome processes with --remote-debugging-port
      // This targets only Chrome instances launched by Flutter
      final result = await Process.run(
        'wmic',
        ['process', 'where', '"name=\'chrome.exe\' and CommandLine like \'%remote-debugging-port%\'"', 'delete'],
        runInShell: true,
      );
      // If the above fails, fall back to killing all chrome.exe
      if (result.exitCode != 0) {
        await Process.run('taskkill', ['/F', '/IM', 'chrome.exe'], runInShell: true);
      }
    } else {
      // macOS/Linux: Kill Chrome processes with --remote-debugging-port (Flutter's test Chrome)
      // This is safer as it only kills Chrome instances launched by Flutter testing
      final result = await Process.run('pkill', ['-f', 'chrome.*remote-debugging-port'], runInShell: true);
      
      // If no specific Chrome instance found, try the general chrome process
      if (result.exitCode != 0) {
        await Process.run('pkill', ['-f', 'Chromium.*remote-debugging-port'], runInShell: true);
      }
    }
    
    // Give it a moment to clean up
    await Future.delayed(Duration(milliseconds: 500));
    print('✅ Chrome processes cleaned up');
  } catch (e) {
    // It's okay if this fails - Chrome might have already closed
    print('ℹ️ Chrome cleanup completed (some processes may have already been closed)');
  }
}

/// Save SafeExpect JSON results to testmate-reports/report.json
void _saveSafeExpectJson(String jsonString, String flutterProjectDir, [String? reportName]) {
  try {
    // Validate the JSON first
    final jsonData = json.decode(jsonString);
    
    // Create the testmate-reports directory
    final reportsDir = Directory('$flutterProjectDir/testmate-reports');
    if (!reportsDir.existsSync()) {
      reportsDir.createSync(recursive: true);
    }
    
    // Save to testmate-reports/report.json
    final reportFile = File('$flutterProjectDir/testmate-reports/report.json');
    reportFile.writeAsStringSync(jsonString);
    
    print('✅ SafeExpect results saved to testmate-reports/report.json');
    
    // Also generate HTML report from the SafeExpect JSON
    try {
      final reportFileName = reportName != null ? '${reportName}_report.html' : 'safeexpect_report.html';
      generateHtmlReport(jsonData, '$flutterProjectDir/testmate-reports/$reportFileName');
      print('✅ SafeExpect HTML report generated: testmate-reports/$reportFileName');
    } catch (e) {
      print('⚠️ Could not generate HTML report: $e');
    }
    
  } catch (e) {
    print('❌ Failed to save SafeExpect JSON: $e');
    print('Raw JSON: $jsonString');
  }
}
