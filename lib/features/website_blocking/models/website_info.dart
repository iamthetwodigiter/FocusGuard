import 'package:hive_flutter/hive_flutter.dart';

part 'website_info.g.dart';

@HiveType(typeId: 3)
class WebsiteInfo {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final bool isBlocked;

  @HiveField(2)
  final DateTime addedAt;

  WebsiteInfo({
    required this.url,
    required this.isBlocked,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  WebsiteInfo copyWith({
    String? url,
    bool? isBlocked,
    DateTime? addedAt,
  }) {
    return WebsiteInfo(
      url: url ?? this.url,
      isBlocked: isBlocked ?? this.isBlocked,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Extract domain from URL for display
  String get domain {
    try {
      final uri = Uri.parse(url.contains('://') ? url : 'https://$url');
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}
