import 'package:focusguard/services/native_bridge/android_service_bridge.dart';
import 'package:flutter/material.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal();

  /// Retrieve all service logs
  Future<List<String>> getServiceLogs() async {
    return await AndroidServiceBridge.getServiceLogs();
  }

  /// Get logs as a single formatted string
  Future<String> getLogsAsString() async {
    final logs = await getServiceLogs();
    return logs.join('\n');
  }

  /// Log a message to the native service
  Future<void> log(String message) async {
    debugPrint(message);
    await AndroidServiceBridge.logToService(message);
  }

  /// Log with custom prefix
  Future<void> logWithPrefix(String prefix, String message) async {
    final formatted = '$prefix $message';
    await log(formatted);
  }
}
