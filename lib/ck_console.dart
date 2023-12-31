import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

class CkConsole {
  /// Error color
  static const String _colorRed = "\x1B[31m";

  /// Warning color
  static const String _colorYellow = "\x1B[33m";

  /// Pass color
  static const String _colorGreen = "\x1B[32m";

  /// Default text color
  static const String _colorMagenta = "\u001b[35m";

  static const String _resetColor = "\x1B[0m";

  static const int _maxLineLength = 50;

  static void version() async {
    File f = File("pubspec.yaml");
    String doc = await f.readAsString();
    Map yaml = loadYaml(doc);
    _log(
      label: 'Ck Console Version Check',
      labelLength: 45,
      content: '> ${yaml['version']}',
      contentLength: _maxLineLength,
      isAndroid: Platform.isWindows,
    );
  }

  static void log(
    Type runtimeType,
    String log, {
    bool logError = false,
    bool logWarning = false,
    bool logPass = false,
  }) {
    assert([logError, logWarning, logPass].where((element) => element == true).length < 2);
    if (Platform.isWindows | Platform.isAndroid) {
      int labelLength = _maxLineLength + 4;
      int contentLength = _maxLineLength - 5;
      String color = "";
      if (logPass) {
        color = _colorGreen;
      }
      if (logWarning) {
        color = _colorYellow;
      }
      if (logError) {
        color = _colorRed;
      }
      if (color.isEmpty) {
        color = _colorMagenta;
      }

      String label = '$color$runtimeType$_resetColor';
      String message = '> $log ';

      _log(
        label: label,
        labelLength: labelLength,
        content: message,
        contentLength: contentLength,
        isAndroid: true,
      );
    } else {
      String label = runtimeType.toString();
      String message = '> $log ';
      _log(
        label: label,
        labelLength: _maxLineLength * 2,
        content: message,
        contentLength: _maxLineLength * 2,
        isAndroid: false,
      );
    }
  }

  static void _log({
    required String label,
    required int labelLength,
    required String content,
    required int contentLength,
    required bool isAndroid,
  }) {
    if (kDebugMode) {
      debugPrint('\n${'[$label] '.padRight(labelLength, '-')}+');
      int messageSegment = (content.length / contentLength).floor();
      if (isAndroid) {
        if (messageSegment < 1) {
          debugPrint(content);
        } else {
          final pattern = RegExp('(.{0,${contentLength - 1}} )|(.*\$)');
          String printOut = "";
          pattern.allMatches(content).forEach((match) {
            String msg = match.group(0)!;
            if (msg.isNotEmpty) {
              if (msg.startsWith('>')) {
                printOut += msg;
              } else {
                printOut += "\n  $msg";
              }
            }
          });
          debugPrint(printOut);
        }
      } else {
        /// XCode solution
        debugPrint('[$label]');
        final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
        pattern.allMatches(content).forEach((match) => debugPrint(match.group(0)));
      }
    } else {
      //  Log somewhere else
    }
  }

  static void logError(
    Error exception,
    String? messageOverride,
  ) {
    log(exception.runtimeType, messageOverride ?? exception.toString(), logError: true);
    debugPrint(exception.stackTrace.toString());
  }

  static void varDump(Object object) {
    inspect(object);
  }
}
