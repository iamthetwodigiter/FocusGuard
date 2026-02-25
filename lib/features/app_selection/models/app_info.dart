import 'package:hive_flutter/hive_flutter.dart';

part 'app_info.g.dart';

/// Represents an installed app on the device
@HiveType(typeId: 0)
class AppInfo {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final List<int>? icon; // Icon bytes

  @HiveField(3)
  final bool isBlocked;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
    this.isBlocked = false,
  });

  AppInfo copyWith({
    String? packageName,
    String? appName,
    List<int>? icon,
    bool? isBlocked,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      icon: icon ?? this.icon,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
