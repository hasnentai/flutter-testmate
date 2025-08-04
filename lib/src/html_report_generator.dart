import 'dart:convert';
import 'dart:io';

void generateHtmlReport(List<dynamic> results, String outputPath) {
  final html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Flutter Integration Test Report</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .stack-trace-collapsed {
      max-height: 3.6em; /* approx. 2 lines */
      overflow: hidden;
    }
    .toggle-btn {
      cursor: pointer;
      color: #2563eb; /* Tailwind blue-600 */
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }
  </style>
</head>
<body class="bg-gray-100 text-gray-800 p-6">
  <div class="max-w-5xl mx-auto">
    <h1 class="text-3xl font-bold mb-6">📊 Flutter Integration Test Report</h1>

    <div id="summary" class="mb-6 text-lg"></div>
    <div id="report"></div>
  </div>

  <script>
    // Screenshot modal functionality
    function openScreenshotModal(imageSrc) {
      const modal = document.createElement('div');
      modal.className = 'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50';
      modal.onclick = () => document.body.removeChild(modal);
      
      modal.innerHTML = 
        '<div class="max-w-4xl max-h-full p-4">' +
          '<img src="' + imageSrc + '" alt="Full size screenshot" class="max-w-full max-h-full object-contain" />' +
          '<div class="text-center mt-4">' +
            '<button onclick="this.parentElement.parentElement.parentElement.click()" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">Close</button>' +
          '</div>' +
        '</div>';
      
      document.body.appendChild(modal);
    }
    
    const data = ${jsonEncode({'results': results})};

    const grouped = {};
    data.results.forEach(test => {
      const suite = test.suite || "Default Suite";
      if (!grouped[suite]) grouped[suite] = [];
      grouped[suite].push(test);
    });

    const reportDiv = document.getElementById("report");
    const summaryDiv = document.getElementById("summary");

    const total = data.results.length;
    const passed = data.results.filter(t => t.status === "passed").length;
    const failed = data.results.filter(t => t.status === "failed").length;
    const passPercent = ((passed / total) * 100).toFixed(1);

    summaryDiv.innerHTML = 
      '<div class="sticky top-0 bg-white border-b border-gray-200 shadow-sm mb-8">' +
        '<div class="max-w-7xl mx-auto px-4 py-6">' +
          '<div class="flex items-center justify-between mb-6">' +
            '<div>' +
              '<h2 class="text-2xl font-bold text-gray-900">Test Results Summary</h2>' +
              '<p class="text-gray-600 mt-1">Generated on ' + new Date().toLocaleString() + '</p>' +
            '</div>' +
            '<div class="text-right">' +
              '<div class="text-3xl font-bold text-gray-900">' + passPercent + '%</div>' +
              '<div class="text-sm text-gray-600">Pass Rate</div>' +
            '</div>' +
          '</div>' +
          
          '<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">' +
            '<div class="bg-white border border-gray-200 rounded-lg p-4 text-center">' +
              '<div class="text-3xl font-bold text-gray-900">' + total + '</div>' +
              '<div class="text-sm text-gray-600">Total Tests</div>' +
            '</div>' +
            '<div class="bg-green-50 border border-green-200 rounded-lg p-4 text-center">' +
              '<div class="text-3xl font-bold text-green-600">' + passed + '</div>' +
              '<div class="text-sm text-green-700">✅ Passed</div>' +
            '</div>' +
            '<div class="bg-red-50 border border-red-200 rounded-lg p-4 text-center">' +
              '<div class="text-3xl font-bold text-red-600">' + failed + '</div>' +
              '<div class="text-sm text-red-700">❌ Failed</div>' +
            '</div>' +
            '<div class="bg-blue-50 border border-blue-200 rounded-lg p-4 text-center">' +
              '<div class="text-3xl font-bold text-blue-600">' + Object.keys(grouped).length + '</div>' +
              '<div class="text-sm text-blue-700">📦 Test Suites</div>' +
            '</div>' +
          '</div>' +
          
          '<div class="bg-gray-50 rounded-lg p-4">' +
            '<div class="flex items-center justify-between mb-2">' +
              '<span class="text-sm font-medium text-gray-700">Progress</span>' +
              '<span class="text-sm text-gray-600">' + passed + ' of ' + total + ' tests passed</span>' +
            '</div>' +
            '<div class="w-full bg-gray-200 rounded-full h-3">' +
              '<div class="bg-gradient-to-r from-green-400 to-green-600 h-3 rounded-full transition-all duration-500" style="width: ' + passPercent + '%"></div>' +
            '</div>' +
          '</div>' +
        '</div>' +
      '</div>';

    let testIndex = 0;
    Object.entries(grouped).forEach(([suite, tests]) => {
      const passed = tests.filter(t => t.status === "passed");
      const failed = tests.filter(t => t.status === "failed");
      const totalTests = tests.length;
      const hasFailure = failed.length > 0;

      const suiteSection = document.createElement("details");
      suiteSection.className = "mb-8 p-4 rounded shadow border " + (hasFailure ? 'bg-red-50 border-red-400' : 'bg-green-50 border-green-300');
      suiteSection.open = hasFailure; // open if failed, else collapsed

      const suiteTitle = document.createElement("summary");
      suiteTitle.className = "cursor-pointer text-xl font-semibold mb-2 " + (hasFailure ? 'text-red-600' : 'text-green-700');
      suiteTitle.innerHTML = '📦 Suite: ' + suite + ' <span class="text-sm font-normal text-gray-600">(' + totalTests + ' Test' + (totalTests !== 1 ? 's' : '') + ')</span>';
      suiteSection.appendChild(suiteTitle);

      // Create a single list maintaining original test order
      let htmlBody = '<ul class="list-disc list-inside">';
      
      tests.forEach((test, index) => {
        const testNumber = index + 1;
        
        if (test.status === 'passed') {
          htmlBody += '<li class="text-green-800 mb-2">✅ ' + test.testName + ' <span class="text-xs text-gray-500">(' + testNumber + '/' + totalTests + ')</span></li>';
        } else {
          const preId = 'trace-' + testIndex++;
          const fullStack = test.stackTrace || '';
          const shortStack = fullStack.split('\\n').slice(0, 3).join('\\n');
          const hasLocation = test.filePath && test.lineNumber;
          
          htmlBody += 
            '<li class="text-red-800 mb-2">' +
              '<span class="font-semibold">❌ ' + test.testName + ' <span class="text-xs text-gray-500">(' + testNumber + '/' + totalTests + ')</span></span>' +
            '<div class="ml-4">' +
              '<p><strong>• Reason:</strong> ' + test.reason + '</p>';
        
        if (hasLocation) {
          htmlBody += 
            '<p class="mt-2">' +
              '<button onclick="navigateToTest(\\'' + test.filePath + '\\', ' + test.lineNumber + ')" ' +
                      'class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm transition-colors">' +
                '🔍 Open in IDE (Line ' + test.lineNumber + ')' +
              '</button>' +
              '<span class="text-xs text-gray-500 ml-2">File: ' + test.filePath + '</span>' +
            '</p>';
        } else {
          htmlBody += '<p class="text-xs text-gray-500 mt-2">⚠️ Could not determine file location</p>';
        }
        
        htmlBody += 
              '<pre id="' + preId + '" class="bg-gray-200 p-2 rounded text-sm mt-2 whitespace-pre-wrap overflow-hidden max-h-24" data-full-stack="' + fullStack.replace(/"/g, '&quot;') + '">' + shortStack + '</pre>' +
              '<button onclick="toggleTrace(\\'' + preId + '\\', this)" class="text-xs text-gray-500 hover:text-gray-700 mt-1 cursor-pointer">📄 Show more logs</button>';
        
        // Add screenshot if available
        if (test.screenshotPath) {
          htmlBody += 
            '<div class="mt-4">' +
              '<p class="text-sm font-medium text-gray-700 mb-2">📸 Screenshot at failure:</p>' +
              '<div class="border border-gray-300 rounded-lg overflow-hidden">' +
                '<img src="' + test.screenshotPath + '" alt="Test failure screenshot" class="w-full max-w-md cursor-pointer hover:opacity-90 transition-opacity" onclick="openScreenshotModal(this.src)" />' +
              '</div>' +
              '<p class="text-xs text-gray-500 mt-1">Click to view full size</p>' +
            '</div>';
        }
        
        htmlBody += 
            '</div>' +
          '</li>';
        }
      });
      
      htmlBody += '</ul>';

      suiteSection.insertAdjacentHTML('beforeend', htmlBody);
      reportDiv.appendChild(suiteSection);
    });

    function toggleTrace(id, btn) {
      const pre = document.getElementById(id);
      const fullStack = pre.getAttribute('data-full-stack');
      
      if (pre.style.maxHeight === "none") {
        // Collapse back to short version
        pre.style.maxHeight = "6rem";
        pre.textContent = fullStack.split('\\n').slice(0, 3).join('\\n');
        btn.innerHTML = "📄 Show more logs";
      } else {
        // Expand to show complete stack trace
        pre.style.maxHeight = "none";
        pre.textContent = fullStack;
        btn.innerHTML = "📄 Show less logs";
      }
    }

    function navigateToTest(filePath, lineNumber) {
      // Get the current HTML file's location to construct absolute path
      const currentLocation = window.location.href;
      const htmlFileIndex = currentLocation.lastIndexOf('/');
      const basePath = currentLocation.substring(0, htmlFileIndex);
      
      // Go up one level from testmate folder to get project root
      const projectRootIndex = basePath.lastIndexOf('/testmate');
      const projectRoot = projectRootIndex !== -1 
          ? basePath.substring(0, projectRootIndex)
          : basePath;
      
      // Convert file:// URL to regular file path
      let absolutePath = projectRoot + '/' + filePath;
      
      // Remove file:// protocol if present
      if (absolutePath.startsWith('file://')) {
        absolutePath = absolutePath.substring(7); // Remove 'file://'
      }
      
      // Handle macOS file:// URLs (they have an extra slash)
      if (absolutePath.startsWith('//')) {
        absolutePath = absolutePath.substring(1); // Remove extra slash
      }
      
      console.log('Current location:', currentLocation);
      console.log('Project root:', projectRoot);
      console.log('Absolute path:', absolutePath);
      
      // Try different IDE protocols
      const protocols = [
        // Cursor IDE (primary)
        'cursor://file/' + encodeURIComponent(absolutePath) + ':' + lineNumber,
        // VS Code
        'vscode://file/' + encodeURIComponent(absolutePath) + ':' + lineNumber,
        // IntelliJ IDEA / Android Studio
        'idea://open?file=' + encodeURIComponent(absolutePath) + '&line=' + lineNumber,
        // Sublime Text
        'subl://' + encodeURIComponent(absolutePath) + ':' + lineNumber,
        // Atom
        'atom://open?url=file://' + encodeURIComponent(absolutePath) + '&line=' + lineNumber,
        // Vim (if using vim-remote)
        'vim://' + encodeURIComponent(absolutePath) + ':' + lineNumber
      ];

      // Try to open with the first available protocol
      let opened = false;
      for (const protocol of protocols) {
        try {
          window.open(protocol, '_blank');
          opened = true;
          console.log('Attempting to open: ' + protocol);
          break;
        } catch (e) {
          console.log('Failed to open with ' + protocol + ':', e);
        }
      }

      if (!opened) {
        // Fallback: Show file path and line number for manual navigation
        alert('Unable to open IDE automatically.\\n\\nFile: ' + filePath + '\\nLine: ' + lineNumber + '\\n\\nPlease open this file manually in your IDE.');
      }
    }
  </script>
</body>
</html>
''';

  final htmlFile = File(outputPath);
  htmlFile.createSync(recursive: true);
  htmlFile.writeAsStringSync(html);
  print('✅ HTML report saved to: $outputPath');
}
