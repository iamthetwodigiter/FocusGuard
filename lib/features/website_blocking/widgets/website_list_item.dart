import 'package:flutter/material.dart';
import '../models/website_info.dart';

class WebsiteListItem extends StatelessWidget {
  final WebsiteInfo website;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const WebsiteListItem({
    super.key,
    required this.website,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: website.isBlocked 
                ? Colors.red.withValues(alpha: 0.15) 
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: website.isBlocked ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: website.isBlocked ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: website.isBlocked ? Colors.red : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.public_off,
                    color: website.isBlocked ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        website.domain,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        website.url,
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
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                  tooltip: 'Remove',
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: website.isBlocked,
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
