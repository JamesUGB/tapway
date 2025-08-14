// lib/core/utils/logger_config.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerConfig {
  static final Logger logger = Logger('AppLogger');

  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final timestamp = record.time.toString().split('.').first;
      final message = StringBuffer();
      message.write('[$timestamp] ${record.level.name}: ${record.message}');
      
      if (record.error != null) {
        message.write('\nError: ${record.error}');
      }
      
      if (record.stackTrace != null) {
        message.write('\nStack trace: ${record.stackTrace}');
      }
      
      if (record.object != null && record.object is Map) {
        message.write('\nContext: ${_formatContext(record.object as Map)}');
      }
      
      debugPrint(message.toString());
    });
  }

  static String _formatContext(Map context) {
    return context.entries
      .map((e) => '${e.key}: ${e.value}')
      .join(', ');
  }
}