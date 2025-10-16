import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'html_report_generator.dart';

Future<void> run(List<String> arguments) async {
  final parser = ArgParser();
  final testCommand = ArgParser()
    ..addFlag('web', abbr: 'w', negatable: false, help: 'Run on Flutter Web')
    ..addOption('tag', abbr: 't', help: 'Run only tests with specific tag (e.g., @smoke)');
  
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
    // Convert @tag to tag for Flutter test framework compatibility
    final cleanTag = targetTag.startsWith('@') ? targetTag.substring(1) : targetTag;
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
            _saveSafeExpectJson(buffer.toString(), flutterProjectDir);
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

/// Save SafeExpect JSON results to testmate-reports/report.json
void _saveSafeExpectJson(String jsonString, String flutterProjectDir) {
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
      generateHtmlReport(jsonData, '$flutterProjectDir/testmate-reports/safeexpect_report.html');
      print('✅ SafeExpect HTML report generated: testmate-reports/safeexpect_report.html');
    } catch (e) {
      print('⚠️ Could not generate HTML report: $e');
    }
    
  } catch (e) {
    print('❌ Failed to save SafeExpect JSON: $e');
    print('Raw JSON: $jsonString');
  }
}

/// Create a filtered test file containing only tests with the specified tag
Future<File?> createFilteredTestFile(File originalTestFile, String targetTag, String flutterProjectDir) async {
  try {
    
    // Find all test files in integration_test directory
    final integrationTestDir = Directory('$flutterProjectDir/integration_test');
    if (!integrationTestDir.existsSync()) {
      print('❌ Integration test directory not found');
      return null;
    }
    
    final testFiles = integrationTestDir
        .listSync()
        .where((file) => file is File && file.path.endsWith('.test.dart'))
        .cast<File>();
    
    if (testFiles.isEmpty) {
      print('❌ No .test.dart files found in integration_test directory');
      return null;
    }
    
    // Parse all test files and find tests with the target tag
    final List<String> filteredTests = [];
    bool foundAnyTests = false;
    
    for (final testFile in testFiles) {
      final fileContent = await testFile.readAsString();
      final fileLines = fileContent.split('\n');
      
      // Find tests with the target tag
      final List<String> currentFileTests = [];
      bool inTest = false;
      int braceCount = 0;
      
      for (int i = 0; i < fileLines.length; i++) {
        final line = fileLines[i];
        
        // Look for testWidgets or test function
        if (line.contains('testWidgets(') || line.contains('test(')) {
          inTest = true;
          braceCount = 0;
          currentFileTests.clear();
        }
        
        if (inTest) {
          currentFileTests.add(line);
          
          // Count braces to track test function boundaries
          braceCount += line.split('{').length - 1;
          braceCount -= line.split('}').length - 1;
          
          // End of test function - check for tags before clearing
          if (inTest && braceCount == 0 && line.trim().endsWith(');')) {
            // Check if this line contains the target tag
            if (line.contains('tags:') && line.contains(targetTag)) {
              foundAnyTests = true;
              // Add the complete test function
              filteredTests.addAll(currentFileTests);
              filteredTests.add(''); // Add empty line for separation
            }
            inTest = false;
            currentFileTests.clear();
          }
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
    
    // Add imports and setup from the first test file
    final firstTestFile = testFiles.first;
    final firstFileContent = await firstTestFile.readAsString();
    final firstFileLines = firstFileContent.split('\n');
    
    // Add imports
    for (final line in firstFileLines) {
      if (line.startsWith('import ')) {
        if (line.contains('package:flutter_test/flutter_test.dart')) {
          // Import flutter_test but hide group, testWidgets, expect to avoid conflicts
          filteredContent.writeln("import 'package:flutter_test/flutter_test.dart' hide group, testWidgets, expect;");
        } else if (line.contains('package:flutter_testmate/testmate.dart')) {
          // Import testmate normally (not qualified)
          filteredContent.writeln("import 'package:flutter_testmate/testmate.dart';");
        } else {
          filteredContent.writeln(line);
        }
      } else if (line.startsWith('void main()')) {
        break;
      }
    }
    
    // Add main function
    filteredContent.writeln('void main() {');
    filteredContent.writeln('  IntegrationTestWidgetsFlutterBinding.ensureInitialized();');
    
    // Add group wrapper with tag name as test suite
    filteredContent.writeln('  group(\'$cleanTagName Tests\', () {');
    
    // Add filtered tests
    for (final testLine in filteredTests) {
      if (testLine.trim().isNotEmpty) {
        // Convert @tag to tag for Flutter test framework compatibility
        final cleanLine = testLine.replaceAllMapped(RegExp(r"tags:\s*\[\s*'@(\w+)'\s*\]"), (match) => "tags: ['${match.group(1)}']");
        filteredContent.writeln('    $cleanLine');
      } else {
        filteredContent.writeln();
      }
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
    
    print('✅ Found ${filteredTests.where((line) => line.contains('testWidgets(') || line.contains('test(')).length} tests with tag: $targetTag');
    
    return filteredTestFile;
    
  } catch (e) {
    print('❌ Error creating filtered test file: $e');
    return null;
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
