import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';


import 'html_report_generator.dart';


void run(List<String> arguments) async {

  final parser = ArgParser()
    ..addCommand('test')
    ..addFlag('web', abbr: 'w', negatable: false, help: 'Run on Flutter Web');
  final results = parser.parse(arguments);

  final flutterProjectDir = Directory.current.path;


  final driverFile = File('$flutterProjectDir/test_driver/integration_test.dart');
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
    final runCommand =
        'flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome';

    print('🧪 Running: $runCommand');
    final process = await Process.start(
      'flutter',
      [
        'drive',
        '--driver=test_driver/integration_test.dart',
        '--target=integration_test/app_test.dart',
        '-d',
        'chrome',
      ],
      workingDirectory: flutterProjectDir,
      runInShell: true,
    );

    final buffer = StringBuffer(); // Added: to capture report block
    bool capturing = false;

    // Updated: handle stdout and capture test report
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) async {
      stdout.writeln(line); // Print live logs

      if (line.contains('@@TEST_REPORT@@START')) {
        capturing = true;
        buffer.clear();
      } else if (line.contains('@@TEST_REPORT@@END')) {
        capturing = false;

        try {
          final reportData = json.decode(buffer.toString());
          final outputFile = File('$flutterProjectDir/testmate-report/report.json');
          outputFile.createSync(recursive: true);
          outputFile.writeAsStringSync(
              jsonEncode(reportData, toEncodable: _safeJson));
          print('✅ Report saved to testmate-report/report.json');
          final reportJsonFile =
              File('$flutterProjectDir/testmate-report/report.json');
          final results = jsonDecode(reportJsonFile.readAsStringSync());
          generateHtmlReport(
              results, '$flutterProjectDir/testmate-report/testmate_report.html');
        } catch (e) {
          stderr.writeln('❌ Failed to parse report: $e');
        }
      } else if (capturing) {
        buffer.writeln(line);
      }
    });

    // Print stderr live
    process.stderr.transform(utf8.decoder).listen(stderr.writeln);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      print('❌ Test failed with exit code $exitCode');
    } else {
      print('✅ Test completed successfully.');
    }
  } else {
    print('❌ Invalid command.\n');
    print(parser.usage);
  }
}

// Optional encoder for custom types like DateTime (you can enhance this later)
dynamic _safeJson(dynamic value) {
  if (value is DateTime) return value.toIso8601String();
  return value;
}
