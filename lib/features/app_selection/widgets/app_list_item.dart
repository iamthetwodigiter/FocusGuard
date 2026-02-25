import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppListItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onToggle;

  const AppListItem({
    super.key,
    required this.app,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app.isBlocked 
                ? Colors.red.withValues(alpha: 0.15) 
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: app.isBlocked ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: app.isBlocked ? Colors.red : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: app.isBlocked ? Colors.red.shade50 : Colors.grey.shade100,
                    backgroundImage: app.icon != null
                        ? MemoryImage(Uint8List.fromList(app.icon!))
                        : null,
                    child: app.icon == null
                        ? Icon(Icons.android, color: app.isBlocked ? Colors.red : Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.packageName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: app.isBlocked,
                    onChanged: (_) => onToggle(),
                    activeThumbColor: Colors.red,
                    activeTrackColor: Colors.red.shade200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
