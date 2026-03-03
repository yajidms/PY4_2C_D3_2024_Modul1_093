import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class LogHelper {
  static const int _defaultLogLevel = 2;

  static Future<void> writeLog(
    String message, {
    String source = 'Unknown',
    int level = 2,
  }) async {
    final int configLevel = _readLogLevel();
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (_isSourceMuted(source, muteList)) return;

    try {
      final String timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      final String label = _getLabel(level);
      final String color = _getColor(level);

      // Tetap kirim ke debug logger agar jejak audit bisa dilihat di IDE.
      dev.log(message, name: source, time: DateTime.now(), level: level * 100);

      // Terminal hanya aktif saat mode verbose (LOG_LEVEL == 3).
      if (_shouldPrintToTerminal(configLevel)) {
        debugPrint('$color[$timestamp][$label][$source] -> $message\x1B[0m');
      }
    } catch (e) {
      dev.log('Logging failed: $e', name: 'SYSTEM', level: 1000);
    }
  }

  static int _readLogLevel() {
    return readLogLevelFromEnv(dotenv.env);
  }

  static bool _isSourceMuted(String source, String muteList) {
    return isSourceMutedForEnv(source, muteList);
  }

  static bool _shouldPrintToTerminal(int configLevel) {
    return shouldPrintToTerminalForLevel(configLevel);
  }

  @visibleForTesting
  static int readLogLevelFromEnv(Map<String, String> env) {
    return int.tryParse((env['LOG_LEVEL'] ?? '').trim()) ?? _defaultLogLevel;
  }

  @visibleForTesting
  static bool shouldPrintToTerminalForLevel(int configLevel) {
    return configLevel == 3;
  }

  @visibleForTesting
  static bool isSourceMutedForEnv(String source, String muteList) {
    final normalizedSource = _normalizeSource(source);
    if (normalizedSource.isEmpty) return false;

    final muted = muteList
        .split(',')
        .map(_normalizeSource)
        .where((item) => item.isNotEmpty)
        .toSet();

    if (muted.isEmpty) return false;

    final sourceBasename = normalizedSource.split('/').last;
    return muted.any(
      (entry) =>
          normalizedSource == entry ||
          sourceBasename == entry ||
          normalizedSource.endsWith('/$entry'),
    );
  }

  static String _normalizeSource(String value) {
    return value.trim().toLowerCase().replaceAll('\\', '/');
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return 'ERROR';
      case 2:
        return 'INFO';
      case 3:
        return 'VERBOSE';
      default:
        return 'LOG';
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m';
      case 2:
        return '\x1B[32m';
      case 3:
        return '\x1B[34m';
      default:
        return '\x1B[0m';
    }
  }
}
