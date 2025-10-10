import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'html_report_generator.dart';

Future<void> run(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('test')
    ..addFlag('web', abbr: 'w', negatable: false, help: 'Run on Flutter Web');
  final results = parser.parse(arguments);

  final flutterProjectDir = Directory.current.path;

  final driverFile =
      File('$flutterProjectDir/test_driver/integration_test.dart');
  final targetFile = File('$flutterProjectDir/integration_test/app_test.dart');

  if (!driverFile.existsSync()) {
    stderr.writeln('❌ driver.dart not found at ${driverFile.path}');
    exit(1);
  }
  if (!targetFile.existsSync()) {
    stderr.writeln('❌ app_test.dart not found at ${targetFile.path}');
    exit(1);
  }


  if (results.command?.name == 'test') {
    final process = await Process.start(
      'flutter',
      [
        'drive',
        '--driver=test_driver/integration_test.dart',
        '--target=integration_test/app_test.dart',
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
