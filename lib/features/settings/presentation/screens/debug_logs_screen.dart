import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:focusguard/services/logging_service.dart';
import 'package:focusguard/core/theme/app_theme.dart';

class DebugLogsScreen extends StatefulWidget {
  const DebugLogsScreen({super.key});

  @override
  State<DebugLogsScreen> createState() => _DebugLogsScreenState();
}

class _DebugLogsScreenState extends State<DebugLogsScreen> {
  late Future<List<String>> _logs;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    setState(() {
      _logs = LoggingService().getServiceLogs();
    });
  }

  Future<void> _shareLogs(List<String> logs) async {
    final logFile = await _saveLogs(logs);
    await SharePlus.instance.share(
      ShareParams(files: [logFile], subject: 'FocusGuard Service Logs'),
    );
  }

  Future<XFile> _saveLogs(List<String> logs) async {
    final logsText = logs.join('\n');
    final timestamp = DateTime.now().toIso8601String();

    final logDir = Directory('/storage/emulated/0/FocusGuard');

    if (!logDir.existsSync()) logDir.createSync(recursive: true);

    final logFile = '${logDir.path}/log_$timestamp.txt';
    File(logFile).writeAsStringSync(logsText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs saved to $logFile'),
        duration: const Duration(seconds: 2),
      ),
    );

    return XFile(logFile);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('System Service Logs'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: _logs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshLogs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  const Text('No logs yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshLogs,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${logs.length} logs',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshLogs,
                      tooltip: 'Refresh logs',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareLogs(logs),
                      tooltip: 'Share logs',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Container(
                      color: index.isEven ? AppColors.surface.withValues(alpha: 0.3) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: _getLogColor(log),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        tooltip: 'Jump to end',
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('🚫') || log.contains('❌')) return Colors.red[700]!;
    if (log.contains('✅') || log.contains('✨')) return Colors.green[700]!;
    if (log.contains('⚠')) return Colors.orange[700]!;
    if (log.contains('🔴')) return Colors.red;
    if (log.contains('🟢')) return Colors.green;
    return AppColors.text;
  }
}
